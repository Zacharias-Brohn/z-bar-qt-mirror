#include "writefile.hpp"

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QCryptographicHash>
#include <QtCore/QSaveFile>
#include <QtGui/QImageReader>
#include <QtQuick/qquickimageprovider.h>
#include <QtQuick/qquickitemgrabresult.h>
#include <QtQuick/qquickwindow.h>

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFutureWatcher>
#include <QImage>
#include <QJSValue>
#include <QQmlEngine>
#include <QSize>
#include <QVariant>

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
			const auto future = QtConcurrent::run([grabResult, scaledRect, path]() {
				QImage image = grabResult->image();

				if (scaledRect.isValid()) {
					image = image.copy(scaledRect);
				}

				const QString file = path.toLocalFile();
				const QString parent = QFileInfo(file).absolutePath();

				QDir().mkpath(parent);

				QSaveFile out(file);
				if (!out.open(QIODevice::WriteOnly)) {
					return false;
				}

				if (!image.save(&out, "PNG")) {
					return false;
				}

				return out.commit();
			});

			auto* watcher = new QFutureWatcher<bool>(this);
			auto* engine = qmlEngine(this);

			QObject::connect(watcher, &QFutureWatcher<bool>::finished, this, [=]() {
				if (watcher->result()) {
					if (onSaved.isCallable() && engine) {
						onSaved.call({
							engine->toScriptValue(path.toLocalFile()),
							engine->toScriptValue(path)
						});
					}
				} else {
					qWarning() << "ZShellIo::saveItem: failed to save" << path;
					if (onFailed.isCallable() && engine) {
						onFailed.call({
							engine->toScriptValue(path)
						});
					}
				}
				watcher->deleteLater();
			});

			watcher->setFuture(future);
		}
		);
}

// ============================================================
// cacheImage
// ============================================================

void ZShellIo::cacheImage(const QUrl& source, const QString& cacheDir) {
	this->cacheImage(source, cacheDir, QJSValue(), QJSValue());
}

void ZShellIo::cacheImage(const QUrl& source, const QString& cacheDir, QJSValue onSaved) {
	this->cacheImage(source, cacheDir, onSaved, QJSValue());
}

void ZShellIo::cacheImage(
	const QUrl& source,
	const QString& cacheDir,
	QJSValue onSaved,
	QJSValue onFailed
	) {
	if (cacheDir.isEmpty()) {
		qWarning() << "ZShellIo::cacheImage: cacheDir is empty";
		return;
	}

	QImage image;
	if (!loadSourceImage(source, image)) {
		qWarning() << "ZShellIo::cacheImage: failed to load source image" << source;
		auto* engine = qmlEngine(this);
		if (onFailed.isCallable() && engine) {
			onFailed.call({
					engine->toScriptValue(source),
					engine->toScriptValue(cacheDir)
				});
		}
		return;
	}

	const auto future = QtConcurrent::run([image, cacheDir]() -> QString {
			if (image.isNull()) {
				return QString();
			}

			const QImage normalized = image.convertToFormat(QImage::Format_RGBA8888);

			const QByteArray bytes(
				reinterpret_cast<const char*>(normalized.constBits()),
				qsizetype(normalized.sizeInBytes())
				);

			const QByteArray digest =
				QCryptographicHash::hash(bytes, QCryptographicHash::Sha256).toHex();

			QDir dir(cacheDir);
			if (!dir.exists() && !QDir().mkpath(cacheDir)) {
				return QString();
			}

			const QString finalPath = dir.filePath(QString::fromLatin1(digest) + ".png");

			if (QFile::exists(finalPath)) {
				return finalPath;
			}

			QSaveFile out(finalPath);
			if (!out.open(QIODevice::WriteOnly)) {
				return QString();
			}

			if (!normalized.save(&out, "PNG")) {
				return QString();
			}

			if (!out.commit()) {
				return QString();
			}

			return finalPath;
		});

	auto* watcher = new QFutureWatcher<QString>(this);
	auto* engine = qmlEngine(this);

	QObject::connect(watcher, &QFutureWatcher<QString>::finished, this, [=]() {
			const QString finalPath = watcher->result();

			if (!finalPath.isEmpty()) {
				if (onSaved.isCallable() && engine) {
					onSaved.call({
						engine->toScriptValue(finalPath),
						engine->toScriptValue(QUrl::fromLocalFile(finalPath))
					});
				}
			} else {
				qWarning() << "ZShellIo::cacheImage: failed to cache" << source;
				if (onFailed.isCallable() && engine) {
					onFailed.call({
						engine->toScriptValue(source),
						engine->toScriptValue(cacheDir)
					});
				}
			}

			watcher->deleteLater();
		});

	watcher->setFuture(future);
}

// ============================================================
// loadSourceImage
// ============================================================

bool ZShellIo::loadSourceImage(const QUrl& source, QImage& image) const {
	image = QImage();

	if (source.isLocalFile()) {
		QImageReader reader(source.toLocalFile());
		reader.setAutoTransform(true);
		image = reader.read();
		return !image.isNull();
	}

	if (source.scheme() == "image") {
		auto* engine = qmlEngine(const_cast<ZShellIo*>(this));
		if (!engine) {
			qWarning() << "ZShellIo::loadSourceImage: no QQmlEngine";
			return false;
		}

		const QString providerId = source.host();

		const QString imageId =
			source.path().startsWith('/')
		? source.path().mid(1)
		: source.path();

		auto* providerBase = engine->imageProvider(providerId);
		if (!providerBase) {
			qWarning() << "ZShellIo::loadSourceImage: provider not found"
			           << providerId;
			return false;
		}

		auto* provider = dynamic_cast<QQuickImageProvider*>(providerBase);
		if (!provider) {
			qWarning() << "ZShellIo::loadSourceImage: provider is not a QQuickImageProvider"
			           << providerId;
			return false;
		}

		QSize size;

		switch (provider->imageType()) {
		case QQuickImageProvider::Image:
			image = provider->requestImage(imageId, &size, QSize());
			break;

		case QQuickImageProvider::Pixmap:
			image = provider->requestPixmap(imageId, &size, QSize()).toImage();
			break;

		default:
			qWarning() << "ZShellIo::loadSourceImage: unsupported provider type"
			           << providerId;
			return false;
		}

		return !image.isNull();
	}

	qWarning() << "ZShellIo::loadSourceImage: unsupported source" << source;
	return false;
}

// ============================================================
// File ops
// ============================================================

bool ZShellIo::copyFile(const QUrl& source, const QUrl& target, bool overwrite) const {
	if (!source.isLocalFile()) {
		qWarning() << "ZShellIo::copyFile: source" << source << "is not a local file";
		return false;
	}
	if (!target.isLocalFile()) {
		qWarning() << "ZShellIo::copyFile: target" << target << "is not a local file";
		return false;
	}

	if (overwrite) {
		QFile::remove(target.toLocalFile());
	}

	return QFile::copy(source.toLocalFile(), target.toLocalFile());
}

bool ZShellIo::deleteFile(const QUrl& path) const {
	if (!path.isLocalFile()) {
		qWarning() << "ZShellIo::deleteFile: path" << path << "is not a local file";
		return false;
	}

	return QFile::remove(path.toLocalFile());
}

QString ZShellIo::toLocalFile(const QUrl& url) const {
	if (!url.isLocalFile()) {
		qWarning() << "ZShellIo::toLocalFile: given url is not a local file" << url;
		return QString();
	}

	return url.toLocalFile();
}

} // namespace ZShell
