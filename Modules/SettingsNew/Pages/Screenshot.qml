pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ZShell.Components
import qs.Helpers
import qs.Components
import qs.Config
import qs.Modules.SettingsNew
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	title: qsTr("Screenshot effects")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.large
		width: root.cappedWidth

		ToggleRow {
			checked: Config.screenshot.enable_pp
			first: true
			text: qsTr("Enable effects")

			onToggled: Config.screenshot.enable_pp = checked
		}

		SelectRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			active: Config.screenshot.mode === "manual" ? menuItems[0] : menuItems[1]
			enabled: Config.screenshot.enable_pp
			last: true
			subtext: qsTr("Automatic or manual effect values")
			text: qsTr("Effects mode")

			menuItems: [
				MenuItem {
					icon: "build"
					text: qsTr("Manual")
					value: "manual"
				},
				MenuItem {
					icon: "rotate_auto"
					text: qsTr("Auto")
					value: "auto"
				}
			]

			onSelected: item => {
				Config.screenshot.mode = item.value;
				Config.save();
			}
		}

		ToggleRow {
			checked: Config.screenshot.rounding
			enabled: Config.screenshot.enable_pp && Config.screenshot.mode === "manual"
			first: true
			text: qsTr("Enable rounded corners")

			onToggled: Config.screenshot.rounding = checked
		}

		SpinRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			enabled: Config.screenshot.enable_pp && Config.screenshot.mode === "manual" && Config.screenshot.rounding
			from: 0
			last: true
			stepSize: 1
			text: qsTr("Corner radius")
			to: 50
			value: Config.screenshot.radius

			onMoved: value => {
				const newVal = Math.floor(value);
				Config.screenshot.radius = newVal;
			}
		}

		ToggleRow {
			checked: Config.screenshot.shadow
			enabled: Config.screenshot.enable_pp && Config.screenshot.mode === "manual"
			first: true
			text: qsTr("Enable shadow")

			onToggled: Config.screenshot.shadow = checked
		}

		SpinRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			enabled: Config.screenshot.enable_pp && Config.screenshot.mode === "manual" && Config.screenshot.shadow
			from: 0
			stepSize: 1
			text: qsTr("Shadow blur amount")
			to: 100
			value: Config.screenshot.shadow_blur

			onMoved: value => {
				const newVal = Math.floor(value);
				Config.screenshot.shadow_blur = newVal;
			}
		}

		SpinRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			enabled: Config.screenshot.enable_pp && Config.screenshot.mode === "manual" && Config.screenshot.shadow
			from: -100
			stepSize: 10
			text: qsTr("Shadow horizontal offset")
			to: 100
			value: Config.screenshot.shadow_offset_x

			onMoved: value => {
				const newVal = Math.floor(value);
				Config.screenshot.shadow_offset_x = newVal;
			}
		}

		SpinRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			enabled: Config.screenshot.enable_pp && Config.screenshot.mode === "manual" && Config.screenshot.shadow
			from: -100
			last: true
			stepSize: 10
			text: qsTr("Shadow vertical offset")
			to: 100
			value: Config.screenshot.shadow_offset_y

			onMoved: value => {
				const newVal = Math.floor(value);
				Config.screenshot.shadow_offset_y = newVal;
			}
		}
	}
}
