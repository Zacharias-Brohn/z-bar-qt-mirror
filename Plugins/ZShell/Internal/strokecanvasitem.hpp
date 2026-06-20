#pragma once

#include <QCanvasPainterItem>
#include <QColor>
#include <QPointF>
#include <QVector>
#include <qcolor.h>
#include <qcontainerfwd.h>
#include "stroke.hpp"

namespace ZShell::internal {

class StrokeCanvasRenderer;

class StrokeCanvasItem : public QCanvasPainterItem {
Q_OBJECT

QML_NAMED_ELEMENT(StrokeCanvas)

Q_PROPERTY(QColor penColor READ penColor WRITE setPenColor NOTIFY penColorChanged)
Q_PROPERTY(bool hoverVisible READ hoverVisible WRITE setHoverVisible NOTIFY hoverVisibleChanged)
Q_PROPERTY(QPointF hoverPoint READ hoverPoint WRITE setHoverPoint NOTIFY hoverPointChanged)
Q_PROPERTY(qreal penWidth READ penWidth WRITE setPenWidth NOTIFY penWidthChanged)

public:
explicit StrokeCanvasItem(QQuickItem *parent = nullptr);

[[nodiscard]] bool hoverVisible() const {
	return m_hoverVisible;
}
[[nodiscard]] QPointF hoverPoint() const {
	return m_hoverPoint;
}

void setHoverVisible(bool visible);
void setHoverPoint(const QPointF &point);

Q_INVOKABLE void showHover(qreal x, qreal y);
Q_INVOKABLE void hideHover();

[[nodiscard]] QColor penColor() const {
	return m_penColor;
}
[[nodiscard]] float penWidth() const {
	return m_penWidth;
}

void setPenColor(const QColor &color);
void setPenWidth(float width);

Q_INVOKABLE void clear();

Q_INVOKABLE void beginStroke(qreal x, qreal y);
Q_INVOKABLE void appendPoint(qreal x, qreal y);
Q_INVOKABLE void endStroke();

signals:
void penColorChanged();
void penWidthChanged();
void hoverVisibleChanged();
void hoverPointChanged();

protected:
[[nodiscard]] QCanvasPainterItemRenderer *createItemRenderer() const override;

private:
friend class StrokeCanvasRenderer;

bool m_hoverVisible = false;
QPointF m_hoverPoint;
QColor m_penColor = Qt::white;
float m_penWidth = 4.f;

int m_nextGroupId = 0;
QVector<Stroke> m_strokes;
Stroke m_currentStroke;
};

};
