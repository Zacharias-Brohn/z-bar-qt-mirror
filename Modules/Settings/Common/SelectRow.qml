import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ConnectedRect {
	id: root

	property alias active: splitButton.active
	property alias fallbackIcon: splitButton.fallbackIcon
	property alias fallbackText: splitButton.fallbackText
	property alias menuItems: splitButton.menuItems
	property alias menuOnTop: splitButton.menuOnTop
	property string subtext
	property alias text: label.text

	signal selected(item: MenuItem)

	Layout.fillWidth: true
	clip: false
	implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins * 2
	z: splitButton.expanded ? 1 : 0

	RowLayout {
		id: rowLayout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.largeIncreased
		anchors.margins: Appearance.padding.normal
		anchors.rightMargin: Appearance.padding.largeIncreased
		spacing: Appearance.spacing.small

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			CustomText {
				id: label

				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.smaller
			}

			CustomText {
				Layout.fillWidth: true
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				text: root.subtext
				visible: root.subtext
			}
		}

		CustomSplitButton {
			id: splitButton

			type: CustomSplitButton.Tonal

			menu.onItemSelected: item => root.selected(item)
			stateLayer.onClicked: splitButton.expanded = !splitButton.expanded
		}
	}
}
