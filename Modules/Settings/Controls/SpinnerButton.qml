import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

CustomRect {
	id: root

	property alias currentIndex: menu.currentIndex
	property bool enabled
	property alias expanded: menu.expanded
	property alias label: label
	property alias menu: menu
	property bool shouldBeActive: true
	property alias text: label.text

	color: enabled ? DynamicColors.palette.m3primary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
	opacity: shouldBeActive ? 1 : 0
	radius: Appearance.rounding.full
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0
	z: expanded ? 100 : 0

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

	CustomText {
		id: label

		anchors.centerIn: parent
		color: root.enabled ? DynamicColors.palette.m3onPrimary : DynamicColors.layer(DynamicColors.palette.m3onSurface, 2)
		font.pointSize: Appearance.font.size.large
	}

	StateLayer {
		function onClicked(): void {
			SettingsDropdowns.toggle(menu, root);
		}

		visible: root.enabled
	}

	PathViewMenu {
		id: menu

		anchors.centerIn: parent
		from: 1
		implicitWidth: root.width
		itemHeight: root.height
		to: 24
	}
}
