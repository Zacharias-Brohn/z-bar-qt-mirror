pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Helpers
import qs.Modules
import qs.Config
import qs.Components

CustomRect {
	id: root

	required property PersistentProperties visibilities

	clip: true
	color: visibilities.resources ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: rowLayout.implicitWidth + Appearance.padding.normal * 2
	radius: Appearance.rounding.full

	StateLayer {
		onClicked: root.visibilities.resources = !root.visibilities.resources
	}

	RowLayout {
		id: rowLayout

		anchors.centerIn: parent
		implicitHeight: root.implicitHeight
		spacing: Appearance.spacing.smaller

		Ref {
			service: SystemUsage
		}

		Resource {
			Layout.alignment: Qt.AlignVCenter
			Layout.fillHeight: true
			icon: "memory"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3primary
			percentage: SystemUsage.cpuPerc
			warningThreshold: 95
		}

		Resource {
			Layout.fillHeight: true
			icon: "memory_alt"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3secondaryContainer : DynamicColors.palette.m3secondary
			percentage: SystemUsage.memPerc
			warningThreshold: 80
		}

		Resource {
			Layout.fillHeight: true
			icon: "gamepad"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3tertiaryContainer : DynamicColors.palette.m3tertiary
			percentage: SystemUsage.gpuPerc
		}

		Resource {
			Layout.fillHeight: true
			icon: "developer_board"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3primary
			percentage: SystemUsage.gpuMemUsed
		}
	}
}
