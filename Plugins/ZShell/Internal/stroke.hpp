#pragma once

#include <QColor>
#include <QPointF>
#include <QVector>

namespace ZShell::internal {

struct Stroke {
	QVector<QPointF> points;
	QColor color;
	float width;
};

};
