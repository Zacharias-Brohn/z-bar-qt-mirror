#include "strokecanvasitem.hpp"
#include "strokecanvasrenderer.hpp"
#include <qcanvaspainter.h>
#include <qnamespace.h>
#include <qpoint.h>

namespace ZShell::internal {

StrokeCanvasItem::StrokeCanvasItem(QQuickItem* parent)
	: QCanvasPainterItem(parent) {
	setFillColor(Qt::transparent);
	setAlphaBlending(true);
}

QCanvasPainterItemRenderer* StrokeCanvasItem::createItemRenderer() const {
	return new StrokeCanvasRenderer;
}

static bool shouldAddPoint(
	const QVector<QPointF>& points, const QPointF& p, qreal minDistance) {
	if (points.isEmpty()) return true;

	const QPointF delta = p - points.last();

	return QPointF::dotProduct(delta, delta) >= minDistance * minDistance;
}

static QCanvasPath buildStrokePath(const QVector<QPointF>& points, qreal width) {
	QCanvasPath path;

	if (points.size() == 1) {
		path.circle(points[0], width * 0.5);
		return path;
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

	const qreal tension = 0.5;
	path.moveTo(points[0]);

	for (int i = 0; i < points.size() - 1; ++i) {
		const QPointF& p0 = points[qMax(i - 1, 0)];
		const QPointF& p1 = points[i];
		const QPointF& p2 = points[i + 1];
		const QPointF& p3 = points[qMin(i + 2, points.size() - 1)];

		QPointF cp1, cp2;
		catmullToBezier(p0, p1, p2, p3, tension, cp1, cp2);
		path.bezierCurveTo(cp1, cp2, p2);
	}

	return path;
}

void StrokeCanvasItem::setPenColor(const QColor& color) {
	if (m_penColor == color) return;

	m_penColor = color;
	update();

	emit penColorChanged();
}

void StrokeCanvasItem::setHoverVisible(bool visible) {
	if (m_hoverVisible == visible) return;

	m_hoverVisible = visible;
	update();

	emit hoverVisibleChanged();
}

void StrokeCanvasItem::setHoverPoint(const QPointF& point) {
	if (m_hoverPoint == point) return;

	m_hoverPoint = point;
	update();

	emit hoverPointChanged();
}

void StrokeCanvasItem::showHover(qreal x, qreal y) {
	const QPointF newPoint{x, y};
	const bool pointChanged = (m_hoverPoint != newPoint);
	const bool visibleChanged = !m_hoverVisible;


	if (pointChanged || visibleChanged) {
		m_hoverVisible = true;
		m_hoverPoint = newPoint;
		if (pointChanged) emit hoverPointChanged();
		if (visibleChanged) emit hoverVisibleChanged();
		update();
	}
}

void StrokeCanvasItem::hideHover() {
	if (!m_hoverVisible) return;

	m_hoverVisible = false;
	update();

	emit hoverVisibleChanged();
}

void StrokeCanvasItem::setPenWidth(qreal width) {
	if (qFuzzyCompare(m_penWidth, width)) return;

	m_penWidth = width;
	update();

	emit penWidthChanged();
}

void StrokeCanvasItem::beginStroke(qreal x, qreal y) {
	m_isDrawing = true;
	m_currentStroke.points.clear();
	m_currentStroke.points.append({x, y});

	m_currentStroke.color = m_penColor;
	m_currentStroke.width = m_penWidth;

	update();
}

void StrokeCanvasItem::appendPoint(qreal x, qreal y) {
	const QPointF incoming{x, y};

	if (!shouldAddPoint(m_currentStroke.points, incoming, 2.0)) return;

	QPointF smoothed;
	if (m_currentStroke.points.isEmpty()) {
		smoothed = incoming;
	} else {
		const QPointF last = m_currentStroke.points.last();
		const QPointF delta = incoming - last;
		const qreal dist = std::sqrt(QPointF::dotProduct(delta, delta));

		constexpr qreal minDist = 6.0;
		constexpr qreal maxDist = 20.0;
		constexpr qreal minAlpha = 0.1;
		constexpr qreal maxAlpha = 0.3;

		const qreal t =
			std::clamp((dist - minDist) / (maxDist - minDist), 0.0, 1.0);
		const qreal alpha = minAlpha + t * (maxAlpha - minAlpha);

		smoothed = last * (1.0 - alpha) + incoming * alpha;
	}

	m_currentStroke.points.append(smoothed);
	update();
}

void StrokeCanvasItem::endStroke() {
	m_isDrawing = false;
	if (m_currentStroke.points.isEmpty()) return;

	m_currentStroke.isSinglePoint = (m_currentStroke.points.size() == 1);
	m_currentStroke.path =
		buildStrokePath(m_currentStroke.points, m_currentStroke.width);
	m_currentStroke.groupId = m_nextGroupId++;
	m_currentStroke.points.clear();
	m_strokes.append(m_currentStroke);
	m_currentStroke = {};

	update();
}

void StrokeCanvasItem::clear() {
	m_strokes.clear();
	m_currentStroke = {};
	update();
}

}; // namespace ZShell::internal
