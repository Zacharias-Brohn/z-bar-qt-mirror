pragma Singleton

import QtQuick
import Quickshell

Singleton {
	id: root

	readonly property list<var> pages: [
		// Appearance
		{
			name: qsTr("Appearance"),
			icon: "colors",
			description: qsTr("Colors, animations, font, wallpaper"),
			category: "appearance"
		},
		{
			name: qsTr("Screenshot"),
			icon: "screenshot_region",
			description: qsTr("Set screenshot effects"),
			category: "appearance"
		},

		// Connectivity
		{
			name: qsTr("Network"),
			icon: "wifi",
			description: qsTr("Wi-Fi, ethernet"),
			category: "connectivity"
		},
		{
			name: qsTr("Connected devices"),
			icon: "devices_other",
			description: qsTr("Bluetooth, pairing"),
			category: "connectivity"
		},
		{
			name: qsTr("Audio"),
			icon: "volume_up",
			description: qsTr("App volumes, sound devices"),
			category: "connectivity"
		},

		// Shell
		{
			name: qsTr("Panels"),
			icon: "dock_to_bottom",
			description: qsTr("Bar, dashboard, launcher, sidebar"),
			category: "shell"
		},
		{
			name: qsTr("Apps"),
			icon: "apps",
			description: qsTr("Default apps, favorites, hidden apps"),
			category: "shell"
		},
		{
			name: qsTr("Services"),
			icon: "build",
			description: qsTr("Poll intervals, audio and brightness increments"),
			category: "shell"
		},
	]
}
