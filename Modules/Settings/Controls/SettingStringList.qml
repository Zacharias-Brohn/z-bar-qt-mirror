import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	property string addLabel: qsTr("Add entry")
	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	required property string setting
	property bool shouldBeActive: true

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? layout.implicitHeight : 0
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

	ColumnLayout {
		id: layout

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: Appearance.spacing.small

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		StringListEditor {
			Layout.fillWidth: true
			addLabel: root.addLabel
			anchors.left: undefined
			anchors.right: undefined
			anchors.verticalCenter: undefined
			values: [...(root.object[root.setting] ?? [])]

			onListEdited: function (values) {
				root.object[root.setting] = values;
				Config.save();
			}
		}
	}
}
