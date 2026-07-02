pragma ComponentBehavior: Bound

import QtQuick.Layouts
import qs.Config
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("System icons")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Visible icons
		SectionHeader {
			first: true
			text: qsTr("Visible icons")
		}

		ToggleRow {
			checked: Config.bar.tray.showAudio
			first: true
			settingAnchor: "bar-status-speakers"
			text: qsTr("Speakers")

			onToggled: Config.bar.tray.showAudio = checked
		}

		ToggleRow {
			checked: Config.bar.tray.showMicrophone
			settingAnchor: "bar-status-mic"
			text: qsTr("Microphone")

			onToggled: Config.bar.tray.showMicrophone = checked
		}

		ToggleRow {
			checked: Config.bar.tray.showNetwork
			text: qsTr("Network")

			onToggled: Config.bar.tray.showNetwork = checked
		}

		//////// FOR LATER:
		//
		// ToggleRow {
		// 	checked: Config.bar.tray.showWifi
		// 	text: qsTr("Wi-Fi")
		//
		// 	onToggled: Config.bar.tray.showWifi = checked
		// }
		//
		// ToggleRow {
		// 	checked: Config.bar.tray.showBluetooth
		// 	text: qsTr("Bluetooth")
		//
		// 	onToggled: Config.bar.tray.showBluetooth = checked
		// }

		ToggleRow {
			checked: Config.bar.tray.showPower
			last: true
			settingAnchor: "bar-status-power"
			text: qsTr("Battery")

			onToggled: Config.bar.tray.showPower = checked
		}

		// Behaviour
		SectionHeader {
			text: qsTr("Behavior")
		}

		ToggleRow {
			checked: Config.bar.popouts.audio
			first: true
			settingAnchor: "bar-status-audio-popout"
			subtext: qsTr("Show a details popout when hovering the audio icons")
			text: qsTr("Audio popout on hover")

			onToggled: Config.bar.popouts.audio = checked
		}

		ToggleRow {
			checked: Config.bar.popouts.upower
			last: true
			settingAnchor: "bar-status-power-popout"
			subtext: qsTr("Show a details popout when hovering the power icon")
			text: qsTr("Power popout on hover")

			onToggled: Config.bar.popouts.upower = checked
		}

		ToggleRow {
			checked: Config.bar.popouts.network
			last: true
			settingAnchor: "bar-status-network-popout"
			subtext: qsTr("Show a details popout when hovering the network icon")
			text: qsTr("Network popout on hover")

			onToggled: Config.bar.popouts.network = checked
		}
	}
}
