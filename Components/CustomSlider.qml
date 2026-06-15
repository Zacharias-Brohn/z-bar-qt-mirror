pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates
import ZShell.Components
import ZShell
import qs.Components
import qs.Config

Slider {
	id: root

	property bool animateWave
	property color bgColor: enabled ? DynamicColors.palette.m3secondaryContainer : Qt.alpha(DynamicColors.palette.m3onSurface, 0.1)
	property color fgColor: enabled ? DynamicColors.palette.m3primary : Qt.alpha(DynamicColors.palette.m3onSurface, 0.38)
	property real filledWidth
	property alias inset: inset
	property color insetColor: enabled ? (inset.attached ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onPrimary) : DynamicColors.palette.m3onSurface
	property string insetIcon: ""
	property real pos: visualPosition
	property int radius: Appearance.rounding.small
	property int waveDuration: 1000
	property real waveFrequency: 6
	property bool wavy

	signal interaction(v: real)

	implicitHeight: 12
	implicitWidth: 200

	contentItem: Item {
		anchors.fill: parent

		CustomRect {
			id: remaining

			anchors.left: handle.right
			anchors.leftMargin: Appearance.spacing.extraSmall
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			bottomLeftRadius: Appearance.rounding.extraSmall / 2
			color: root.bgColor
			implicitHeight: parent.height * (parent.height <= 12 ? opacity : Math.min(opacity * 2, 1))
			opacity: Math.min(width, 12) / 12
			radius: root.radius
			topLeftRadius: Appearance.rounding.extraSmall / 2
		}

		CustomRect {
			anchors.right: parent.right
			anchors.rightMargin: 4 * remaining.opacity
			anchors.verticalCenter: parent.verticalCenter
			color: root.fgColor
			implicitHeight: 4 * remaining.opacity
			implicitWidth: implicitHeight
			opacity: remaining.opacity
			radius: Appearance.rounding.full
		}

		CustomRect {
			id: handle

			anchors.left: filled.right
			anchors.leftMargin: Appearance.spacing.extraSmall
			anchors.verticalCenter: parent.verticalCenter
			color: root.fgColor
			implicitHeight: {
				const t = ZUtils.clamp((parent.height - 12) / 16, 0, 1);
				const lerp = (a, b) => a + (b - a) * t;
				return parent.height * (mouse.pressed ? lerp(3.5, 1.5) : lerp(3, 1.2));
			}
			implicitWidth: 4
			radius: Appearance.rounding.full

			Behavior on implicitHeight {
				Anim {
					type: Anim.FastSpatial
				}
			}
		}

		Loader {
			id: filled

			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			asynchronous: true
			sourceComponent: root.wavy ? waveComp : lineComp
		}

		MaterialIcon {
			id: inset

			readonly property bool attached: root.filledWidth < (inset.paintedWidth + Appearance.spacing.extraSmall * 2)
			property real dockT: attached ? 1 : 0

			anchors.bottom: parent.bottom
			anchors.top: parent.top
			color: root.insetColor
			font.pixelSize: Appearance.font.size.smaller * 2
			text: root.insetIcon
			verticalAlignment: Text.AlignVCenter
			visible: !root.wavy && root.insetIcon !== ""
			x: Appearance.spacing.extraSmall + dockT * (handle.x + Appearance.spacing.small)

			Behavior on dockT {
				Anim {
				}
			}
		}

		Component {
			id: lineComp

			CustomRect {
				bottomRightRadius: Appearance.rounding.extraSmall / 2
				color: root.fgColor
				implicitHeight: root.height
				implicitWidth: root.filledWidth
				radius: root.radius
				topRightRadius: Appearance.rounding.extraSmall / 2
			}
		}

		Component {
			id: waveComp

			WavyLine {
				color: root.fgColor
				frequency: root.waveFrequency
				fullLength: root.width - handle.implicitWidth - handle.anchors.leftMargin
				implicitHeight: lineWidth * amplitudeMultiplier * 2 + lineWidth
				implicitWidth: root.filledWidth
				lineWidth: root.height * 0.7
				startX: x

				Behavior on color {
					CAnim {
					}
				}
				Anim on waveProgress {
					duration: root.waveDuration
					easing.type: Easing.Linear
					from: 0
					loops: Animation.Infinite
					paused: !root.animateWave
					running: true
					to: 1
				}
			}
		}
	}
	Behavior on filledWidth {
		id: widthBehavior

		Anim {
		}
	}

	Component.onCompleted: filledWidth = Qt.binding(() => (width - handle.implicitWidth - handle.anchors.leftMargin) * pos)

	Binding {
		id: posBinding

		property: "pos"
		target: root
		value: ZUtils.clamp(mouse.pressStartPos + mouse.dragMovement, 0, 1)
		when: mouse.pressed
	}

	MouseArea {
		id: mouse

		property real dragMovement
		property real pressStartPos
		property real pressStartX

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		implicitHeight: handle.implicitHeight
		preventStealing: true

		onPositionChanged: e => {
			dragMovement = (e.x - pressStartX) / width;
			root.interaction(posBinding.value);
		}
		onPressed: e => {
			widthBehavior.enabled = false;
			pressStartX = e.x;
			pressStartPos = root.visualPosition;
		}
		onReleased: e => {
			root.interaction(posBinding.value);
			widthBehavior.enabled = true;
			dragMovement = 0;
		}
	}
}
