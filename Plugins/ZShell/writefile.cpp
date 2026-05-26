#include "writefile.hpp"

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtQuick/qquickimageprovider.h>
#include <QtQuick/qquickitemgrabresult.h>
#include <QtQuick/qquickwindow.h>

#include <qdir.h>
#include <qfile.h>
#include <qfileinfo.h>
#include <qfuturewatcher.h>
#include <qimage.h>
#include <qjsengine.h>
#include <qqmlengine.h>

namespace ZShell {

// ============================================================
// saveItem
// ============================================================

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path) {
	this->saveItem(target, path, QRect(), QJSValue(), QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect) {
	this->saveItem(target, path, rect, QJSValue(), QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, QJSValue onSaved) {
	this->saveItem(target, path, QRect(), onSaved, QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, QJSValue onSaved, QJSValue onFailed) {
	this->saveItem(target, path, QRect(), onSaved, onFailed);
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect, QJSValue onSaved) {
	this->saveItem(target, path, rect, onSaved, QJSValue());
}

void ZShellIo::saveItem(
	QQuickItem* target,
	const QUrl& path,
	const QRect& rect,
	QJSValue onSaved,
	QJSValue onFailed
	) {
	if (!target) {
		qWarning() << "ZShellIo::saveItem: a target is required";
		return;
	}

	if (!path.isLocalFile()) {
		qWarning() << "ZShellIo::saveItem:" << path << "is not a local file";
		return;
	}

	if (!target->window()) {
		qWarning() << "ZShellIo::saveItem: unable to save target"
		           << target
		           << "without a window";
		return;
	}

	auto scaledRect = rect;

	const qreal scale = target->window()->devicePixelRatio();

	if (rect.isValid() && !qFuzzyCompare(scale + 1.0, 2.0)) {
		scaledRect = QRectF(
			rect.left() * scale,
			rect.top() * scale,
			rect.width() * scale,
			rect.height() * scale
			).toRect();
	}

	const QSharedPointer<const QQuickItemGrabResult> grabResult =
		target->grabToImage();

	QObject::connect(
		grabResult.data(),
		&QQuickItemGrabResult::ready,
		this,
		[grabResult, scaledRect, path, onSaved, onFailed, this]() {

			QImage image = grabResult->image();

			if (scaledRect.isValid()) {
				image = image.copy(scaledRect);
			}

			const auto future = QtConcurrent::run([image, path]() {

				const QString file = path.toLocalFile();
				const QString parent = QFileInfo(file).absolutePath();

				return QDir().mkpath(parent) && image.save(file);
			});

			auto* watcher = new QFutureWatcher<bool>(this);
			auto* engine = qmlEngine(this);

			QObject::connect(
				watcher,
				&QFutureWatcher<bool>::finished,
				this,
				[=]() {

				if (watcher->result()) {

					if (onSaved.isCallable()) {
						onSaved.call({
							QJSValue(path.toLocalFile()),
							engine->toScriptValue(QVariant::fromValue(path))
						});
					}

				} else {

					qWarning() << "ZShellIo::saveItem: failed to save"
					           << path;

					if (onFailed.isCallable()) {
						onFailed.call({
							engine->toScriptValue(QVariant::fromValue(path))
						});
					}
				}

				watcher->deleteLater();
			}
				);

			watcher->setFuture(future);
		}
		);
}

// ============================================================
// saveImage
// ============================================================

void ZShellIo::saveImage(const QUrl& source, const QUrl& target) {
	this->saveImage(source, target, QJSValue(), QJSValue());
}

void ZShellIo::saveImage(const QUrl& source, const QUrl& target, QJSValue onSaved) {
	this->saveImage(source, target, onSaved, QJSValue());
}

void ZShellIo::saveImage(
	const QUrl& source,
	const QUrl& target,
	QJSValue onSaved,
	QJSValue onFailed
	) {
	auto* engine = qmlEngine(this);

	const auto future = QtConcurrent::run([this, source, target]() {
			return this->saveImageInternal(source, target);
		});

	auto* watcher = new QFutureWatcher<bool>(this);

	QObject::connect(
		watcher,
		&QFutureWatcher<bool>::finished,
		this,
		[=]() {

			if (watcher->result()) {

				if (onSaved.isCallable()) {
					onSaved.call({
						QJSValue(target.toLocalFile()),
						engine->toScriptValue(QVariant::fromValue(target))
					});
				}

			} else {

				qWarning() << "ZShellIo::saveImage: failed to save"
				           << source
				           << "to"
				           << target;

				if (onFailed.isCallable()) {
					onFailed.call({
						engine->toScriptValue(QVariant::fromValue(target))
					});
				}
			}

			watcher->deleteLater();
		}
		);

	watcher->setFuture(future);
}

bool ZShellIo::saveImageInternal(const QUrl& source, const QUrl& target) const {

	if (!target.isLocalFile()) {
		qWarning() << "ZShellIo::saveImage: target"
		           << target
		           << "is not a local file";
		return false;
	}

	const QString targetFile = target.toLocalFile();

	if (!QDir().mkpath(QFileInfo(targetFile).absolutePath())) {
		return false;
	}

	// ========================================================
	// Local file path
	// ========================================================

	if (source.isLocalFile()) {

		QFile::remove(targetFile);

		return QFile::copy(
			source.toLocalFile(),
			targetFile
			);
	}

	// ========================================================
	// image:// provider path
	// ========================================================

	if (source.scheme() == "image") {

		auto* engine = qmlEngine(const_cast<ZShellIo*>(this));

		if (!engine) {
			qWarning() << "ZShellIo::saveImage: no QQmlEngine";
			return false;
		}

		const QString providerId = source.host();

		const QString imageId =
			source.path().startsWith('/')
			        ? source.path().mid(1)
			        : source.path();

		auto* providerBase =
			engine->imageProvider(providerId);

		if (!providerBase) {
			qWarning() << "ZShellIo::saveImage: provider not found"
			           << providerId;
			return false;
		}

		auto* provider =
			dynamic_cast<QQuickImageProvider*>(providerBase);

		if (!provider) {
			qWarning() << "ZShellIo::saveImage: provider is not a QQuickImageProvider"
			           << providerId;
			return false;
		}

		if (!provider) {
			qWarning() << "ZShellIo::saveImage: provider not found"
			           << providerId;
			return false;
		}

		QSize size;
		QImage image;

		switch (provider->imageType()) {

		case QQuickImageProvider::Image:
			image = provider->requestImage(
				imageId,
				&size,
				QSize()
				);
			break;

		case QQuickImageProvider::Pixmap:
			image = provider->requestPixmap(
				imageId,
				&size,
				QSize()
				).toImage();
			break;

		default:
			qWarning() << "ZShellIo::saveImage: unsupported provider type";
			return false;
		}

		if (image.isNull()) {
			qWarning() << "ZShellIo::saveImage: provider returned null image";
			return false;
		}

		return image.save(targetFile);
	}

	qWarning() << "ZShellIo::saveImage: unsupported source"
	           << source;

	return false;
}

// ============================================================
// File ops
// ============================================================

bool ZShellIo::copyFile(const QUrl& source, const QUrl& target, bool overwrite) const {

	if (!source.isLocalFile()) {
		qWarning() << "ZShellIo::copyFile: source"
		           << source
		           << "is not a local file";
		return false;
	}

	if (!target.isLocalFile()) {
		qWarning() << "ZShellIo::copyFile: target"
		           << target
		           << "is not a local file";
		return false;
	}

	if (overwrite) {
		QFile::remove(target.toLocalFile());
	}

	return QFile::copy(
		source.toLocalFile(),
		target.toLocalFile()
		);
}

bool ZShellIo::deleteFile(const QUrl& path) const {

	if (!path.isLocalFile()) {
		qWarning() << "ZShellIo::deleteFile: path"
		           << path
		           << "is not a local file";
		return false;
	}

	return QFile::remove(path.toLocalFile());
}

QString ZShellIo::toLocalFile(const QUrl& url) const {

	if (!url.isLocalFile()) {
		qWarning() << "ZShellIo::toLocalFile: given url is not a local file"
		           << url;
		return QString();
	}

	return url.toLocalFile();
}

} // namespace ZShell
