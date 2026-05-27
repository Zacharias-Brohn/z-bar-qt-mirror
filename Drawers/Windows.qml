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
import qs.Modules
import qs.Modules.Bar
import qs.Config
import qs.Helpers
import qs.Drawers

Variants {
	model: Quickshell.screens

	Scope {
		id: scope

		required property var modelData

		Exclusions {
			bar: bar
			screen: scope.modelData
		}

		CustomWindow {
			id: win

			readonly property bool hasFullscreen: Hypr.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2)
			property var root: Quickshell.shellDir

			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			// WlrLayershell.keyboardFocus: visibilities.dock || visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || visibilities.resources ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
			color: "transparent"
			contentItem.focus: true
			mask: visibilities.isDrawing ? null : region
			name: "Bar"
			screen: scope.modelData

			contentItem.Keys.onEscapePressed: {
				if (Config.barConfig.autoHide)
					visibilities.bar = false;
				visibilities.sidebar = false;
				visibilities.dashboard = false;
				visibilities.osd = false;
				visibilities.settings = false;
				visibilities.resources = false;
			}
			onHasFullscreenChanged: {
				visibilities.launcher = false;
				visibilities.dashboard = false;
				visibilities.osd = false;
				visibilities.settings = false;
				visibilities.resources = false;
			}

			Region {
				id: region

				height: win.height - bar.implicitHeight - Config.barConfig.border
				intersection: Intersection.Xor
				regions: popoutRegions.instances
				width: win.width - Config.barConfig.border * 2
				x: Config.barConfig.border
				y: bar.implicitHeight
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
					x: modelData.x + Config.barConfig.border
					y: modelData.y + bar.implicitHeight
				}
			}

			HyprlandFocusGrab {
				id: focusGrab

				active: visibilities.dock || visibilities.resources || visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || (panels.popouts.hasCurrent && panels.popouts.currentName.startsWith("traymenu"))
				windows: [win]

				onCleared: {
					visibilities.launcher = false;
					visibilities.sidebar = false;
					visibilities.dashboard = false;
					visibilities.osd = false;
					visibilities.settings = false;
					visibilities.resources = false;
					visibilities.dock = false;
					panels.popouts.hasCurrent = false;
				}
			}

			PersistentProperties {
				id: visibilities

				property bool bar
				property bool dashboard
				property bool dock
				property bool isDrawing
				property bool launcher
				property bool notif: NotifServer.popups.length > 0
				property bool osd
				property bool resources
				property bool settings
				property bool sidebar

				Component.onCompleted: Visibilities.load(scope.modelData, this)
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
				anchors.fill: parent
				layer.enabled: true
				opacity: Appearance.transparency.enabled ? DynamicColors.transparency.base : 1

				layer.effect: MultiEffect {
					blurMax: 32
					shadowColor: Qt.alpha(DynamicColors.palette.m3shadow, 1)
					shadowEnabled: true
				}

				BlobGroup {
					id: blobGroup

					color: DynamicColors.palette.m3surface
					smoothing: Config.barConfig.smoothing

					Behavior on color {
						CAnim {
						}
					}
				}

				BlobInvertedRect {
					anchors.fill: parent
					anchors.margins: -50
					borderBottom: Config.barConfig.border - anchors.margins
					borderLeft: Config.barConfig.border - anchors.margins
					borderRight: Config.barConfig.border - anchors.margins
					borderTop: bar.implicitHeight - anchors.margins
					group: blobGroup
					radius: Config.barConfig.rounding
				}

				PanelBg {
					id: dashBg

					property real extraHeight: 0.2

					deformAmount: 0.06
					implicitHeight: panels.dashboard.height * (1 + extraHeight)
					implicitWidth: panels.dashboard.width
					panel: panels.dashboardWrapper
					radius: Appearance.rounding.normal
					x: panels.dashboardWrapper.x + panels.dashboard.x + Config.barConfig.border
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
					x: panels.osdWrapper.x + panels.osd.x + Config.barConfig.border
					y: panels.osdWrapper.y + panels.osd.y + bar.implicitHeight
				}

				PanelBg {
					id: notifsBg

					panel: panels.notifications
					radius: Appearance.rounding.normal
				}

				PanelBg {
					id: utilsBg

					deformAmount: panels.sidebar.visible ? (0.1) : (0.1)
					exclude: panels.sidebar.offsetScale > 0.08 ? [] : [sidebarBg]
					panel: panels.utilities
					topLeftRadius: 0
				}

				PanelBg {
					id: popoutBg

					property real extraHeight: panels.popouts.isDetached ? 0 : 0.2

					deformAmount: panels.popouts.isDetached ? 0.05 : panels.popouts.hasCurrent ? 0.15 : 0.1
					implicitHeight: panels.popouts.height * (1 + extraHeight)
					implicitWidth: panels.popouts.width
					panel: panels.popoutsWrapper
					radius: (panels.popouts.currentName.startsWith("audio") || panels.popouts.currentName.startsWith("updates")) ? Appearance.rounding.normal : 20 * Appearance.rounding.scale
					x: panels.popoutsWrapper.x + panels.popouts.x + Config.barConfig.border
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
					radius: Appearance.rounding.normal
					x: panels.resourcesWrapper.x + panels.resources.x + Config.barConfig.border
					y: panels.resourcesWrapper.y + panels.resources.y + bar.implicitHeight
				}

				PanelBg {
					id: settingsBg

					property real extraHeight: 0.2

					deformAmount: 0.03
					implicitHeight: panels.settings.height * (1 + extraHeight)
					implicitWidth: panels.settings.width
					panel: panels.settings
					radius: Appearance.rounding.large
					topLeftRadius: Appearance.rounding.large + Appearance.padding.smaller
					topRightRadius: Appearance.rounding.large + Appearance.padding.smaller
					x: panels.settingsWrapper.x + panels.settings.x + Config.barConfig.border
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
			}

			Loader {
				id: drawingLoader

				active: visibilities.isDrawing

				sourceComponent: Drawing {
					id: drawing

					anchors.fill: parent
					z: 2
				}
			}

			Loader {
				id: inputLoader

				active: visibilities.isDrawing

				sourceComponent: DrawingInput {
					id: input

					bar: bar
					drawing: drawingLoader.item
					panels: panels
					popout: panels.drawing
					visibilities: visibilities
					z: 2
				}
			}

			Interactions {
				id: mouseArea

				anchors.fill: parent
				bar: bar
				drawing: drawingLoader.item
				input: inputLoader.item
				panels: panels
				popouts: panels.popouts
				screen: scope.modelData
				visibilities: visibilities
				z: 1

				Panels {
					id: panels

					bar: bar
					drawingItem: drawingLoader.item
					screen: scope.modelData
					visibilities: visibilities

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
					settings.transform: Matrix4x4 {
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
					popouts: panels.popouts
					popoutsWrapper: panels.popoutsWrapper
					screen: scope.modelData
					visibilities: visibilities
				}
			}
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
		x: panel.x + Config.barConfig.border
		y: panel.y + bar.implicitHeight
	}
}
