#include "blobgroup.hpp"
#include "blobinvertedrect.hpp"
#include "blobshape.hpp"

BlobGroup::BlobGroup(QObject* parent)
	: QObject(parent) {
}

BlobGroup::~BlobGroup() {
	for (auto* shape : std::as_const(m_shapes))
		shape->m_group = nullptr;
	if (m_invertedRect)
		static_cast<BlobShape*>(m_invertedRect)->m_group = nullptr;
}

void BlobGroup::setSmoothing(qreal s) {
	if (qFuzzyCompare(m_smoothing, s))
		return;
	m_smoothing = s;
	emit smoothingChanged();
	markDirty();
}

void BlobGroup::setColor(const QColor& c) {
	if (m_color == c)
		return;
	m_color = c;
	emit colorChanged();
	markDirty();
}

void BlobGroup::addShape(BlobShape* shape) {
	if (!shape || m_shapes.contains(shape))
		return;
	m_shapes.append(shape);
	markDirty();
}

void BlobGroup::removeShape(BlobShape* shape) {
	m_shapes.removeOne(shape);
	markDirty();
}

void BlobGroup::setInvertedRect(BlobInvertedRect* rect) {
	if (m_invertedRect == rect)
		return;
	m_invertedRect = rect;
	markDirty();
}

void BlobGroup::clearInvertedRect(BlobInvertedRect* rect) {
	if (m_invertedRect != rect)
		return;
	m_invertedRect = nullptr;
	markDirty();
}

void BlobGroup::markDirty() {
	m_physicsUpdated = false;
	for (auto* shape : std::as_const(m_shapes)) {
		shape->polish();
		shape->update();
	}
	if (m_invertedRect) {
		static_cast<BlobShape*>(m_invertedRect)->polish();
		static_cast<BlobShape*>(m_invertedRect)->update();
	}
}

void BlobGroup::markShapeDirty(BlobShape* source, const QRectF& oldGeometry) {
	m_physicsUpdated = false;

	source->polish();
	source->update();

	const float pad = static_cast<float>(m_smoothing) * 2.0f;

	// Compute the source's dirty rect in scene space using its old position
	const QPointF oldScene(oldGeometry.x(), oldGeometry.y());
	const QRectF oldDirtyRect(oldScene.x() - static_cast<double>(pad),
	                          oldScene.y() - static_cast<double>(pad),
	                          static_cast<double>(oldGeometry.width() + pad * 2.0),
	                          static_cast<double>(oldGeometry.height() + pad * 2.0));

	// Compute the source's dirty rect using its new position (fresh from polish)
	const QRectF newDirtyRect(static_cast<double>(source->m_cachedPaddedX - pad),
	                          static_cast<double>(source->m_cachedPaddedY - pad),
	                          static_cast<double>(source->m_cachedPaddedW + pad * 2.0),
	                          static_cast<double>(source->m_cachedPaddedH + pad * 2.0));

	// Mark shapes near the old position as dirty (prevents ghost blobs after panel moves)
	for (auto* shape : std::as_const(m_shapes)) {
		if (shape == source)
			continue;
		const QPointF shapeScene = shape->mapToScene(QPointF(0, 0));
		const QRectF shapeRect(shapeScene.x(), shapeScene.y(),
		                       static_cast<double>(shape->width()), static_cast<double>(shape->height()));
		if (oldDirtyRect.intersects(shapeRect)) {
			shape->polish();
			shape->update();
		}
	}

	// Mark shapes near the new position as dirty
	for (auto* shape : std::as_const(m_shapes)) {
		if (shape == source)
			continue;
		const QPointF shapeScene = shape->mapToScene(QPointF(0, 0));
		const QRectF shapeRect(shapeScene.x(), shapeScene.y(),
		                       static_cast<double>(shape->width()), static_cast<double>(shape->height()));
		if (newDirtyRect.intersects(shapeRect)) {
			shape->polish();
			shape->update();
		}
	}

	if (m_invertedRect && static_cast<BlobShape*>(m_invertedRect) != source) {
		static_cast<BlobShape*>(m_invertedRect)->polish();
		static_cast<BlobShape*>(m_invertedRect)->update();
	}
}

void BlobGroup::ensurePhysicsUpdated() {
	if (m_physicsUpdated)
		return;
	m_physicsUpdated = true;
	for (auto* shape : std::as_const(m_shapes))
		shape->updatePhysics();
}
