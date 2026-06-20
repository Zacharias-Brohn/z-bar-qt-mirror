import QtQuick
import qs.Config

CustomRect {
	id: root

	enum ButtonType {
		Filled,
		Tonal,
		Text
	}

	property color activeColor
	property color activeOnColor
	property bool checked
	property real checkedRadius: Appearance.rounding.medium
	property real defaultRadius: Appearance.rounding.large
	property color disabledColor: Qt.alpha(DynamicColors.palette.m3onSurface, 0.1)
	property color disabledOnColor: Qt.alpha(DynamicColors.palette.m3onSurface, 0.38)
	property bool fillWidth
	property real horizontalPadding: padding
	readonly property alias hovered: stateLayer.containsMouse
	required implicitHeight
	required implicitWidth
	property color inactiveColor
	property color inactiveOnColor
	property bool internalChecked
	property bool isRound
	property bool isToggle
	readonly property color onColor: !enabled ? disabledOnColor : internalChecked ? activeOnColor : inactiveOnColor
	property real padding
	readonly property alias pressed: stateLayer.pressed
	property real pressedRadius: Appearance.rounding.small
	readonly property alias radiusAnim: radiusAnim
	property bool radiusMorph: true
	property alias shapeMorph: stateLayer.shapeMorph
	property real shapeMorphExpansion: shapeMorph && pressed ? 24 : 0
	readonly property alias stateLayer: stateLayer
	property int type: ButtonBase.Filled
	property real verticalPadding: padding

	signal clicked

	color: type === ButtonBase.Text ? "transparent" : !enabled ? disabledColor : internalChecked ? activeColor : inactiveColor
	radius: {
		if (radiusMorph && pressed)
			return pressedRadius;
		if (internalChecked)
			return checkedRadius;
		if (isRound)
			return (height || implicitHeight) / 2 * Math.min(1, Appearance.rounding.scale);
		return defaultRadius;
	}

	Behavior on radius {
		Anim {
			id: radiusAnim

			type: Anim.DefaultEffects
		}
	}
	Behavior on shapeMorphExpansion {
		Anim {
			type: Anim.FastSpatial
		}
	}

	onCheckedChanged: internalChecked = checked

	StateLayer {
		id: stateLayer

		color: root.internalChecked ? root.activeOnColor : root.inactiveOnColor
		enabled: root.enabled

		onClicked: {
			if (root.isToggle)
				root.internalChecked = !root.internalChecked;
			root.clicked();
		}
	}
}
