pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import ZShell.Components
import qs.Config

Item {
	id: root

	readonly property real arcRadius: (size - padding - strokeWidth * (1 + waveAmplitude * 2)) / 2
	property color bgColor: DynamicColors.palette.m3secondaryContainer
	property real clampedVal: Math.max(1 / 360, Math.min(1, isNaN(value) ? 0 : value))
	readonly property real dotAngleRad: (startAngle + sweepAngle - gapAngle * (sweepAngle < 360 ? 0 : 1)) * Math.PI / 180
	property color fgColor: DynamicColors.palette.m3primary
	readonly property real gapAngle: ((spacing + strokeWidth) / (arcRadius || 1)) * (180 / Math.PI)
	property alias hasEndIndicator: dot.active
	property real implicitSize
	property int padding: 0
	readonly property real size: Math.min(width, height)
	property int spacing: Appearance.spacing.small
	property int startAngle: -90
	property int strokeWidth: Appearance.padding.small
	property int sweepAngle: 360
	readonly property real thickness: strokeWidth * (1 + waveAmplitude) * 2
	property real value
	property alias waveAmplitude: wave.amplitudeMultiplier
	property alias waveDuration: waveProgAnim.duration
	property alias waveFrequency: wave.frequency
	property bool wavePaused
	property bool wavy: false

	implicitHeight: implicitSize
	implicitWidth: implicitSize

	Shape {
		asynchronous: true
		opacity: Math.min(1, remainingArc.sweepAngle)
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			capStyle: ShapePath.RoundCap
			fillColor: "transparent"
			strokeColor: root.bgColor
			strokeWidth: Math.min(1, remainingArc.sweepAngle) * root.strokeWidth

			Behavior on strokeColor {
				CAnim {
				}
			}

			PathAngleArc {
				id: remainingArc

				centerX: root.size / 2
				centerY: root.size / 2
				radiusX: root.arcRadius
				radiusY: root.arcRadius
				startAngle: root.startAngle + root.clampedVal * root.sweepAngle + root.gapAngle
				sweepAngle: Math.max(1 / 360, root.sweepAngle * (1 - root.clampedVal) - root.gapAngle * (root.sweepAngle < 360 ? 1 : 2))
			}
		}
	}

	WavyLine {
		id: wave

		amplitudeMultiplier: root.wavy ? 0.5 : 0
		anchors.fill: parent
		anchors.margins: -lineWidth * amplitudeMultiplier
		color: root.fgColor
		frequency: 8
		fullAngle: root.sweepAngle
		lineWidth: root.strokeWidth
		pathType: WavyLine.Arc
		radius: root.arcRadius
		startAngle: root.startAngle
		value: root.clampedVal

		Behavior on amplitudeMultiplier {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		Behavior on color {
			CAnim {
			}
		}
		Anim on waveProgress {
			id: waveProgAnim

			duration: 2000
			easing.type: Easing.Linear
			from: 0
			loops: Animation.Infinite
			paused: root.wavePaused || wave.amplitudeMultiplier === 0
			running: true
			to: 1
		}
	}

	Loader {
		id: dot

		x: root.size / 2 + root.arcRadius * Math.cos(root.dotAngleRad) - width / 2
		y: root.size / 2 + root.arcRadius * Math.sin(root.dotAngleRad) - height / 2

		sourceComponent: CustomRect {
			color: root.fgColor
			implicitHeight: Math.min(1, remainingArc.sweepAngle) * Math.min(4, root.strokeWidth)
			implicitWidth: Math.min(1, remainingArc.sweepAngle) * Math.min(4, root.strokeWidth)
			opacity: Math.min(1, remainingArc.sweepAngle)
			radius: Appearance.rounding.full
		}
	}
}
