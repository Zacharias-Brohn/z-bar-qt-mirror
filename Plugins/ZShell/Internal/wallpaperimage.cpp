#include "wallpaperimage.hpp"

#include <QStandardPaths>
#include <QCryptographicHash>
#include <QDir>
#include <QFileInfo>
#include <QtConcurrent>
#include <QSGImageNode>
#include <QQuickWindow>

namespace ZShell::internal {

WallpaperImage::WallpaperImage(QQuickItem *parent)
	: QQuickItem(parent)
{
	setFlag(ItemHasContents, true);
	connect(&m_imageWatcher, &QFutureWatcher<QImage>::finished, this, &WallpaperImage::handleImageLoaded);
}

WallpaperImage::~WallpaperImage() {
	if (m_texture) delete m_texture;
}

void WallpaperImage::setSource(const QUrl &source) {
	if (m_source == source) return;
	m_source = source;
	emit sourceChanged();
	loadImage();
}

void WallpaperImage::setScreenResolution(const QSize &screenResolution) {
	if (m_screenResolution == screenResolution) return;
	m_screenResolution = screenResolution;
	emit screenResolutionChanged();
	loadImage();
}

void WallpaperImage::setZoom(qreal zoom) {
	if (qFuzzyCompare(m_zoom, zoom)) return;
	m_zoom = zoom;
	emit zoomChanged();
	update();
}

void WallpaperImage::setCropX(qreal x) {
	if (qFuzzyCompare(m_cropX, x)) return;
	m_cropX = x;
	emit cropXChanged();
	update();
}

void WallpaperImage::setCropY(qreal y) {
	if (qFuzzyCompare(m_cropY, y)) return;
	m_cropY = y;
	emit cropYChanged();
	update();
}

void WallpaperImage::setCropWidth(qreal w) {
    if (w <= 0.0) w = 1.0;
    if (qFuzzyCompare(m_cropWidth, w)) return;
    m_cropWidth = w;
    emit cropWidthChanged();
    update();
}

void WallpaperImage::setCropHeight(qreal h) {
    if (h <= 0.0) h = 1.0;
    if (qFuzzyCompare(m_cropHeight, h)) return;
    m_cropHeight = h;
    emit cropHeightChanged();
    update();
}

QString WallpaperImage::getCacheFilePath() const {
	if (m_source.isEmpty() || m_screenResolution.isEmpty()) return QString();

    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + "/zshell/imagecache";
	QDir().mkpath(cachePath);

	// Hash the source URL + resolution
	QString id = m_source.toString() + "_" + QString::number(m_screenResolution.width()) + "x" + QString::number(m_screenResolution.height());
	QByteArray hash = QCryptographicHash::hash(id.toUtf8(), QCryptographicHash::Md5).toHex();

	return cachePath + "/" + hash + ".png";
}

void WallpaperImage::loadImage() {
    if (m_source.isEmpty()) return;

    QString cacheFile = getCacheFilePath();
    QString sourceFile = m_source.isLocalFile() ? m_source.toLocalFile() : m_source.toString();
    
    // Qt resource path correction if passed as a standard URL string
    if (sourceFile.startsWith("qrc:/")) {
        sourceFile = sourceFile.mid(3); // Converts "qrc:/" to ":/"
    }
    
    QSize targetRes = m_screenResolution;

    // Run off the main thread to avoid blocking the UI
    QFuture<QImage> future = QtConcurrent::run([sourceFile, cacheFile, targetRes]() -> QImage {
        if (!targetRes.isEmpty() && !cacheFile.isEmpty() && QFileInfo::exists(cacheFile)) {
            QImage cached(cacheFile);
            if (!cached.isNull()) return cached;
        }

        QImage original(sourceFile);
        if (original.isNull()) return QImage();

        if (targetRes.isEmpty()) {
            // Screen resolution not set yet by QML, return the unscaled original for now to prevent a black screen
            return original;
        }

        // Check if original is strictly larger than screen resolution
        if (original.width() > targetRes.width() || original.height() > targetRes.height()) {
            QImage scaled = original.scaled(targetRes, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
            if (!cacheFile.isEmpty()) scaled.save(cacheFile, "PNG");
            return scaled;
        }

        // Otherwise just cache and return the original
        if (!cacheFile.isEmpty()) original.save(cacheFile, "PNG");
        return original;
    });

    m_imageWatcher.setFuture(future);
}

void WallpaperImage::handleImageLoaded() {
	m_image = m_imageWatcher.result();
	m_textureDirty = true;
	update(); // Request redraw
}

QSGNode *WallpaperImage::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
	auto *node = static_cast<QSGImageNode *>(oldNode);

	if (m_image.isNull()) {
		delete node;
		return nullptr;
	}

	if (!node) {
		node = window()->createImageNode();
	}

	if (m_textureDirty) {
		if (m_texture) delete m_texture;
        m_texture = window()->createTextureFromImage(m_image, QQuickWindow::TextureHasAlphaChannel);
		m_textureDirty = false;
	}

	if (m_texture) {
		node->setTexture(m_texture);
		node->setRect(boundingRect());
		node->setFiltering(QSGTexture::Linear);

        qreal cW = m_cropWidth / m_zoom;
        qreal cH = m_cropHeight / m_zoom;

        QRectF reqRect(
            m_cropX * m_texture->textureSize().width(),
            m_cropY * m_texture->textureSize().height(),
            cW * m_texture->textureSize().width(),
            cH * m_texture->textureSize().height()
        );

        QRectF bounds = boundingRect();
        if (bounds.isEmpty() || reqRect.isEmpty()) return node;

        qreal targetRatio = bounds.width() / bounds.height();
        qreal reqRatio = reqRect.width() / reqRect.height();

        QRectF sourceRect = reqRect;

        // Force 'PreserveAspectCrop' behavior on the requested region
        if (reqRatio > targetRatio) {
            // Requested region is too wide, center-crop the sides
            qreal newWidth = reqRect.height() * targetRatio;
            qreal xOffset = (reqRect.width() - newWidth) / 2.0;
            sourceRect.setX(reqRect.x() + xOffset);
            sourceRect.setWidth(newWidth);
        } else if (reqRatio < targetRatio) {
            // Requested region is too tall, center-crop the top/bottom
            qreal newHeight = reqRect.width() / targetRatio;
            qreal yOffset = (reqRect.height() - newHeight) / 2.0;
            sourceRect.setY(reqRect.y() + yOffset);
            sourceRect.setHeight(newHeight);
        }

        node->setSourceRect(sourceRect);
	}

	return node;
}

} // namespace ZShell::internal
