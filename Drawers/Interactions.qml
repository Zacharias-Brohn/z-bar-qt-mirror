import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Helpers
import qs.Modules as BarPopouts

Item {
	id: root

	required property Item bar
	required property real borderThickness
	property bool dashboardShortcutActive
	required property Drawing drawing
	property bool osdShortcutActive
	required property Panels panels
	required property BarPopouts.Wrapper popouts
	required property ShellScreen screen
	property bool singleGestureTriggered: false
	property bool utilitiesShortcutActive
	required property PersistentProperties visibilities

	function inBottomPanel(panel: Item, x: real, y: real): bool {
		return y > root.height - panel.height - Config.barConfig.border && withinPanelWidth(panel, x, y);
	}

	function inLeftPanel(panel: Item, x: real, y: real): bool {
		return x < panel.x + panel.width + Config.barConfig.border && withinPanelHeight(panel, x, y);
	}

	function inRightPanel(panel: Item, x: real, y: real): bool {
		return x > panel.x - Config.barConfig.border && withinPanelHeight(panel, x, y);
	}

	function inTopPanel(panel: Item, x: real, y: real): bool {
		return y < bar.implicitHeight + panel.height && withinPanelWidth(panel, x, y);
	}

	function onWheel(event: WheelEvent): void {
		if (event.x < bar.implicitWidth) {
			bar.handleWheel(event.y, event.angleDelta);
		}
	}

	function withinPanelHeight(panel: Item, x: real, y: real): bool {
		const panelY = panel.y + bar.implicitHeight;
		return y >= panelY && y <= panelY + panel.height;
	}

	function withinPanelWidth(panel: Item, x: real, y: real): bool {
		const panelX = panel.x + root.borderThickness;
		return x >= panelX && x <= panelX + panel.width;
	}

	anchors.fill: parent

	DragHandler {
		id: singleHandler

		cursorShape: (active && centroid.pressPosition.y < root.bar.implicitHeight) ? Qt.ClosedHandCursor : undefined
		dragThreshold: 0
		enabled: !root.visibilities.isDrawing
		grabPermissions: PointerHandler.CanTakeOverFromHandlersOfSameType | PointerHandler.ApprovesTakeOverByAnything
		maximumPointCount: 1
		minimumPointCount: 1
		target: null

		onActiveChanged: {
			if (!active)
				root.singleGestureTriggered = false;
		}
		onCentroidChanged: {
			const x = centroid.position.x;
			const y = centroid.position.y;
			const dragX = x - centroid.pressPosition.x;
			const dragY = y - centroid.pressPosition.y;

			if (centroid.pressPosition.y >= root.screen.height - Config.barConfig.border && centroid.pressPosition.x > root.screen.width / 5 && dragY < -200)
				root.visibilities.launcher = true;

			if (root.singleGestureTriggered)
				return;

			if (centroid.pressPosition.y < root.bar.implicitHeight) {
				if (dragY > 20) {
					root.visibilities.settings = true;
					root.singleGestureTriggered = true;
				} else if (dragY < -20) {
					root.visibilities.settings = false;
					root.singleGestureTriggered = true;
				}
			}

			if (centroid.pressPosition.y > root.screen.height - Config.barConfig.border && centroid.pressPosition.x < root.screen.width / 5 && dragY < -50)
				root.visibilities.clipboard = true;

			if (!Config.dock.hoverToReveal && centroid.pressPosition.y > root.screen.height - root.bar.implicitHeight && centroid.pressPosition.x > root.screen.width / 5)
				if (dragY < -10) {
					root.visibilities.dock = true;
					root.singleGestureTriggered = true;
				}

			if (centroid.pressPosition.x > root.screen.width - Config.barConfig.border && centroid.pressPosition.y < (root.screen.height / 2) && dragX < -20) {
				root.visibilities.sidebar = true;
				root.singleGestureTriggered = true;
			}

			if (centroid.pressPosition.x >= root.screen.width - Config.barConfig.border && centroid.pressPosition.y > (root.screen.height / 2) && dragX < -20) {
				Hypr.dispatch(`hl.dsp.focus({ workspace = 'r+1', on_current_monitor = true })`);
				root.singleGestureTriggered = true;
			}

			if (centroid.pressPosition.x <= Config.barConfig.border && dragX > 20) {
				Hypr.dispatch(`hl.dsp.focus({ workspace = 'r-1', on_current_monitor = true })`);
				root.singleGestureTriggered = true;
			}
		}
	}

	PointHandler {
		id: drawingHandler

		property bool setInitialPoint: false

		enabled: root.visibilities.isDrawing

		onActiveChanged: {
			console.log(active);
			if (!active) {
				setInitialPoint = false;
				root.drawing.endStroke();
			} else {
				root.panels.drawing.expanded = false;
			}
		}
		onPointChanged: {
			const x = point.position.x;
			const y = point.position.y;
			const origX = point.pressPosition.x;
			const origY = point.pressPosition.y;
			if (x === 0 && y === 0 && origX === 0 && origY === 0)
				return;

			if (!setInitialPoint) {
				setInitialPoint = true;
				root.drawing.beginStroke(origX, origY);
				return;
			}

			root.drawing.appendPoint(x, y);
		}
	}

	HoverHandler {
		id: hoverHandler

		onHoveredChanged: {
			if (!hovered) {
				if (!root.osdShortcutActive) {
					root.visibilities.osd = false;
					root.panels.osd.hovered = false;
				}

				if (!root.popouts.currentName.startsWith("traymenu")) {
					root.popouts.hasCurrent = false;
				}

				if (Config.barConfig.autoHide)
					root.bar.isHovered = false;
			}
		}
		onPointChanged: {
			const x = point.position.x;
			const y = point.position.y;

			if (root.visibilities.isDrawing) {
				if (root.inLeftPanel(root.panels.drawing, x, y))
					root.panels.drawing.expanded = true;
				return;
			}

			if (!root.visibilities.bar && Config.barConfig.autoHide && y < root.bar.implicitHeight)
				root.bar.isHovered = true;

			if (root.panels.sidebar.width === 0) {
				const showOsd = root.inRightPanel(root.panels.osdWrapper, x, y);

				if (showOsd) {
					root.osdShortcutActive = false;
					root.panels.osd.hovered = true;
				}
			} else {
				const outOfSidebar = x < root.width - root.panels.sidebar.width;
				const showOsd = outOfSidebar && root.inRightPanel(root.panels.osdWrapper, x, y);

				if (!root.osdShortcutActive) {
					root.visibilities.osd = showOsd;
					root.panels.osd.hovered = showOsd;
				} else if (showOsd) {
					root.osdShortcutActive = false;
					root.panels.osd.hovered = true;
				}
			}

			if (Config.dock.enable && Config.dock.hoverToReveal && !root.visibilities.dock && !root.visibilities.launcher && root.inBottomPanel(root.panels.dock, x, y))
				root.visibilities.dock = true;

			if (y < root.bar.implicitHeight)
				root.bar.checkPopout(x);
		}
	}

	Connections {
		function onDashboardChanged() {
			if (root.visibilities.dashboard) {
				const inDashboardArea = root.inTopPanel(root.panels.dashboard, root.mouseX, root.mouseY);
				if (!inDashboardArea) {
					root.dashboardShortcutActive = true;
				}
				if (root.panels.launcher.x + root.panels.launcher.width > root.panels.dashboardWrapper.x)
					root.visibilities.launcher = false;

				root.visibilities.settings = false;
				root.visibilities.sidebar = false;
				root.popouts.hasCurrent = false;
			} else {
				root.dashboardShortcutActive = false;
			}
		}

		function onIsDrawingChanged() {
			if (!root.visibilities.isDrawing)
				root.drawing.clear();
		}

		function onLauncherChanged() {
			if (!root.visibilities.launcher) {
				root.dashboardShortcutActive = false;
				root.osdShortcutActive = false;
				root.utilitiesShortcutActive = false;

				const inOsdArea = root.inRightPanel(root.panels.osd, root.mouseX, root.mouseY);

				if (!inOsdArea) {
					root.visibilities.osd = false;
					root.panels.osd.hovered = false;
				}
			}

			if (root.visibilities.launcher) {
				if (root.panels.dashboardWrapper.x < root.panels.launcher.x + root.panels.launcher.width) {
					root.visibilities.dashboard = false;
				}

				root.visibilities.dock = false;
				root.visibilities.settings = false;
			}
		}

		function onOsdChanged() {
			if (root.visibilities.osd) {
				const inOsdArea = root.inRightPanel(root.panels.osd, root.mouseX, root.mouseY);
				if (!inOsdArea) {
					root.osdShortcutActive = true;
				}
			} else {
				root.osdShortcutActive = false;
			}
		}

		function onResourcesChanged() {
			if (root.visibilities.resources && (root.popouts.currentName.startsWith("audio") || root.popouts.currentName.startsWith("updates"))) {
				root.popouts.hasCurrent = false;
			}

			if (root.visibilities.resources)
				root.visibilities.settings = false;
		}

		function onSettingsChanged() {
			if (root.visibilities.settings) {
				root.visibilities.resources = false;
				root.visibilities.dashboard = false;
				root.visibilities.sidebar = false;
				root.panels.popouts.hasCurrent = false;
				root.visibilities.launcher = false;
			}
		}

		function onSidebarChanged() {
			if (root.visibilities.sidebar) {
				root.visibilities.dashboard = false;
				root.visibilities.settings = false;
				root.popouts.hasCurrent = false;
			}
		}

		function onUtilitiesChanged() {
			if (root.visibilities.utilities) {
				const inUtilitiesArea = root.inBottomPanel(root.panels.utilities, root.mouseX, root.mouseY);
				if (!inUtilitiesArea) {
					root.utilitiesShortcutActive = true;
				}
			} else {
				root.utilitiesShortcutActive = false;
			}
		}

		target: root.visibilities
	}
}
