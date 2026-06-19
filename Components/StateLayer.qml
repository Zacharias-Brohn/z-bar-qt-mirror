import QtQuick
import QtQuick.Shapes
import ZShell
import ZShell.Components
import qs.Helpers
import qs.Config

MouseArea {
	id: root

	property alias bottomLeftRadius: base.bottomLeftRadius
	property alias bottomRightRadius: base.bottomRightRadius
	property real circleRadius
	property alias color: base.color
	readonly property real endRadius: {
		const d1 = distSq(0, 0);
		const d2 = distSq(width, 0);
		const d3 = distSq(0, height);
		const d4 = distSq(width, height);
		return (Math.sqrt(Math.max(d1, d2, d3, d4)) + (shapeMorph ? 24 : 0)) * 1.3;
	}
	property real endRadiusAtPress
	property bool manualPressOverride
	property real pressX: width / 2
	property real pressY: height / 2
	property alias radius: base.radius
	readonly property alias rect: base
	property bool shapeMorph
	property bool showHoverBackground: true
	property real stateOpacity: containsMouse ? 0.08 : 0
	property alias topLeftRadius: base.topLeftRadius
	property alias topRightRadius: base.topRightRadius

	function clamp(r: real): real {
		return Math.max(0, Math.min(r, width / 2, height / 2));
	}

	function distSq(x: real, y: real): real {
		return (pressX - x) ** 2 + (pressY - y) ** 2;
	}

	function press(x: real, y: real): void {
		pressX = x;
		pressY = y;
		fadeAnim.complete();
		circleRadius = 0;
		circle.opacity = 0.1;
		rippleAnim.restart();
		endRadiusAtPress = endRadius;
	}

	anchors.fill: parent
	cursorShape: !enabled ? undefined : Qt.PointingHandCursor
	enabled: parent.enabled && !Visibilities.getForActive().isDrawing
	hoverEnabled: true

	Behavior on stateOpacity {
		Anim {
			type: Anim.DefaultEffects
		}
	}

	onCircleRadiusChanged: {
		if (!(pressed || manualPressOverride) && circleRadius > endRadiusAtPress * 0.99 && !fadeAnim.running)
			fadeAnim.start();
	}
	onManualPressOverrideChanged: {
		if (!(pressed || manualPressOverride) && circleRadius > endRadiusAtPress * 0.99 && !fadeAnim.running)
			fadeAnim.start();
	}
	onPressed: e => press(e.x, e.y)
	onPressedChanged: {
		if (!(pressed || manualPressOverride) && !rippleAnim.running && circle.opacity > 0)
			fadeAnim.start();
	}

	Anim {
		id: rippleAnim

		alwaysRunToEnd: true
		duration: Appearance.anim.durations.expressiveSlowEffects * 2
		easing.bezierCurve: Appearance.anim.curves.standard
		property: "circleRadius"
		target: root
		to: root.endRadius
	}

	Anim {
		id: fadeAnim

		property: "opacity"
		target: circle
		to: 0
		type: Anim.SlowEffects
	}

	CustomRect {
		id: base

		anchors.fill: parent
		bottomLeftRadius: root.parent?.bottomLeftRadius ?? radius ?? 0
		bottomRightRadius: root.parent?.bottomRightRadius ?? radius ?? 0
		color: DynamicColors.palette.m3onSurface
		opacity: root.stateOpacity
		// Pick up radius from parent if it has one (parent can be anything with radius props)
		// qmllint disable missing-property
		radius: root.parent?.radius ?? 0
		topLeftRadius: root.parent?.topLeftRadius ?? radius ?? 0
		topRightRadius: root.parent?.topRightRadius ?? radius ?? 0
		// qmllint enable missing-property
	}

	Shape {
		id: circle

		anchors.fill: parent
		opacity: 0
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			fillColor: base.color
			startX: root.clamp(base.topLeftRadius)
			startY: 0
			strokeColor: "transparent"
			strokeWidth: 0

			fillGradient: RadialGradient {
				centerRadius: root.circleRadius
				centerX: root.pressX
				centerY: root.pressY
				focalX: centerX
				focalY: centerY

				GradientStop {
					color: Qt.alpha(base.color, 1)
					position: 0
				}

				GradientStop {
					color: Qt.alpha(base.color, 1)
					position: ZUtils.clamp(1 - 0.2 * root.endRadius / root.circleRadius, 0.01, 0.99)
				}

				GradientStop {
					color: Qt.alpha(base.color, ZUtils.clamp((root.circleRadius / root.endRadius - 0.9) / 0.1, 0, 1))
					position: 1
				}
			}

			PathLine {
				x: root.width - root.clamp(base.topRightRadius)
				y: 0
			}

			PathArc {
				radiusX: root.clamp(base.topRightRadius)
				radiusY: root.clamp(base.topRightRadius)
				relativeX: root.clamp(base.topRightRadius)
				relativeY: root.clamp(base.topRightRadius)
			}

			PathLine {
				x: root.width
				y: root.height - root.clamp(base.bottomRightRadius)
			}

			PathArc {
				radiusX: root.clamp(base.bottomRightRadius)
				radiusY: root.clamp(base.bottomRightRadius)
				relativeX: -root.clamp(base.bottomRightRadius)
				relativeY: root.clamp(base.bottomRightRadius)
			}

			PathLine {
				x: root.clamp(base.bottomLeftRadius)
				y: root.height
			}

			PathArc {
				radiusX: root.clamp(base.bottomLeftRadius)
				radiusY: root.clamp(base.bottomLeftRadius)
				relativeX: -root.clamp(base.bottomLeftRadius)
				relativeY: -root.clamp(base.bottomLeftRadius)
			}

			PathLine {
				x: 0
				y: root.clamp(base.topLeftRadius)
			}

			PathArc {
				radiusX: root.clamp(base.topLeftRadius)
				radiusY: root.clamp(base.topLeftRadius)
				x: root.clamp(base.topLeftRadius)
				y: 0
			}
		}
	}
}
