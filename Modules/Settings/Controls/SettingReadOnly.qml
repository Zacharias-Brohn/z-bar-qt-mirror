import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	property bool shouldBeActive: true
	required property string value

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? row.implicitHeight + Appearance.padding.smaller * 2 : 0
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}
	Behavior on y {
		Anim {
		}
	}

	Rectangle {
		anchors.fill: parent
		anchors.margins: -Appearance.padding.smaller
		color: DynamicColors.palette.m3primaryContainer
		opacity: root.highlighted ? 0.5 : 0
		radius: Appearance.rounding.small

		Behavior on opacity {
			Anim {
				duration: Appearance.anim.durations.normal
			}
		}
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomText {
			color: DynamicColors.palette.m3onSurfaceVariant
			font.family: Appearance.font.family.mono
			font.pointSize: Appearance.font.size.normal
			text: root.value
		}
	}
}
