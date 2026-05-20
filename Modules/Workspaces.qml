pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Config
import qs.Components

Item {
	id: root

	property real activeWorkspaceMargin: Math.ceil(Appearance.padding.small / 2)
	readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
	readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
	required property ShellScreen screen
	property int workspaceButtonWidth: bgRect.implicitHeight - root.activeWorkspaceMargin * 2
	property int workspaceIndexInGroup: (effectiveActiveWorkspaceId - 1) % root.workspacesShown
	readonly property list<var> workspaces: Hyprland.workspaces.values.filter(w => w.monitor === root.monitor)
	readonly property int workspacesShown: workspaces.length

	height: implicitHeight
	implicitHeight: Config.barConfig.height + Appearance.padding.smaller * 2
	implicitWidth: (root.workspaceButtonWidth * root.workspacesShown) + root.activeWorkspaceMargin * 2

	Behavior on implicitWidth {
		Anim {
		}
	}

	CustomRect {
		id: bgRect

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: root.implicitHeight - ((Appearance.padding.small - 1) * 2)
		radius: height / 2

		Grid {
			id: grid

			anchors.fill: parent
			anchors.margins: root.activeWorkspaceMargin
			columnSpacing: 0
			columns: root.workspacesShown
			rowSpacing: 0
			rows: 1

			Repeater {
				model: root.workspaces

				Button {
					id: button

					required property int index
					required property HyprlandWorkspace modelData

					implicitHeight: indicator.indicatorThickness
					implicitWidth: indicator.indicatorThickness
					width: root.workspaceButtonWidth

					background: Item {
						id: workspaceButtonBackground

						implicitHeight: root.workspaceButtonWidth
						implicitWidth: root.workspaceButtonWidth

						CustomText {
							anchors.centerIn: parent
							color: DynamicColors.palette.m3onSecondaryContainer
							elide: Text.ElideRight
							horizontalAlignment: Text.AlignHCenter
							text: button.modelData.name
							verticalAlignment: Text.AlignVCenter
						}
					}

					onPressed: {
						const ws = button.modelData.name;
						Hyprland.dispatch(Hyprland.usingLua ? `hl.dsp.focus({ workspace= "${ws}"})` : `workspace ${ws}`);
					}
				}
			}
		}

		CustomRect {
			id: indicator

			property real indicatorLength: (Math.abs(idxPair.idx1 - idxPair.idx2) + 1) * root.workspaceButtonWidth
			property real indicatorPosition: Math.min(idxPair.idx1, idxPair.idx2) * root.workspaceButtonWidth + root.activeWorkspaceMargin
			property real indicatorThickness: root.workspaceButtonWidth

			anchors.verticalCenter: parent.verticalCenter
			clip: true
			color: DynamicColors.palette.m3primary
			implicitHeight: indicatorThickness
			implicitWidth: indicatorLength
			radius: Appearance.rounding.full
			x: indicatorPosition

			AnimatedTabIndexPair {
				id: idxPair

				index: root.workspaces.findIndex(w => w.active)
			}

			Coloriser {
				colorizationColor: DynamicColors.palette.m3onPrimary
				implicitHeight: grid.height
				implicitWidth: grid.width
				source: grid
				sourceColor: DynamicColors.palette.m3onSurface
				x: -indicator.x + 3
			}
		}
	}
}
