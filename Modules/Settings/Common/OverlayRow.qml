import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.Settings

ConnectedRect {
	id: root

	property alias checked: switchButton.checked
	property int horizontalPadding: Appearance.padding.largeIncreased
	required property Component popup
	property alias subtext: subtext.text
	property alias text: text.text
	property int verticalPadding: Appearance.padding.normal

	signal clicked(checked: bool)

	Layout.fillWidth: true
	implicitHeight: layout.implicitHeight + verticalPadding * 2

	Column {
		id: layout

		anchors.left: parent.left
		anchors.leftMargin: root.horizontalPadding
		anchors.right: icon.left
		anchors.rightMargin: Appearance.padding.normal
		anchors.verticalCenter: parent.verticalCenter

		CustomText {
			id: text

			font.pointSize: Appearance.font.size.smaller
		}

		CustomText {
			id: subtext

			color: DynamicColors.palette.m3outline
			font.pointSize: Appearance.font.size.small
			wrapMode: Text.WordWrap
		}
	}

	MaterialIcon {
		id: icon

		anchors.right: switchButton.left
		anchors.rightMargin: Appearance.spacing.normal
		anchors.verticalCenter: parent.verticalCenter
		text: "open_in_new"
	}

	StateLayer {
		onClicked: PopupManager.requestOpen(root.popup)
	}

	CustomSwitch {
		id: switchButton

		anchors.right: parent.right
		anchors.rightMargin: root.horizontalPadding
		anchors.verticalCenter: parent.verticalCenter

		onClicked: root.clicked(checked)
	}
}
