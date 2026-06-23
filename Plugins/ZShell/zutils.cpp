#include "zutils.hpp"

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtQuick/qquickitemgrabresult.h>
#include <QtQuick/qquickwindow.h>
#include <qdir.h>
#include <qfileinfo.h>
#include <qfuturewatcher.h>
#include <qloggingcategory.h>
#include <qqmlengine.h>

Q_LOGGING_CATEGORY(lcZUtils, "ZShell.cutils", QtInfoMsg)

namespace ZShell {

void ZUtils::saveItem(QQuickItem* target, const QUrl& path) {
	this->saveItem(target, path, QRect(), QJSValue(), QJSValue());
}

void ZUtils::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect) {
	this->saveItem(target, path, rect, QJSValue(), QJSValue());
}

void ZUtils::saveItem(QQuickItem* target, const QUrl& path, QJSValue onSaved) {
	this->saveItem(target, path, QRect(), onSaved, QJSValue());
}

void ZUtils::saveItem(QQuickItem* target, const QUrl& path, QJSValue onSaved, QJSValue onFailed) {
	this->saveItem(target, path, QRect(), onSaved, onFailed);
}

void ZUtils::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect, QJSValue onSaved) {
	this->saveItem(target, path, rect, onSaved, QJSValue());
}

void ZUtils::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect, QJSValue onSaved, QJSValue onFailed) {
	if (!target) {
		qCWarning(lcZUtils) << "saveItem: a target is required";
		return;
	}

	if (!path.isLocalFile()) {
		qCWarning(lcZUtils) << "saveItem:" << path << "is not a local file";
		return;
	}

	if (!target->window()) {
		qCWarning(lcZUtils) << "saveItem: unable to save target" << target << "without a window";
		return;
	}

	auto scaledRect = rect;
	const qreal scale = target->window()->devicePixelRatio();
	if (rect.isValid() && !qFuzzyCompare(scale + 1.0, 2.0)) {
		scaledRect =
			QRectF(rect.left() * scale, rect.top() * scale, rect.width() * scale, rect.height() * scale).toRect();
	}

	const QSharedPointer<const QQuickItemGrabResult> grabResult = target->grabToImage();

	QObject::connect(grabResult.data(), &QQuickItemGrabResult::ready, this,
	                 [grabResult, scaledRect, path, onSaved, onFailed, this]() {
			const auto future = QtConcurrent::run([=]() {
				QImage image = grabResult->image();

				if (scaledRect.isValid()) {
					image = image.copy(scaledRect);
				}

				const QString file = path.toLocalFile();
				const QString parent = QFileInfo(file).absolutePath();
				return QDir().mkpath(parent) && image.save(file);
			});

			auto* watcher = new QFutureWatcher<bool>(this);
			auto* engine = qmlEngine(this);

			QObject::connect(watcher, &QFutureWatcher<bool>::finished, this, [=]() {
				if (watcher->result()) {
					if (onSaved.isCallable()) {
						QJSValueList args = { QJSValue(path.toLocalFile()) };
						if (engine) {
							args << engine->toScriptValue(QVariant::fromValue(path));
						}
						onSaved.call(args);
					}
				} else {
					qCWarning(lcZUtils) << "saveItem: failed to save" << path;
					if (onFailed.isCallable()) {
						if (engine) {
							onFailed.call({ engine->toScriptValue(QVariant::fromValue(path)) });
						} else {
							onFailed.call();
						}
					}
				}
				watcher->deleteLater();
			});
			watcher->setFuture(future);
		});
}

bool ZUtils::copyFile(const QUrl& source, const QUrl& target, bool overwrite) {
	if (!source.isLocalFile()) {
		qCWarning(lcZUtils) << "copyFile: source" << source << "is not a local file";
		return false;
	}
	if (!target.isLocalFile()) {
		qCWarning(lcZUtils) << "copyFile: target" << target << "is not a local file";
		return false;
	}

	if (overwrite && QFile::exists(target.toLocalFile())) {
		if (!QFile::remove(target.toLocalFile())) {
			qCWarning(lcZUtils) << "copyFile: overwrite was specified but failed to remove" << target.toLocalFile();
			return false;
		}
	}

	return QFile::copy(source.toLocalFile(), target.toLocalFile());
}

bool ZUtils::deleteFile(const QUrl& path) {
	if (!path.isLocalFile()) {
		qCWarning(lcZUtils) << "deleteFile: path" << path << "is not a local file";
		return false;
	}

	return QFile::remove(path.toLocalFile());
}

QString ZUtils::toLocalFile(const QUrl& url) {
	if (!url.isLocalFile()) {
		qCWarning(lcZUtils) << "toLocalFile: given url is not a local file" << url;
		return QString();
	}

	return url.toLocalFile();
}

qreal ZUtils::clamp(qreal value, qreal min, qreal max) {
	return qBound(min, value, max);
}

} // namespace ZShell
