pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
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
			WlrLayershell.keyboardFocus: visibilities.dock || visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || visibilities.resources ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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

					deformAmount: 0.1
					panel: panels.dashboard
					radius: Appearance.rounding.normal
				}

				PanelBg {
					id: launcherBg

					deformAmount: 0.1
					panel: panels.launcher
					radius: Appearance.rounding.smallest + 5
				}

				PanelBg {
					id: sidebarBg

					bottomLeftRadius: 0
					deformAmount: 0.03
					exclude: panels.sidebar.offsetscale > 0.08 ? [] : [utilsBg]
					implicitHeight: panel.height * (1 / rawDeformMatrix.m22) + 2
					panel: panels.sidebar
				}

				PanelBg {
					id: osdBg

					deformAmount: 0.25
					panel: panels.osd
					radius: 20
				}

				PanelBg {
					id: notifsBg

					panel: panels.notifications
				}

				PanelBg {
					id: utilsBg

					deformAmount: panels.sidebar.visible ? 0.1 : 0.15
					exclude: panels.sidebar.offsetScale > 0.08 ? [] : [sidebarBg]
					panel: panels.utilities
					topLeftRadius: 0
				}

				PanelBg {
					id: popoutBg

					deformAmount: 0.15
					implicitWidth: panels.popouts.width
					panel: panels.popoutsWrapper
				}

				PanelBg {
					id: resourcesBg

					deformAmount: 0.15
					panel: panels.resources
					radius: Appearance.rounding.normal
				}
			}

			Drawing {
				id: drawing

				anchors.fill: parent
				z: 2
			}

			DrawingInput {
				id: input

				bar: bar
				drawing: drawing
				panels: panels
				popout: panels.drawing
				visibilities: visibilities
				z: 2
			}

			Interactions {
				id: mouseArea

				anchors.fill: parent
				bar: bar
				drawing: drawing
				input: input
				panels: panels
				popouts: panels.popouts
				screen: scope.modelData
				visibilities: visibilities
				z: 1

				Panels {
					id: panels

					bar: bar
					drawingItem: drawing
					screen: scope.modelData
					visibilities: visibilities

					dashboard.transform: Matrix4x4 {
						matrix: dashBg.deformMatrix
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

		deformScale: deformAmount / 10000
		group: panel.width > 0 && panel.height > 0 ? blobGroup : null
		implicitHeight: panel.height
		implicitWidth: panel.width
		radius: Appearance.rounding.smallest
		x: panel.x + Config.barConfig.border
		y: panel.y + bar.implicitHeight
	}
}
