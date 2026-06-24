import Quickshell
import QtQuick
import qs.Config
import qs.Daemons
import qs.Components

CustomRect {
	id: root

	required property Wrapper popouts
	required property PersistentProperties visibilities

	color: visibilities.sidebar ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.bar.height + Appearance.padding.smallest * 2
	implicitWidth: implicitHeight
	radius: Appearance.rounding.full

	MaterialIcon {
		id: notificationCenterIcon

		anchors.centerIn: parent
		color: root.visibilities.sidebar ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
		fill: root.visibilities.sidebar ? 1 : 0
		font.family: "Material Symbols Rounded"
		font.pointSize: Appearance.font.size.larger
		text: NotifServer.list.length ? "\uf4fe" : "\ue7f4"

		Behavior on color {
			CAnim {
			}
		}
		Behavior on fill {
			Anim {
			}
		}
	}

	StateLayer {
		color: root.visibilities.sidebar ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

		onClicked: {
			root.visibilities.sidebar = !root.visibilities.sidebar;
		}
	}
}
