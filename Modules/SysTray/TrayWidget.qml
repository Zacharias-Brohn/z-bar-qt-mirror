pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.Components
import qs.Config
import qs.Modules.SysTray.Widgets
import qs.Modules

RowLayout {
	id: root

	readonly property alias items: repeater
	required property RowLayout loader
	required property Wrapper popouts

	function closestRowChild(row, x) {
		let child = row.childAt(x, row.height / 2);
		if (child)
			return child;

		let closest = null;
		let closestDistance = Infinity;

		for (let i = 0; i < row.children.length; ++i) {
			let c = row.children[i];

			if (!c.visible || c.width <= 0)
				continue;

			let centerX = c.x + c.width / 2;
			let dist = Math.abs(x - centerX);

			if (dist < closestDistance) {
				closestDistance = dist;
				closest = c;
			}
		}

		return closest;
	}

	function getHoveredSubItem(localX, localY) {
		let modPos = mapToItem(sysTrayMod, localX, localY);
		if (sysTrayMod.contains(Qt.point(modPos.x, modPos.y))) {
			let modRowPos = sysTrayMod.mapToItem(sysModRow, modPos.x, modPos.y);
			let child = closestRowChild(sysModRow, modRowPos.x);
			if (child) {
				if (child.objectName === "audioWidget" && Config.bar.popouts.audio)
					return {
						id: "audio",
						item: child
					};
				if (child.objectName === "upowerWidget" && Config.bar.popouts.upower)
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

	height: Config.bar.height + Appearance.padding.smallest * 2
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
		implicitWidth: sysModRow.implicitWidth + Appearance.padding.smaller + Appearance.padding.normal
		radius: Appearance.rounding.full
		topLeftRadius: Appearance.rounding.smallest / 2

		RowLayout {
			id: sysModRow

			anchors.fill: parent
			anchors.leftMargin: Appearance.padding.smaller
			anchors.rightMargin: Appearance.padding.normal

			AudioWidget {
				Layout.fillHeight: true
				Layout.rightMargin: hasContent ? Appearance.spacing.extraSmall / 2 : 0
				objectName: "audioWidget"

				Behavior on Layout.rightMargin {
					Anim {
						type: Anim.FastEffects
					}
				}
			}

			UPowerWidget {
				Layout.fillHeight: true
				objectName: "upowerWidget"
			}
		}
	}
}
