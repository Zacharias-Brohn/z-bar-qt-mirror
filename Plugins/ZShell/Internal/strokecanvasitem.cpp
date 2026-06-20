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
	if (shouldAddPoint(m_currentStroke.points, {x, y}, 2.0))
		m_currentStroke.points.append({x, y});

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
