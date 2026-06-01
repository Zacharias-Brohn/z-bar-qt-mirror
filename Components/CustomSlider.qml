import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
	id: root

	property color color: DynamicColors.palette.m3primary

	background: Item {
		CustomRect {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: root.implicitHeight / 6
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.topMargin: root.implicitHeight / 6
			bottomRightRadius: root.implicitHeight / 6
			color: root.color
			implicitWidth: root.handle.x - root.implicitHeight / 6
			radius: root.implicitHeight / 6
			topRightRadius: root.implicitHeight / 6
		}

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: root.implicitHeight / 6
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.topMargin: root.implicitHeight / 6
			bottomLeftRadius: root.implicitHeight / 6
			color: DynamicColors.tPalette.m3surfaceContainerHighest
			implicitWidth: parent.width - root.handle.x - root.handle.implicitWidth - root.implicitHeight / 6
			radius: root.implicitHeight / 6
			topLeftRadius: root.implicitHeight / 6
		}
	}
	handle: CustomRect {
		anchors.verticalCenter: parent.verticalCenter
		color: root.color
		implicitHeight: root.implicitHeight
		implicitWidth: root.implicitHeight / 4.5
		radius: Appearance.rounding.full
		x: root.visualPosition * root.availableWidth - implicitWidth / 2

		MouseArea {
			acceptedButtons: Qt.NoButton
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
		}
	}
}
