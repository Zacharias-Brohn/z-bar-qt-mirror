import QtQuick
import QtQuick.Layouts
import ZShell.Services
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: layout.implicitWidth + layout.anchors.margins * 4

	ServiceRef {
		service: Storage
	}

	ServiceRef {
		service: Memory
	}

	ServiceRef {
		service: Cpu
	}

	ServiceRef {
		service: Gpu
	}

	ColumnLayout {
		id: layout

		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.margins: Appearance.padding.large
		anchors.top: parent.top
		spacing: Appearance.spacing.normal

		Resource {
			fgColor: DynamicColors.palette.m3primary
			icon: "memory"
			value: Cpu.percentage
		}

		Resource {
			fgColor: DynamicColors.palette.m3secondary
			icon: "memory_alt"
			value: Memory.percentage
		}

		Resource {
			fgColor: DynamicColors.palette.m3tertiary
			icon: "gamepad"
			value: Gpu.percentage
		}

		Resource {
			fgColor: DynamicColors.palette.m3primary
			icon: "host"
			value: Gpu.memoryUsed / Gpu.memoryTotal
		}

		Resource {
			fgColor: DynamicColors.palette.m3secondary
			icon: "hard_disk"
			value: Storage.percentage
		}
	}

	component Resource: CircularProgress {
		id: res

		required property string icon

		Layout.fillHeight: true
		implicitSize: height

		Behavior on clampedVal {
			Anim {
			}
		}

		MaterialIcon {
			anchors.centerIn: parent
			color: res.fgColor
			text: res.icon
		}
	}
}
