import Quickshell
import QtQuick
import qs.Components
import qs.Config

CustomMouseArea {
	id: root

	required property var bar
	required property Drawing drawing
	required property Panels panels
	required property var popout
	required property PersistentProperties visibilities

	function inLeftPanel(panel: Item, x: real, y: real): bool {
		return x < panel.x + panel.width + Config.barConfig.border && withinPanelHeight(panel, x, y);
	}

	function withinPanelHeight(panel: Item, x: real, y: real): bool {
		const panelY = panel.y + bar.implicitHeight;
		return y >= panelY && y <= panelY + panel.height;
	}

	acceptedButtons: Qt.LeftButton | Qt.RightButton
	enabled: z > 0
	hoverEnabled: true
	visible: root.visibilities.isDrawing

	onPositionChanged: event => {
		const x = event.x;
		const y = event.y;
		if (root.visibilities.isDrawing && (event.buttons & Qt.LeftButton)) {
			root.drawing.points.push(Qt.point(x, y));
			root.drawing.requestPaint();
		}

		if (root.inLeftPanel(root.popout, x, y)) {
			console.log("set -2 z");
			root.z = -2;
			root.panels.drawing.expanded = true;
		}
	}
	onPressed: event => {
		const x = event.x;
		const y = event.y;

		if (root.visibilities.isDrawing && (event.buttons & Qt.LeftButton)) {
			root.panels.drawing.expanded = false;
			root.drawing.points.push(Qt.point(x, y));
			root.drawing.requestPaint();
			return;
		}

		if (event.buttons & Qt.RightButton)
			root.drawing.clear();
	}
	onReleased: {
		root.drawing.points = [];
	}
}
