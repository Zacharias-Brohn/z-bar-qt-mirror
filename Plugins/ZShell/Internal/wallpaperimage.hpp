#pragma once

#include <QQuickItem>
#include <QImage>
#include <QUrl>
#include <QSGTexture>
#include <QFutureWatcher>
#include <QtQml/qqml.h>
#include <qtmetamacros.h>

namespace ZShell::internal {

class WallpaperImage : public QQuickItem {
	Q_OBJECT
	QML_NAMED_ELEMENT(WallpaperImage)
	Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
	Q_PROPERTY(
		QSize screenResolution READ screenResolution WRITE setScreenResolution
			NOTIFY screenResolutionChanged)
	Q_PROPERTY(qreal zoom READ zoom WRITE setZoom NOTIFY zoomChanged)
	Q_PROPERTY(Status status READ status NOTIFY statusChanged)

	Q_PROPERTY(qreal actualCropX READ actualCropX NOTIFY actualCropChanged)
	Q_PROPERTY(qreal actualCropY READ actualCropY NOTIFY actualCropChanged)
	Q_PROPERTY(
		qreal actualCropWidth READ actualCropWidth NOTIFY actualCropChanged)
	Q_PROPERTY(
		qreal actualCropHeight READ actualCropHeight NOTIFY actualCropChanged)

	Q_PROPERTY(qreal cropX READ cropX WRITE setCropX NOTIFY cropXChanged)
	Q_PROPERTY(qreal cropY READ cropY WRITE setCropY NOTIFY cropYChanged)
	Q_PROPERTY(
		qreal cropWidth READ cropWidth WRITE setCropWidth NOTIFY
			cropWidthChanged)
	Q_PROPERTY(
		qreal cropHeight READ cropHeight WRITE setCropHeight NOTIFY
			cropHeightChanged)

	public:
	explicit WallpaperImage(QQuickItem* parent = nullptr);
	~WallpaperImage() override;

	enum Status { Null, Ready, Loading, Error };
	Q_ENUM(Status)

	Status status() const { return m_status; }

	QUrl source() const { return m_source; }
	void setSource(const QUrl& source);

	QSize screenResolution() const { return m_screenResolution; }
	void setScreenResolution(const QSize& screenResolution);

	qreal zoom() const { return m_zoom; }
	void setZoom(qreal zoom);

	qreal actualCropX() const { return m_actualCropX; }

	qreal actualCropY() const { return m_actualCropY; }

	qreal actualCropWidth() const { return m_actualCropWidth; }

	qreal actualCropHeight() const { return m_actualCropHeight; }

	qreal cropX() const { return m_cropX; }
	void setCropX(qreal x);

	qreal cropY() const { return m_cropY; }
	void setCropY(qreal y);

	qreal cropWidth() const { return m_cropWidth; }
	void setCropWidth(qreal w);

	qreal cropHeight() const { return m_cropHeight; }
	void setCropHeight(qreal h);

	protected:
	QSGNode* updatePaintNode(
		QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData) override;

	signals:
	void sourceChanged();
	void screenResolutionChanged();
	void zoomChanged();
	void actualCropChanged();
	void cropXChanged();
	void cropYChanged();
	void cropWidthChanged();
	void cropHeightChanged();
	void statusChanged();

	private:
	void loadImage();
	void handleImageLoaded();
	QString getCacheFilePath() const;
	void setStatus(const Status s);

	Status m_status = Null;
	QUrl m_source;
	QSize m_screenResolution;
	qreal m_zoom = 1.0;

	qreal m_actualCropX = 0.0;
	qreal m_actualCropY = 0.0;
	qreal m_actualCropWidth = 1.0;
	qreal m_actualCropHeight = 1.0;

	qreal m_cropX = 0.0;
	qreal m_cropY = 0.0;
	qreal m_cropWidth = 1.0;
	qreal m_cropHeight = 1.0;

	QImage m_image;
	QSGTexture* m_texture = nullptr;
	bool m_textureDirty = false;
	QFutureWatcher<QImage> m_imageWatcher;
};

} // namespace ZShell::internal
