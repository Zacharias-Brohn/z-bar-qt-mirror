import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Notifications")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Notifications
		SectionHeader {
			first: true
			text: qsTr("Notifications")
		}

		ToggleRow {
			checked: Config.notifs.showInFullscreen
			first: true
			settingAnchor: "notif-show-in-fullscreen"
			subtext: qsTr("Whether notifications appear over fullscreen apps")
			text: qsTr("Show in fullscreen")

			onToggled: Config.notifs.showInFullscreen = checked
		}

		ToggleRow {
			checked: Config.notifs.expire
			settingAnchor: "notif-expire-automatically"
			subtext: qsTr("Dismiss notifications after their timeout")
			text: qsTr("Expire automatically")

			onToggled: Config.notifs.expire = checked
		}

		ToggleRow {
			checked: Config.notifs.openExpanded
			settingAnchor: "notif-open-expanded"
			subtext: qsTr("Show notifications expanded by default")
			text: qsTr("Open expanded")

			onToggled: Config.notifs.openExpanded = checked
		}

		SpinRow {
			from: 1000
			settingAnchor: "notif-default-timeout"
			stepSize: 500
			subtext: qsTr("Time before a notification dismisses (ms)")
			text: qsTr("Default timeout")
			to: 60000
			value: Config.notifs.defaultExpireTimeout

			onMoved: v => Config.notifs.defaultExpireTimeout = Math.round(v)
		}

		SpinRow {
			from: 1
			last: true
			settingAnchor: "notif-group-preview-count"
			stepSize: 1
			subtext: qsTr("Notifications shown per group before collapsing")
			text: qsTr("Group preview count")
			to: 10
			value: Config.notifs.groupPreviewNum

			onMoved: v => Config.notifs.groupPreviewNum = Math.round(v)
		}

		// Toasts
		SectionHeader {
			text: qsTr("Toasts")
		}

		SpinRow {
			first: true
			from: 1
			settingAnchor: "notif-visible-toasts"
			stepSize: 1
			subtext: qsTr("Maximum number of toasts shown at once")
			text: qsTr("Visible toasts")
			to: 10
			value: Config.utilities.maxToasts

			onMoved: v => Config.utilities.maxToasts = Math.round(v)
		}

		ToggleRow {
			checked: Config.utilities.toasts.chargingChanged
			settingAnchor: "notif-charging-changes"
			text: qsTr("Charging changes")

			onToggled: Config.utilities.toasts.chargingChanged = checked
		}

		ToggleRow {
			checked: Config.utilities.toasts.gameModeChanged
			settingAnchor: "notif-game-mode-changes"
			text: qsTr("Game mode changes")

			onToggled: Config.utilities.toasts.gameModeChanged = checked
		}

		// ToggleRow {
		// 	checked: Config.utilities.toasts.dndChanged
		// 	text: qsTr("Do not disturb changes")
		//
		// 	onToggled: Config.utilities.toasts.dndChanged = checked
		// }

		ToggleRow {
			checked: Config.utilities.toasts.audioOutputChanged
			settingAnchor: "notif-audio-output-changes"
			text: qsTr("Audio output changes")

			onToggled: Config.utilities.toasts.audioOutputChanged = checked
		}

		ToggleRow {
			checked: Config.utilities.toasts.audioInputChanged
			last: true
			settingAnchor: "notif-audio-input-changes"
			text: qsTr("Audio input changes")

			onToggled: Config.utilities.toasts.audioInputChanged = checked
		}

		// ToggleRow {
		// 	checked: Config.utilities.toasts.capsLockChanged
		// 	text: qsTr("Caps lock changes")
		//
		// 	onToggled: Config.utilities.toasts.capsLockChanged = checked
		// }
		//
		// ToggleRow {
		// 	checked: Config.utilities.toasts.numLockChanged
		// 	text: qsTr("Num lock changes")
		//
		// 	onToggled: Config.utilities.toasts.numLockChanged = checked
		// }
		//
		// ToggleRow {
		// 	checked: Config.utilities.toasts.kbLayoutChanged
		// 	text: qsTr("Keyboard layout changes")
		//
		// 	onToggled: Config.utilities.toasts.kbLayoutChanged = checked
		// }
		//
		// ToggleRow {
		// 	checked: Config.utilities.toasts.vpnChanged
		// 	text: qsTr("VPN changes")
		//
		// 	onToggled: Config.utilities.toasts.vpnChanged = checked
		// }
		//
		// ToggleRow {
		// 	checked: Config.utilities.toasts.nowPlaying
		// 	last: true
		// 	text: qsTr("Now playing")
		//
		// 	onToggled: Config.utilities.toasts.nowPlaying = checked
		// }
	}
}
