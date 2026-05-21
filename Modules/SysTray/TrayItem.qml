import QtQuick.Layouts
import QtQuick
import QtQuick.VectorImage
import Quickshell
import Quickshell.Services.SystemTray
import qs.Modules
import qs.Components
import qs.Config

Item {
	id: root

	property bool current: popouts.currentName.startsWith(`traymenu${ind}`) && popouts.hasCurrent
	property bool hasLoaded: false
	required property int ind
	required property SystemTrayItem item
	required property RowLayout loader
	required property Wrapper popouts

	CustomRect {
		anchors.fill: parent
		anchors.margins: 3
		color: root.current ? DynamicColors.palette.m3primary : "transparent"
		radius: Appearance.rounding.full

		StateLayer {
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			anchors.fill: parent

			onClicked: {
				if (mouse.button === Qt.LeftButton) {
					root.item.activate();
				} else if (mouse.button === Qt.RightButton) {
					root.popouts.currentName = `traymenu${root.ind}`;
					root.popouts.currentCenter = Qt.binding(() => root.mapToItem(root.loader, root.implicitWidth / 2, 0).x);
					root.popouts.hasCurrent = true;
					if (visibilities.sidebar || visibilities.dashboard || visibilities.settings) {
						visibilities.sidebar = false;
						visibilities.dashboard = false;
						visibilities.settings = false;
					}
				}
			}
		}
	}

	ColoredIcon {
		id: icon

		anchors.centerIn: parent
		color: root.current ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
		implicitSize: 22
		layer.enabled: Config.general.color.smart || Config.general.color.scheduleDark
		source: root.item.icon
	}
}
