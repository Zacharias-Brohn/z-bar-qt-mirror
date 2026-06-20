#include "strokecanvasitem.hpp"
#include "strokecanvasrenderer.hpp"
#include <qnamespace.h>

namespace ZShell::internal {

StrokeCanvasItem::StrokeCanvasItem(QQuickItem *parent) : QCanvasPainterItem(parent) {
	setFillColor(Qt::transparent);
	setAlphaBlending(true);
}

QCanvasPainterItemRenderer *StrokeCanvasItem::createItemRenderer() const {
	return new StrokeCanvasRenderer;
}

static bool shouldAddPoint(
	const QVector<QPointF> &points,
	const QPointF &p,
	qreal minDistance)
{
	if (points.isEmpty())
		return true;

	const QPointF delta = p - points.last();

	return QPointF::dotProduct(delta, delta)
	       >= minDistance * minDistance;
}

void StrokeCanvasItem::setPenColor(const QColor &color) {
	if (m_penColor == color)
		return;

	m_penColor = color;
	update();

	emit penColorChanged();
}

void StrokeCanvasItem::setHoverVisible(bool visible) {
	if (m_hoverVisible == visible)
		return;

	m_hoverVisible = visible;
	update();

	emit hoverVisibleChanged();
}

void StrokeCanvasItem::setHoverPoint(const QPointF &point) {
	if (m_hoverPoint == point)
		return;

	m_hoverPoint = point;
	update();

	emit hoverPointChanged();
}

void StrokeCanvasItem::showHover(qreal x, qreal y) {
	m_hoverPoint = {x, y};
	m_hoverVisible = true;
	update();

	emit hoverPointChanged();
	emit hoverVisibleChanged();
}

void StrokeCanvasItem::hideHover() {
	if (!m_hoverVisible)
		return;

	m_hoverVisible = false;
	update();

	emit hoverVisibleChanged();
}

void StrokeCanvasItem::setPenWidth(float width) {
	if (qFuzzyCompare(m_penWidth, width))
		return;

	m_penWidth = width;
	update();

	emit penWidthChanged();
}

void StrokeCanvasItem::beginStroke(qreal x, qreal y) {
	m_currentStroke.points.clear();
	m_currentStroke.points.append({x, y});

	m_currentStroke.color = m_penColor;
	m_currentStroke.width = m_penWidth;

	update();
}

void StrokeCanvasItem::appendPoint(qreal x, qreal y) {
	const QPointF incoming{x, y};

	if (!shouldAddPoint(m_currentStroke.points, incoming, 2.0))
		return;

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

		const qreal t = std::clamp((dist - minDist) / (maxDist - minDist), 0.0, 1.0);
		const qreal alpha = minAlpha + t * (maxAlpha - minAlpha);

		smoothed = last * (1.0 - alpha) + incoming * alpha;
	}

	m_currentStroke.points.append(smoothed);
	update();
}

void StrokeCanvasItem::endStroke() {
	if (m_currentStroke.points.isEmpty())
		return;

	m_strokes.append(m_currentStroke);
	m_currentStroke.points.clear();

	update();
}

void StrokeCanvasItem::clear() {
	m_strokes.clear();
	m_currentStroke.points.clear();

	update();
}

};
