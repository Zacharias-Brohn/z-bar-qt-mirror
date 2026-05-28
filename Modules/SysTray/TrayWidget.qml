pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Components
import qs.Config
import qs.Modules.SysTray.Widgets
import qs.Modules.SysTray.Popouts
import qs.Modules

RowLayout {
	id: root

	readonly property alias items: repeater
	required property RowLayout loader
	required property Wrapper popouts

	function getHoveredSubItem(localX, localY) {
		let modPos = mapToItem(sysTrayMod, localX, localY);
		if (sysTrayMod.contains(Qt.point(modPos.x, modPos.y))) {
			let modRowPos = sysTrayMod.mapToItem(sysModRow, modPos.x, modPos.y);
			let child = sysModRow.childAt(modRowPos.x, modRowPos.y);
			if (child) {
				if (child.objectName === "audioWidget" && Config.barConfig.popouts.audio)
					return {
						id: "audio",
						item: child
					};
				if (child.objectName === "upowerWidget" && Config.barConfig.popouts.upower)
					return {
						id: "upower",
						item: child
					};
			}
		}

		let trayPos = mapToItem(sysTray, localX, localY);
		if (sysTray.contains(Qt.point(trayPos.x, trayPos.y))) {
			let trayRowPos = sysTray.mapToItem(sysRow, trayPos.x, trayPos.y);
			let child = sysRow.childAt(trayRowPos.x, trayRowPos.y);
			if (child && child.hasOwnProperty("popoutId")) {
				return {
					id: child.popoutId,
					item: child
				};
			}
		}

		return null;
	}

	height: Config.barConfig.height + Appearance.padding.smallest * 2
	spacing: Appearance.padding.small
	width: sysTray.implicitWidth + sysTrayMod.implicitWidth + Appearance.padding.small

	CustomClippingRect {
		id: sysTray

		Layout.fillHeight: true
		bottomRightRadius: Appearance.rounding.smallest / 2
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitWidth: sysRow.width + Appearance.padding.small * 2
		radius: Appearance.rounding.full
		topRightRadius: Appearance.rounding.smallest / 2

		Row {
			id: sysRow

			anchors.centerIn: parent
			spacing: 0

			Repeater {
				id: repeater

				model: SystemTray.items

				TrayItem {
					id: trayItem

					required property int index
					required property SystemTrayItem modelData

					implicitHeight: 34
					implicitWidth: 34
					ind: index
					item: modelData
					loader: root.loader
					popouts: root.popouts
				}
			}
		}
	}

	CustomClippingRect {
		id: sysTrayMod

		Layout.fillHeight: true
		bottomLeftRadius: Appearance.rounding.smallest / 2
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitWidth: sysModRow.width + Appearance.padding.smaller * 2
		radius: Appearance.rounding.full
		topLeftRadius: Appearance.rounding.smallest / 2

		Row {
			id: sysModRow

			anchors.centerIn: parent
			spacing: Appearance.padding.small

			AudioWidget {
				objectName: "audioWidget"
			}

			UPowerWidget {
				height: parent.height
				objectName: "upowerWidget"
			}
		}
	}
}
