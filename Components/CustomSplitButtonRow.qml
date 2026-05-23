pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config

Item {
	id: root

	property alias active: splitButton.active
	property alias buttonAlias: splitButton
	property bool enabled: true
	property alias expanded: splitButton.expanded
	property int expandedZ: 100
	required property string label
	property alias menuItems: splitButton.menuItems
	property bool shouldBeActive: true
	property alias type: splitButton.type

	signal selected(item: MenuItem)

	anchors.left: parent.left
	anchors.right: parent.right
	clip: false
	implicitHeight: row.implicitHeight + Appearance.padding.smaller * 2
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	z: root.expanded ? expandedZ : -1

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.normal

		CustomText {
			Layout.fillWidth: true
			color: root.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.larger
			text: root.label
			z: root.expanded ? root.expandedZ : -1
		}

		CustomSplitButton {
			id: splitButton

			enabled: root.enabled
			type: CustomSplitButton.Filled
			z: root.expanded ? root.expandedZ : -1

			menu.onItemSelected: item => {
				root.selected(item);
				splitButton.closeDropdown();
			}
			stateLayer.onClicked: {
				splitButton.toggleDropdown();
			}
		}
	}
}
