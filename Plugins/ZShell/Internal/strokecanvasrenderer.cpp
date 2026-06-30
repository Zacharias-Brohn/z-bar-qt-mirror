#include "strokecanvasrenderer.hpp"
#include "strokecanvasitem.hpp"
#include <qcolor.h>

namespace ZShell::internal {

static void drawStroke(
	QCanvasPainter* painter,
	const QVector<QPointF>& points,
	const QColor& color,
	qreal width) {
	if (points.isEmpty()) return;

	painter->setStrokeStyle(color);
	painter->setFillStyle(color);
	painter->setLineWidth(width);
	painter->setLineCap(QCanvasPainter::LineCap::Round);
	painter->setLineJoin(QCanvasPainter::LineJoin::Round);

	if (points.size() == 1) {
		painter->beginPath();
		painter->circle(points.front(), width * 0.5);
		painter->fill();
		return;
	}

	auto catmullToBezier = [](const QPointF& p0,
							  const QPointF& p1,
							  const QPointF& p2,
							  const QPointF& p3,
							  qreal tension,
							  QPointF& cp1,
							  QPointF& cp2) {
		cp1 = p1 + (p2 - p0) * tension / 3.0;
		cp2 = p2 - (p3 - p1) * tension / 3.0;
	};

	const qreal tension = 0.5; // increase toward 1.0 for tighter curves

	painter->beginPath();
	painter->moveTo(points[0]);

	for (int i = 0; i < points.size() - 1; ++i) {
		const QPointF& p0 = points[qMax(i - 1, 0)];
		const QPointF& p1 = points[i];
		const QPointF& p2 = points[i + 1];
		const QPointF& p3 = points[qMin(i + 2, points.size() - 1)];

		QPointF cp1, cp2;
		catmullToBezier(p0, p1, p2, p3, tension, cp1, cp2);
		painter->bezierCurveTo(cp1, cp2, p2);
	}

	painter->stroke();
}

static void drawHoverCursor(
	QCanvasPainter* painter,
	const QPointF& point,
	qreal penWidth,
	QColor penColor,
	bool isDrawing) {
	const qreal radius = penWidth * 0.5;

	if (isDrawing) {
		painter->setFillStyle(penColor);
		painter->beginPath();
		painter->circle(point, radius);
		painter->fill();
	}

	const qreal lineWidth = 1.5;
	const qreal crosshairSize = 6.0;
	const bool useDashes = penWidth > 10.0;

	auto drawOutline = [&](const QColor& color, qreal width) {
		painter->setStrokeStyle(color);
		painter->setLineWidth(width);
		painter->setLineCap(QCanvasPainter::LineCap::Round);


		if (useDashes) {
			const int dashCount = 12;
			const qreal fullAngle = 2.0 * M_PI;
			const qreal dashAngle = fullAngle / dashCount * 0.5;
			const qreal gapAngle = fullAngle / dashCount * 0.5;

			qreal angle = 0.0;
			for (int i = 0; i < dashCount; ++i) {
				painter->beginPath();
				painter->arc(
					point,
					radius,
					angle,
					angle + dashAngle,
					QCanvasPainter::PathWinding::ClockWise,
					QCanvasPainter::PathConnection::NotConnected);
				painter->stroke();
				angle += dashAngle + gapAngle;
			}
		} else {
			painter->beginPath();
			painter->circle(point, radius);
			painter->stroke();
		}
	};

	auto drawCrosshair = [&](const QColor& color, qreal width) {
		painter->setStrokeStyle(color);
		painter->setLineWidth(width);
		painter->setLineCap(QCanvasPainter::LineCap::Round);

		const qreal inner = radius + 3.0;
		const qreal outer = radius + 3.0 + crosshairSize;

		painter->beginPath();
		painter->moveTo(point + QPointF(0, -outer));
		painter->lineTo(point + QPointF(0, -inner));
		painter->moveTo(point + QPointF(0, outer));
		painter->lineTo(point + QPointF(0, inner));
		painter->moveTo(point + QPointF(-outer, 0));
		painter->lineTo(point + QPointF(-inner, 0));
		painter->moveTo(point + QPointF(outer, 0));
		painter->lineTo(point + QPointF(inner, 0));
		painter->stroke();
	};

	drawOutline(QColor(0, 0, 0, 160), lineWidth + 1.0);
	drawCrosshair(QColor(0, 0, 0, 160), lineWidth + 1.0);

	drawOutline(QColor(255, 255, 255, 220), lineWidth);
	drawCrosshair(QColor(255, 255, 255, 220), lineWidth);
}

void StrokeCanvasRenderer::synchronizeData(QCanvasPainterItem* item) {
	auto* canvas = static_cast<StrokeCanvasItem*>(item);

	m_penColor = canvas->m_penColor;
	m_penWidth = canvas->m_penWidth;

	while (m_strokes.size() < canvas->m_strokes.size())
		m_strokes.append(canvas->m_strokes[m_strokes.size()]);

	if (canvas->m_strokes.isEmpty() && !m_strokes.isEmpty()) {
		for (const auto& stroke : m_strokes)
			if (stroke.groupId >= 0)
				m_pendingGroupRemovals.append(stroke.groupId);
		m_strokes.clear();
	}

	m_currentStroke = canvas->m_currentStroke;

	m_hoverVisible = canvas->m_hoverVisible;
	m_hoverPoint = canvas->m_hoverPoint;
	m_isDrawing = canvas->m_isDrawing;
}

void StrokeCanvasRenderer::paint(QCanvasPainter* painter) {
	for (int id : m_pendingGroupRemovals)
		painter->removePathGroup(id);
	m_pendingGroupRemovals.clear();

	painter->clearRect(0, 0, width(), height());

	for (const auto& stroke : m_strokes) {
		painter->setStrokeStyle(stroke.color);
		painter->setFillStyle(stroke.color);
		painter->setLineWidth(stroke.width);
		painter->setLineCap(QCanvasPainter::LineCap::Round);
		painter->setLineJoin(QCanvasPainter::LineJoin::Round);

		if (stroke.isSinglePoint) {
			painter->fill(stroke.path, stroke.groupId);
		} else {
			painter->stroke(stroke.path, stroke.groupId);
		}
	}

	drawStroke(
		painter,
		m_currentStroke.points,
		m_currentStroke.color,
		m_currentStroke.width);

	if (m_hoverVisible)
		drawHoverCursor(
			painter, m_hoverPoint, m_penWidth, m_penColor, m_isDrawing);
}

}; // namespace ZShell::internal
