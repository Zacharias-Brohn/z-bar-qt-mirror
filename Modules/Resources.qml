pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import ZShell.Services
import qs.Helpers
import qs.Modules
import qs.Config
import qs.Components

CustomRect {
	id: root

	required property PersistentProperties visibilities

	clip: true
	color: visibilities.resources ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.bar.height + Appearance.padding.smallest * 2
	implicitWidth: rowLayout.implicitWidth + Appearance.padding.larger * 2
	radius: Appearance.rounding.full

	StateLayer {
		color: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

		onClicked: root.visibilities.resources = !root.visibilities.resources
	}

	RowLayout {
		id: rowLayout

		anchors.centerIn: parent
		anchors.horizontalCenterOffset: -2
		implicitHeight: root.implicitHeight
		spacing: Appearance.spacing.smaller

		ServiceRef {
			service: Gpu
		}

		ServiceRef {
			service: Cpu
		}

		ServiceRef {
			service: Memory
		}

		Resource {
			Layout.alignment: Qt.AlignVCenter
			Layout.fillHeight: true
			icon: "memory"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3primary
			percentage: Cpu.percentage
			warningThreshold: 95
		}

		Resource {
			Layout.fillHeight: true
			icon: "memory_alt"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3secondary
			percentage: Memory.percentage
			warningThreshold: 80
		}

		Resource {
			Layout.fillHeight: true
			icon: "gamepad"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3tertiary
			percentage: Gpu.percentage
		}

		Resource {
			Layout.fillHeight: true
			icon: "developer_board"
			iconColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			mainColor: root.visibilities.resources ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3primary
			percentage: Gpu.memoryUsed / Gpu.memoryTotal
		}
	}
}
