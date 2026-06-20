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

	painter->beginPath();
	painter->moveTo(points[0]);

	for (int i = 1; i < points.size() - 1; ++i) {
		QPointF mid = (points[i] + points [i + 1]) / 2;
		painter->quadraticCurveTo(points[i], mid);
	}
	painter->lineTo(points.last());

	painter->stroke();
}

void StrokeCanvasRenderer::synchronizeData(QCanvasPainterItem *item) {
	auto *canvas = static_cast<StrokeCanvasItem *>(item);

	m_penColor = canvas->m_penColor;
	m_penWidth = canvas->m_penWidth;

	m_strokes = canvas->m_strokes;
	m_currentStroke = canvas->m_currentStroke;
}

void StrokeCanvasRenderer::paint(QCanvasPainter *painter) {
	painter->clearRect(0, 0, width(), height());

	for (const auto &stroke : m_strokes)
		drawStroke(painter, stroke.points, stroke.color, stroke.width);

	drawStroke(
		painter,
		m_currentStroke.points,
		m_currentStroke.color,
		m_currentStroke.width
		);
}

};
