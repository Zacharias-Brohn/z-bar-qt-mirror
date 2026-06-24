#pragma once

#include <QColor>
#include <QPointF>
#include <QVector>
#include <QCanvasPath>

namespace ZShell::internal {

struct Stroke {
	QVector<QPointF> points;
	QCanvasPath path;
	QColor color;
	float width;
	int groupId = -1;
	bool isSinglePoint = false;
};

};
