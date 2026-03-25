import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	required property string setting

	Layout.fillWidth: true
	Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

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
			id: text

			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomSwitch {
			id: cswitch

			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
			checked: root.object[root.setting]

			onToggled: {
				root.object[root.setting] = checked;
				Config.save();
			}
		}
	}
}
