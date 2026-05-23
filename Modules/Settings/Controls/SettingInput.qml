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
	property bool shouldBeActive: true

	function formattedValue(): string {
		const value = root.object[root.setting];

		if (value === null || value === undefined)
			return "";

		return String(value);
	}

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
			id: text

			Layout.alignment: Qt.AlignLeft
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomRect {
			id: rect

			Layout.preferredHeight: 33
			Layout.preferredWidth: Math.max(Math.min(textField.contentWidth + Appearance.padding.large * 2, 550), 50)
			color: DynamicColors.tPalette.m3surfaceContainerHigh
			radius: Appearance.rounding.full

			CustomTextField {
				id: textField

				anchors.centerIn: parent
				horizontalAlignment: Text.AlignHCenter
				implicitWidth: Math.min(contentWidth + Appearance.padding.normal * 2, 550)
				text: root.formattedValue()

				onEditingFinished: {
					root.object[root.setting] = textField.text;
					Config.save();
				}
			}
		}
	}
}
