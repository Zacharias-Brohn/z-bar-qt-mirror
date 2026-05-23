import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	property real max: Infinity
	property real min: -Infinity
	required property string name
	required property var object
	required property string setting
	property bool shouldBeActive: true
	property real step: 1

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
			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomSpinBox {
			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
			max: root.max
			min: root.min
			step: root.step
			value: Number(root.object[root.setting] ?? 0)

			onValueModified: function (value) {
				root.object[root.setting] = value;
				Config.save();
			}
		}
	}
}
