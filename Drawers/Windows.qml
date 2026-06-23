pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import ZShell.Blobs
import qs.Daemons
import qs.Components
import qs.Modules.Bar
import qs.Config
import qs.Helpers
import qs.Drawers

CustomWindow {
	id: root

	readonly property alias bar: bar
	readonly property real borderLayoutThickness: hasFullscreen ? 0 : Config.barConfig.border
	readonly property real borderRounding: Config.barConfig.rounding * (1 - fsTransitionProg)
	readonly property real borderThickness: Config.barConfig.border * (1 - fsTransitionProg)
	readonly property int dragMaskPadding: {
		if (focusGrab.active)
			return 0;

		if (monitor?.lastIpcObject.specialWorkspace?.name || monitor?.activeWorkspace.lastIpcObject.windows > 0)
			return 0;

		return 100;
	}
	property real fsTransitionProg: hasFullscreen ? 1 : 0
	readonly property bool hasFullscreen: {
		if (hasSpecialWorkspace) {
			const specialName = monitor?.lastIpcObject.specialWorkspace?.name;
			if (!specialName)
				return false;
			const specialWs = Hypr.workspaces.values.find(ws => ws.name === specialName);
			return specialWs?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false;
		}
		return hasFullscreenOnNormalWs;
	}
	readonly property bool hasFullscreenOnNormalWs: monitor?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false
	readonly property bool hasSpecialWorkspace: (monitor?.lastIpcObject.specialWorkspace?.name.length ?? 0) > 0
	readonly property alias interactionWrapper: interactions
	readonly property alias menuRegion: menuPopoutRegion
	readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
	property var root: Quickshell.shellDir
	readonly property real sdfBorderOffset: 2 * fsTransitionProg
	readonly property real shadowOpacity: 0.7 * (1 - fsTransitionProg)
	property color surfaceColor: DynamicColors.tPalette.m3surface

	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.settings ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
	WlrLayershell.layer: (fsTransitionProg > 0 && Config.general.showOverFullscreen) || (hasSpecialWorkspace && hasFullscreenOnNormalWs) ? WlrLayer.Overlay : WlrLayer.Top
	color: "transparent"
	contentItem.focus: true
	mask: visibilities.isDrawing ? null : (hasFullscreen ? emptyRegion : region)
	name: "Bar"

	Behavior on fsTransitionProg {
		Anim {
		}
	}
	Behavior on surfaceColor {
		CAnim {
		}
	}

	contentItem.Keys.onEscapePressed: {
		if (Config.barConfig.autoHide)
			visibilities.bar = false;
		visibilities.launcher = false;
		visibilities.sidebar = false;
		visibilities.dashboard = false;
		visibilities.osd = false;
		visibilities.settings = false;
		visibilities.resources = false;
		visibilities.dock = false;
		visibilities.clipboard = false;
		panels.popouts.hasCurrent = false;
	}
	onHasFullscreenChanged: {
		visibilities.launcher = false;
		visibilities.sidebar = false;
		visibilities.dashboard = false;
		visibilities.osd = false;
		visibilities.settings = false;
		visibilities.resources = false;
		visibilities.clipboard = false;
		visibilities.dock = false;
		panels.popouts.hasCurrent = false;
	}

	Region {
		id: menuPopoutRegion

		intersection: Intersection.Subtract
	}

	Region {
		id: emptyRegion

		height: panels.notifications.height
		width: panels.notifications.width
		x: panels.notifications.x + root.borderThickness
		y: panels.notifications.y + bar.implicitHeight
	}

	Region {
		id: region

		height: root.height - bar.implicitHeight - root.borderThickness - root.dragMaskPadding * 2
		intersection: Intersection.Xor
		regions: [...popoutRegions.instances, menuPopoutRegion]
		width: root.width - root.borderThickness * 2 - root.dragMaskPadding * 2
		x: root.borderThickness + root.dragMaskPadding
		y: bar.implicitHeight + root.dragMaskPadding
	}

	anchors {
		bottom: true
		left: true
		right: true
		top: true
	}

	Variants {
		id: popoutRegions

		model: panels.children

		Region {
			required property Item modelData

			height: modelData.height
			intersection: Intersection.Subtract
			width: modelData.width
			x: modelData.x + root.borderThickness
			y: modelData.y + bar.implicitHeight
		}
	}

	HyprlandFocusGrab {
		id: focusGrab

		active: visibilities.dock || visibilities.resources || visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || visibilities.clipboard || (panels.popouts.hasCurrent && panels.popouts.currentName.startsWith("traymenu"))
		windows: [root]

		onCleared: {
			visibilities.launcher = false;
			visibilities.sidebar = false;
			visibilities.dashboard = false;
			visibilities.osd = false;
			visibilities.settings = false;
			visibilities.resources = false;
			visibilities.clipboard = false;
			visibilities.dock = false;
			panels.popouts.hasCurrent = false;
		}
	}

	PersistentProperties {
		id: visibilities

		property bool bar
		property bool clipboard
		property bool dashboard
		property bool dock
		property bool isDrawing
		property bool launcher
		property bool notif: NotifServer.popups.length > 0
		property bool osd
		property bool resources
		property bool settings
		property bool sidebar

		Component.onCompleted: Visibilities.load(root.screen, this)
	}

	IpcHandler {
		function toggleLauncher(fix: string): void {
			visibilities.launcher = !visibilities.launcher;
		}

		target: "visibilities"
	}

	Binding {
		property: "bar"
		target: visibilities
		value: visibilities.sidebar || visibilities.dashboard || visibilities.osd || (!Config.barConfig.hideWhenNotif && visibilities.notif) || visibilities.resources || visibilities.settings || bar.isHovered
		when: Config.barConfig.autoHide
	}

	Item {
		id: surface

		anchors.fill: parent
		layer.enabled: true
		opacity: root.surfaceColor.a

		layer.effect: MultiEffect {
			blurMax: 32
			shadowColor: Qt.alpha(DynamicColors.palette.m3shadow, Math.max(0, root.shadowOpacity))
			shadowEnabled: true
		}

		BlobGroup {
			id: blobGroup

			color: root.surfaceColor
			smoothing: Config.barConfig.smoothing
		}

		BlobInvertedRect {
			anchors.fill: parent
			anchors.margins: -50
			borderBottom: root.borderThickness - anchors.margins - root.sdfBorderOffset
			borderLeft: root.borderThickness - anchors.margins - root.sdfBorderOffset
			borderRight: root.borderThickness - anchors.margins - root.sdfBorderOffset
			borderTop: bar.implicitHeight - anchors.margins - root.sdfBorderOffset
			group: blobGroup
			radius: root.borderRounding
		}

		PanelBg {
			id: dashBg

			property real extraHeight: 0.2

			deformAmount: 0.06
			implicitHeight: panels.dashboard.height * (1 + extraHeight)
			implicitWidth: panels.dashboard.width
			panel: panels.dashboardWrapper
			radius: Appearance.rounding.normal
			x: panels.dashboardWrapper.x + panels.dashboard.x + root.borderThickness
			y: panels.dashboardWrapper.y + panels.dashboard.y + bar.implicitHeight - panels.dashboard.height * extraHeight
		}

		PanelBg {
			id: launcherBg

			property real extraHeight: 0.2

			deformAmount: 0.06
			implicitHeight: panels.launcher.height * (1 + extraHeight)
			panel: panels.launcher
			radius: Appearance.rounding.smallest + 5
			y: panels.launcher.y + bar.implicitHeight
		}

		PanelBg {
			id: sidebarBg

			bottomLeftRadius: 0
			deformAmount: 0.04
			exclude: panels.sidebar.offsetScale > 0.08 ? [] : [utilsBg]
			implicitHeight: panel.height * (1 / rawDeformMatrix.m22) + 2
			panel: panels.sidebar
		}

		PanelBg {
			id: osdBg

			deformAmount: 0.1
			implicitHeight: panels.osd.height
			implicitWidth: panels.osd.width
			panel: panels.osdWrapper
			radius: 20
			x: panels.osdWrapper.x + panels.osd.x + root.borderThickness
			y: panels.osdWrapper.y + panels.osd.y + bar.implicitHeight
		}

		PanelBg {
			id: notifsBg

			panel: panels.notifications
			radius: Appearance.rounding.normal
		}

		PanelBg {
			id: utilsBg

			deformAmount: 0.1
			exclude: panels.sidebar.offsetScale > 0.08 ? [] : [sidebarBg]
			panel: panels.utilities
			topLeftRadius: 0
		}

		PanelBg {
			id: popoutBg

			property real extraHeight: 0.2

			deformAmount: panels.popouts.currentName.startsWith("traymenu") ? 0.15 : 0.08
			implicitHeight: panels.popouts.height * (1 + extraHeight)
			implicitWidth: panels.popouts.width
			panel: panels.popoutsWrapper
			radius: panels.popouts.current?.panelRadius ?? Appearance.rounding.normal
			x: panels.popoutsWrapper.x + panels.popouts.x + root.borderThickness
			y: panels.popoutsWrapper.y + panels.popouts.y + bar.implicitHeight - panels.popouts.height * extraHeight

			Behavior on extraHeight {
				Anim {
				}
			}
		}

		PanelBg {
			id: resourcesBg

			deformAmount: 0.05
			implicitHeight: panels.resources.height
			implicitWidth: panels.resources.width
			panel: panels.resourcesWrapper
			radius: Appearance.rounding.large
			x: panels.resourcesWrapper.x + panels.resources.x + root.borderThickness
			y: panels.resourcesWrapper.y + panels.resources.y + bar.implicitHeight
		}

		PanelBg {
			id: settingsBg

			property real extraHeight: 0

			deformAmount: 0.03
			implicitHeight: panels.settings.height * (1 + extraHeight)
			implicitWidth: panels.settings.width
			panel: panels.settingsWrapper
			radius: Appearance.rounding.large + Appearance.padding.normal
			x: panels.settingsWrapper.x + panels.settings.x + root.borderThickness
			y: panels.settingsWrapper.y + panels.settings.y + bar.implicitHeight - panels.settings.height * extraHeight
		}

		PanelBg {
			id: dockBg

			deformAmount: 0.08
			panel: panels.dock
			radius: Appearance.rounding.normal
		}

		PanelBg {
			id: drawingBg

			deformAmount: 0.08
			panel: panels.drawing
			radius: Appearance.rounding.normal
		}

		PanelBg {
			id: clipboardBg

			deformAmount: 0.03
			panel: panels.clipboard
			radius: 29
		}
	}

	Drawing {
		id: drawing

		anchors.fill: parent
		layer.enabled: true
		visibilities: visibilities
		z: 2

		layer.effect: MultiEffect {
			maskEnabled: true
			maskInverted: true
			maskSource: maskSource
		}
	}

	Item {
		id: maskSource

		anchors.fill: parent
		layer.enabled: true
		visible: false

		CustomRect {
			readonly property int extraWidth: radius

			color: "white"
			implicitHeight: panels.drawing.height
			implicitWidth: panels.drawing.width + extraWidth
			radius: drawingBg.radius
			x: -extraWidth + root.borderThickness + panels.drawing.x
			y: panels.drawing.y + bar.implicitHeight
		}
	}

	Interactions {
		id: interactions

		anchors.fill: parent
		bar: bar
		borderThickness: root.borderLayoutThickness
		drawing: drawing
		enabled: true
		panels: panels
		popouts: panels.popouts
		screen: root.screen
		visibilities: visibilities

		Panels {
			id: panels

			bar: bar
			borderThickness: root.borderThickness
			drawingItem: drawing
			screen: root.screen
			visibilities: visibilities

			clipboard.transform: Matrix4x4 {
				matrix: clipboardBg.deformMatrix
			}
			dashboard.transform: Matrix4x4 {
				matrix: dashBg.deformMatrix
			}
			dock.transform: Matrix4x4 {
				matrix: dockBg.deformMatrix
			}
			launcher.transform: Matrix4x4 {
				matrix: launcherBg.deformMatrix
			}
			notifications.transform: Matrix4x4 {
				matrix: notifsBg.deformMatrix
			}
			osd.transform: Matrix4x4 {
				matrix: osdBg.deformMatrix
			}
			popouts.transform: Matrix4x4 {
				matrix: popoutBg.deformMatrix
			}
			resources.transform: Matrix4x4 {
				matrix: resourcesBg.deformMatrix
			}
			settingsWrapper.transform: Matrix4x4 {
				matrix: settingsBg.deformMatrix
			}
			sidebar.transform: Matrix4x4 {
				matrix: sidebarBg.deformMatrix
			}
			utilities.transform: Matrix4x4 {
				matrix: utilsBg.deformMatrix
			}
		}

		BarLoader {
			id: bar

			anchors.left: parent.left
			anchors.right: parent.right
			enabled: !visibilities.isDrawing
			fullscreen: root.hasFullscreen
			popouts: panels.popouts
			popoutsWrapper: panels.popoutsWrapper
			screen: root.screen
			visibilities: visibilities
		}
	}

	component PanelBg: BlobRect {
		property real deformAmount: 0.15
		required property Item panel

		deformScale: (deformAmount * Config.appearance.deform.scale) / 10000
		group: blobGroup
		implicitHeight: panel.height
		implicitWidth: panel.width
		radius: Appearance.rounding.smallest
		x: panel.x + root.borderThickness
		y: panel.y + bar.implicitHeight
	}
}
