import QtQuick.Layouts
import QtQuick
import QtQuick.VectorImage
import Quickshell
import Quickshell.Services.SystemTray
import qs.Helpers
import qs.Modules
import qs.Components
import qs.Config

Item {
	id: root

	property bool current: popouts.currentName.startsWith(`traymenu${ind}`) && popouts.hasCurrent
	readonly property real dpr: Hypr.monitorFor(loader.screen).scale
	property bool hasLoaded: false
	required property int ind
	required property SystemTrayItem item
	required property RowLayout loader
	required property Wrapper popouts

	function resolveIcon(app: string, icon: string): string {
		if (app === "chrome_status_icon_1") {
			return Quickshell.iconPath("discord-tray");
		} else if (app === "AyuGramDesktop") {
			if (icon === Quickshell.iconPath("com.ayugram.desktop-attention-symbolic"))
				return Quickshell.iconPath("telegram-attention-panel");
			else if (icon === Quickshell.iconPath("com.ayugram.desktop-mute-symbolic"))
				return Quickshell.iconPath("telegram-mute-panel");
			else if (icon === Quickshell.iconPath("com.ayugram.desktop-symbolic"))
				return Quickshell.iconPath("telegram-panel");
		} else if (app === "TelegramDesktop") {
			if (icon === Quickshell.iconPath("org.telegram.desktop-symbolic"))
				return Quickshell.iconPath("telegram-panel");
			else if (icon === Quickshell.iconPath("org.telegram.desktop-attention-symbolic"))
				return Quickshell.iconPath("telegram-attention-panel");
			else if (icon === Quickshell.iconPath("org.telegram.desktop-mute-symbolic"))
				return Quickshell.iconPath("telegram-mute-panel");
		}

		return root.item.icon;
	}

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
					console.log(icon.source + "\n" + root.item.id);
				} else if (mouse.button === Qt.RightButton && Config.barConfig.popouts.tray) {
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
		antialiasing: true
		color: root.current ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
		implicitSize: 24 * root.dpr
		layer.enabled: Config.general.color.smart || Config.general.color.scheduleDark
		scale: 1 / root.dpr
		source: root.resolveIcon(root.item.id, root.item.icon)
	}
}
