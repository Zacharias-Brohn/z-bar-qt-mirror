import QtQuick
import qs.Components
import qs.Helpers
import qs.Config

CustomRect {
	id: root

	property bool tempEnabled: Hyprsunset.enabled

	color: root.tempEnabled ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: implicitHeight
	radius: Appearance.rounding.full

	StateLayer {
		onClicked: {
			Hyprsunset.toggleNightLight();
			Hyprsunset.manualToggle = true;
		}
	}

	MaterialIcon {
		anchors.centerIn: parent
		animate: true
		color: root.tempEnabled ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
		text: root.tempEnabled ? "lightbulb" : "light_off"
	}
}
