#include "strokecanvasrenderer.hpp"
#include "strokecanvasitem.hpp"

namespace ZShell::internal {

static void drawStroke(
	QCanvasPainter *painter,
	const QVector<QPointF> &points,
	const QColor &color,
	float width) {

	if (points.isEmpty())
		return;

	painter->setStrokeStyle(color);
	painter->setFillStyle(color);
	painter->setLineWidth(width);
	painter->setLineCap(QCanvasPainter::LineCap::Round);
	painter->setLineJoin(QCanvasPainter::LineJoin::Round);

	if (points.size() == 1) {
		painter->beginPath();
		painter->circle(points.front(), width * 0.5f);
		painter->fill();
		return;
	}

	auto catmullToBezier = [](
		const QPointF &p0, const QPointF &p1,
		const QPointF &p2, const QPointF &p3,
		float tension,
		QPointF &cp1, QPointF &cp2)
			       {
				       cp1 = p1 + (p2 - p0) * tension / 3.0f;
				       cp2 = p2 - (p3 - p1) * tension / 3.0f;
			       };

	const float tension = 0.5f; // increase toward 1.0 for tighter curves

	painter->beginPath();
	painter->moveTo(points[0]);

	for (int i = 0; i < points.size() - 1; ++i) {
		const QPointF &p0 = points[qMax(i - 1, 0)];
		const QPointF &p1 = points[i];
		const QPointF &p2 = points[i + 1];
		const QPointF &p3 = points[qMin(i + 2, points.size() - 1)];

		QPointF cp1, cp2;
		catmullToBezier(p0, p1, p2, p3, tension, cp1, cp2);
		painter->bezierCurveTo(cp1, cp2, p2);
	}

	painter->stroke();
}

static void drawDot(
	QCanvasPainter *painter,
	const QPointF &point,
	const QColor &color,
	float width)
{
	painter->setFillStyle(color);

	painter->beginPath();
	painter->circle(point, width * 0.5f);
	painter->fill();
}

void StrokeCanvasRenderer::synchronizeData(QCanvasPainterItem *item) {
	auto *canvas = static_cast<StrokeCanvasItem *>(item);

	m_penColor = canvas->m_penColor;
	m_penWidth = canvas->m_penWidth;

	// Only copy strokes the renderer hasn't seen yet
	while (m_strokes.size() < canvas->m_strokes.size())
		m_strokes.append(canvas->m_strokes[m_strokes.size()]);

	// Handle clear()
	if (canvas->m_strokes.isEmpty() && !m_strokes.isEmpty()) {
		for (const auto &stroke : m_strokes)
			if (stroke.groupId >= 0)
				m_pendingGroupRemovals.append(stroke.groupId);
		m_strokes.clear();
	}

	m_currentStroke = canvas->m_currentStroke;

	m_hoverVisible = canvas->m_hoverVisible;
	m_hoverPoint = canvas->m_hoverPoint;
}

void StrokeCanvasRenderer::paint(QCanvasPainter *painter) {
	for (int id : m_pendingGroupRemovals)
		painter->removePathGroup(id);
	m_pendingGroupRemovals.clear();

	painter->clearRect(0, 0, width(), height());

	for (const auto &stroke : m_strokes) {
		painter->setStrokeStyle(stroke.color);
		painter->setFillStyle(stroke.color);
		painter->setLineWidth(stroke.width);
		painter->setLineCap(QCanvasPainter::LineCap::Round);
		painter->setLineJoin(QCanvasPainter::LineJoin::Round);

		if (stroke.path.commandsSize() == 1) {
			painter->fill(stroke.path, stroke.groupId);
		} else {
			painter->stroke(stroke.path, stroke.groupId);
		}
	}

	drawStroke(painter, m_currentStroke.points, m_currentStroke.color, m_currentStroke.width);

	if (m_hoverVisible)
		drawDot(painter, m_hoverPoint, m_penColor, m_penWidth);
}

};
