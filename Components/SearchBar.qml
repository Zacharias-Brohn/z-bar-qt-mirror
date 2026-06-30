import QtQuick
import qs.Config

TextFieldBase {
	id: root

	readonly property alias bg: bg
	readonly property alias clearIcon: clearIcon
	readonly property alias searchIcon: searchIcon

	bottomPadding: Appearance.padding.large
	leftPadding: searchIcon.width + searchIcon.anchors.leftMargin + Appearance.spacing.small
	rightPadding: clearIcon.width + clearIcon.anchors.rightMargin + Appearance.spacing.small
	topPadding: Appearance.padding.large

	background: CustomRect {
		id: bg

		anchors.fill: parent
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.full

		StateLayer {
			id: stateLayer

			cursorShape: Qt.IBeamCursor
			enabled: !root.activeFocus
			manualPressOverride: tapHandler.pressed

			onClicked: root.focus = true
		}
	}

	onPressed: {
		if (stateLayer.enabled)
			stateLayer.press(stateLayer.mouseX, stateLayer.mouseY);
	}

	CustomText {
		id: placeholder

		anchors.left: parent.left
		anchors.leftMargin: root.leftPadding
		anchors.verticalCenter: parent.verticalCenter
		color: root.placeholderTextColor
		font: root.font
		opacity: root.text ? 0 : 1
		text: root.placeholderText

		Behavior on opacity {
			Anim {
				type: Anim.DefaultEffects
			}
		}
	}

	MaterialIcon {
		id: searchIcon

		anchors.left: parent.left
		anchors.leftMargin: Appearance.padding.large
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.palette.m3onSurfaceVariant
		font.pointSize: Appearance.font.size.large
		text: "search"
	}

	IconButton {
		id: clearIcon

		anchors.right: parent.right
		anchors.rightMargin: Appearance.padding.larger
		anchors.verticalCenter: parent.verticalCenter
		enabled: root.text
		icon: "clear"
		opacity: root.text ? 1 : 0
		radius: Appearance.rounding.full
		radiusMorph: false
		stateLayer.hoverEnabled: enabled
		type: IconButton.Text

		Behavior on opacity {
			Anim {
				type: Anim.DefaultEffects
			}
		}

		onClicked: root.clear()
	}

	TapHandler {
		id: tapHandler
	}
}
