import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Modules
import qs.Helpers
import qs.Components

CustomRect {
	id: root

	required property RowLayout loader
	required property Wrapper popouts
	required property PersistentProperties visibilities

	color: visibilities.dashboard ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.bar.height + Appearance.padding.smallest * 2
	implicitWidth: timeText.contentWidth + Appearance.padding.normal * 2
	radius: Appearance.rounding.full

	CustomText {
		id: timeText

		anchors.centerIn: parent
		color: root.visibilities.dashboard ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
		font: Appearance.font.family.mono // qmllint disable incompatible-type
		text: Time.dateStr

		Behavior on color {
			CAnim {
			}
		}
	}

	StateLayer {
		acceptedButtons: Qt.LeftButton
		color: root.visibilities.dashboard ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

		onClicked: {
			root.visibilities.dashboard = !root.visibilities.dashboard;
		}
	}
}
