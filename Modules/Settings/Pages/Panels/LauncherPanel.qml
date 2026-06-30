pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Launcher")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// General
		SectionHeader {
			first: true
			text: qsTr("General")
		}

		ToggleRow {
			checked: Config.launcher.enabled
			first: true
			last: true
			settingAnchor: "launcher-enabled"
			text: qsTr("Enabled")

			onToggled: Config.launcher.enabled = checked
		}

		// Display
		SectionHeader {
			text: qsTr("Display")
		}

		SpinRow {
			first: true
			from: 1
			settingAnchor: "launcher-max-items-shown"
			stepSize: 1
			text: qsTr("Max items shown")
			to: 20
			value: Config.launcher.maxAppsShown

			onMoved: v => Config.launcher.maxShown = v
		}

		SpinRow {
			from: 1
			settingAnchor: "launcher-max-wallpapers"
			stepSize: 1
			text: qsTr("Max wallpapers")
			to: 30
			value: Config.launcher.maxWallpapers

			onMoved: v => Config.launcher.maxWallpapers = v
		}

		SpinRow {
			from: 0
			last: true
			settingAnchor: "launcher-drag-threshold"
			stepSize: 5
			subtext: qsTr("Pixels dragged before the launcher opens")
			text: qsTr("Drag threshold")
			to: 200
			value: Config.launcher.dragThreshold

			onMoved: v => Config.launcher.dragThreshold = v
		}

		// Behavior
		SectionHeader {
			text: qsTr("Behavior")
		}

		ToggleRow {
			checked: Config.launcher.enableDangerousActions
			first: true
			last: true
			settingAnchor: "launcher-enable-dangerous-actions"
			subtext: qsTr("Allow actions that shut down or log out")
			text: qsTr("Enable dangerous actions")

			onToggled: Config.launcher.enableDangerousActions = checked
		}

		// Fuzzy search
		SectionHeader {
			text: qsTr("Fuzzy search")
		}

		ToggleRow {
			checked: Config.launcher.useFuzzy.apps
			first: true
			settingAnchor: "launcher-apps"
			text: qsTr("Apps")

			onToggled: Config.launcher.useFuzzy.apps = checked
		}

		ToggleRow {
			checked: Config.launcher.useFuzzy.actions
			settingAnchor: "launcher-actions"
			text: qsTr("Actions")

			onToggled: Config.launcher.useFuzzy.actions = checked
		}

		ToggleRow {
			checked: Config.launcher.useFuzzy.variants
			settingAnchor: "launcher-variants"
			text: qsTr("Variants")

			onToggled: Config.launcher.useFuzzy.variants = checked
		}

		ToggleRow {
			checked: Config.launcher.useFuzzy.wallpapers
			last: true
			settingAnchor: "launcher-wallpapers"
			text: qsTr("Wallpapers")

			onToggled: Config.launcher.useFuzzy.wallpapers = checked
		}
	}
}
