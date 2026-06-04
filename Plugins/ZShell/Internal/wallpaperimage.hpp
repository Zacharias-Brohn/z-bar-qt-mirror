#pragma once

#include <QQuickItem>
#include <QImage>
#include <QUrl>
#include <QSGTexture>
#include <QFutureWatcher>
#include <QtQml/qqml.h>

namespace ZShell::Internal {

class WallpaperImage : public QQuickItem {
Q_OBJECT
QML_NAMED_ELEMENT(WallpaperImage)
Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
Q_PROPERTY(QSize screenResolution READ screenResolution WRITE setScreenResolution NOTIFY screenResolutionChanged)
Q_PROPERTY(qreal zoom READ zoom WRITE setZoom NOTIFY zoomChanged)

Q_PROPERTY(qreal cropX READ cropX WRITE setCropX NOTIFY cropXChanged)
Q_PROPERTY(qreal cropY READ cropY WRITE setCropY NOTIFY cropYChanged)
Q_PROPERTY(qreal cropWidth READ cropWidth WRITE setCropWidth NOTIFY cropWidthChanged)
Q_PROPERTY(qreal cropHeight READ cropHeight WRITE setCropHeight NOTIFY cropHeightChanged)

public:
explicit WallpaperImage(QQuickItem *parent = nullptr);
~WallpaperImage() override;

QUrl source() const {
	return m_source;
}
void setSource(const QUrl &source);

QSize screenResolution() const {
	return m_screenResolution;
}
void setScreenResolution(const QSize &screenResolution);

qreal zoom() const {
	return m_zoom;
}
void setZoom(qreal zoom);

qreal cropX() const {
	return m_cropX;
}
void setCropX(qreal x);

qreal cropY() const {
	return m_cropY;
}
void setCropY(qreal y);

qreal cropWidth() const {
	return m_cropWidth;
}
void setCropWidth(qreal w);

qreal cropHeight() const {
	return m_cropHeight;
}
void setCropHeight(qreal h);

protected:
QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *updatePaintNodeData) override;

signals:
void sourceChanged();
void screenResolutionChanged();
void zoomChanged();
void cropXChanged();
void cropYChanged();
void cropWidthChanged();
void cropHeightChanged();

private:
void loadImage();
void handleImageLoaded();
QString getCacheFilePath() const;

QUrl m_source;
QSize m_screenResolution;
qreal m_zoom = 1.0;

qreal m_cropX = 0.0;
qreal m_cropY = 0.0;
qreal m_cropWidth = 1.0;
qreal m_cropHeight = 1.0;

QImage m_image;
QSGTexture *m_texture = nullptr;
bool m_textureDirty = false;
QFutureWatcher<QImage> m_imageWatcher;
};

} // namespace ZShell::internal
