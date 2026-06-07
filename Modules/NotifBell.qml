import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

CustomRect {
	id: root

	required property Wrapper popouts
	required property PersistentProperties visibilities

	color: visibilities.sidebar ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: implicitHeight
	radius: Appearance.rounding.full

	MaterialIcon {
		id: notificationCenterIcon

		anchors.centerIn: parent
		color: root.visibilities.sidebar ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
		font.family: "Material Symbols Rounded"
		font.pointSize: Appearance.font.size.larger
		text: HasNotifications.hasNotifications ? "\uf4fe" : "\ue7f4"

		Behavior on color {
			CAnim {
			}
		}
	}

	StateLayer {
		onClicked: {
			root.visibilities.sidebar = !root.visibilities.sidebar;
		}
	}
}
