#pragma once

#include <QCanvasPainterItemRenderer>
#include <qcontainerfwd.h>
#include "stroke.hpp"

namespace ZShell::internal {

class StrokeCanvasRenderer final : public QCanvasPainterItemRenderer {
	public:
	void synchronizeData(QCanvasPainterItem* item) override;
	void paint(QCanvasPainter* painter) override;

	private:
	QColor m_penColor;
	qreal m_penWidth = 4.0;
	bool m_hoverVisible = false;
	QPointF m_hoverPoint;
	bool m_isDrawing = false;

	QVector<Stroke> m_strokes;
	Stroke m_currentStroke;
	QVector<int> m_pendingGroupRemovals;
};

}; // namespace ZShell::internal
