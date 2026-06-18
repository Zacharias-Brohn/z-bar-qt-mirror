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
Q_PROPERTY(qreal penWidth READ penWidth WRITE setPenWidth NOTIFY penWidthChanged)

public:
explicit StrokeCanvasItem(QQuickItem *parent = nullptr);

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

protected:
[[nodiscard]] QCanvasPainterItemRenderer *createItemRenderer() const override;

private:
friend class StrokeCanvasRenderer;

QColor m_penColor = Qt::white;
float m_penWidth = 4.f;

QVector<Stroke> m_strokes;
Stroke m_currentStroke;
};

};
