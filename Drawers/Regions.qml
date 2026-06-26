pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Modules.Bar as Bar

Region {
	id: root

	required property Bar.BarLoader bar
	readonly property real borderThickness: win.borderThickness
	readonly property alias menuPopoutRegion: menuPopoutRegion
	required property Panels panels
	required property var win

	height: win.height - bar.implicitHeight - win.borderThickness - win.dragMaskPadding * 2
	intersection: Intersection.Xor
	width: win.width - win.borderThickness * 2 - win.dragMaskPadding * 2
	x: win.borderThickness + win.dragMaskPadding
	y: bar.implicitHeight + win.dragMaskPadding

	R {
		panel: root.panels.dashboardWrapper
	}

	R {
		panel: root.panels.launcher
	}

	R {
		id: sidebarRegion

		panel: root.panels.sidebar
		width: panel.width * (1 - root.panels.sidebar.offsetScale) + root.borderThickness
		x: root.win.width - width
	}

	R {
		panel: root.panels.osdWrapper
		width: panel.width * (1 - root.panels.osd.offsetScale) + root.borderThickness
		x: root.win.width - width
	}

	R {
		panel: root.panels.notifications
	}

	R {
		height: panel.height * (1 - root.panels.utilities.offsetScale) + root.borderThickness
		panel: root.panels.utilities
		y: root.win.height - height
	}

	R {
		panel: root.panels.popoutsWrapper
	}

	R {
		panel: root.panels.resourcesWrapper
	}

	R {
		panel: root.panels.settingsWrapper
	}

	R {
		panel: root.panels.dock
	}

	R {
		panel: root.panels.clipboard
	}

	Region {
		id: menuPopoutRegion

		intersection: Intersection.Subtract
	}

	component R: Region {
		required property Item panel

		height: panel.height
		intersection: Intersection.Subtract
		width: panel.width
		x: panel.x + root.borderThickness
		y: panel.y + root.bar.implicitHeight
	}
}
