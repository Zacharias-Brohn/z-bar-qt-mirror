import QtQuick
import QtQuick.Layouts
import Quickshell
import ZShell.Services
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	// GPU options + the config string each maps to (see Gpu::parseType)
	readonly property list<MenuItem> gpuItems: [
		MenuItem {
			text: qsTr("Auto")
		},
		MenuItem {
			text: "NVIDIA"
		},
		MenuItem {
			text: qsTr("Generic")
		},
		MenuItem {
			text: qsTr("None")
		}
	]
	readonly property list<string> gpuValues: ["", "NVIDIA", "GENERIC", "None"]

	function gpuKeyToIndex(key: string): int {
		const u = (key ?? "").trim().toUpperCase();
		if (u === "")
			return 0; // Auto
		if (u === "NVIDIA")
			return 1;
		if (u === "GENERIC")
			return 2;
		return 3; // None
	}

	title: qsTr("Services")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Detected running players, used as default-player options
		Variants {
			id: playerVariants

			model: [...new Set(Players.list.map(p => Players.getIdentity(p)).filter(id => id))]

			MenuItem {
				required property string modelData

				activeIcon: "music_note"
				icon: modelData === Config.services.defaultPlayer ? "check" : ""
				text: modelData
			}
		}

		// Notifications
		SectionHeader {
			first: true
			text: qsTr("Notifications")
		}

		NavRow {
			first: true
			icon: "notifications"
			last: true
			status: qsTr("Notifications, toasts, timeouts")
			text: qsTr("Notifications")

			onClicked: root.sState.openSubPage(1)
		}

		// Polling
		SectionHeader {
			text: qsTr("Polling")
		}

		SpinRow {
			first: true
			from: 100
			stepSize: 50
			subtext: qsTr("How often the media position updates (ms)")
			text: qsTr("Media refresh")
			to: 2000
			value: Config.dashboard.mediaUpdateInterval

			onMoved: v => Config.dashboard.mediaUpdateInterval = v
		}

		SpinRow {
			from: 0.5
			last: true
			stepSize: 0.5
			subtext: qsTr("CPU, memory and GPU update interval (seconds)")
			text: qsTr("System stats refresh")
			to: 10
			value: Config.dashboard.resourceUpdateInterval / 1000

			onMoved: v => Config.dashboard.resourceUpdateInterval = Math.round(v * 1000)
		}

		// Media & lyrics
		SectionHeader {
			text: qsTr("Media")
		}

		SelectRow {
			active: menuItems.find(i => i.text === Config.services.defaultPlayer) ?? null
			fallbackIcon: "music_note"
			fallbackText: Config.services.defaultPlayer || qsTr("Auto")
			first: true
			last: true
			menuItems: playerVariants.instances
			subtext: qsTr("Preferred media player when several are open")
			text: qsTr("Default player")

			onSelected: item => Config.services.defaultPlayer = item.text
		}

		// Input increments
		SectionHeader {
			text: qsTr("Input increments")
		}

		SpinRow {
			first: true
			from: 1
			stepSize: 1
			subtext: qsTr("Amount the volume changes per input (%)")
			text: qsTr("Volume step")
			to: 50
			value: Math.round(Config.services.audioIncrement * 100)

			onMoved: v => Config.services.audioIncrement = v / 100
		}

		SpinRow {
			from: 1
			stepSize: 1
			subtext: qsTr("Amount the brightness changes per input (%)")
			text: qsTr("Brightness step")
			to: 50
			value: Math.round(Config.services.brightnessIncrement * 100)

			onMoved: v => Config.services.brightnessIncrement = v / 100
		}

		SpinRow {
			from: 1
			stepSize: 1
			subtext: qsTr("Lowest allowed brightness (%)")
			text: qsTr("Brightness minimum")
			to: 20
			value: Math.round(Config.services.minBrightness * 100)

			onMoved: v => Config.services.minBrightness = v / 100
		}

		SpinRow {
			from: 50
			last: true
			stepSize: 5
			subtext: qsTr("Upper limit for output volume (%)")
			text: qsTr("Max volume")
			to: 200
			value: Math.round(Config.services.maxVolume * 100)

			onMoved: v => Config.services.maxVolume = v / 100
		}

		// Service tuning
		SectionHeader {
			text: qsTr("Service tuning")
		}

		SpinRow {
			first: true
			from: 10
			stepSize: 2
			subtext: qsTr("Resolution of the audio visualizer")
			text: qsTr("Visualizer resolution")
			to: 120
			value: Config.services.visualizerBars

			onMoved: v => Config.services.visualiserBars = v
		}

		ToggleRow {
			checked: Config.general.color.smart
			subtext: qsTr("Derive theme mode from the wallpaper")
			text: qsTr("Smart color scheme")

			onToggled: Config.general.color.smart = checked
		}

		SelectRow {
			active: root.gpuItems[root.gpuKeyToIndex(Config.services.gpuType)]
			last: true
			menuItems: root.gpuItems
			menuOnTop: true
			subtext: Gpu.name ? qsTr("Monitoring: %1").arg(Gpu.name) : qsTr("Override for GPU type")
			text: qsTr("GPU")

			onSelected: item => Config.services.gpuType = root.gpuValues[root.gpuItems.indexOf(item)]
		}
	}
}
