pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Resources")

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
			checked: Config.dashboard.performance.enabled
			first: true
			last: true
			text: qsTr("Enabled")

			onToggled: Config.dashboard.performance.enabled = checked
		}

		// Performance widgets
		SectionHeader {
			text: qsTr("Performance widgets")
		}

		ToggleRow {
			checked: Config.dashboard.performance.showBattery
			first: true
			text: qsTr("Battery")

			onToggled: Config.dashboard.performance.showBattery = checked
		}

		ToggleRow {
			checked: Config.dashboard.performance.showGpu
			text: qsTr("GPU")

			onToggled: Config.dashboard.performance.showGpu = checked
		}

		ToggleRow {
			checked: Config.dashboard.performance.showCpu
			text: qsTr("CPU")

			onToggled: Config.dashboard.performance.showCpu = checked
		}

		ToggleRow {
			checked: Config.dashboard.performance.showMemory
			text: qsTr("Memory")

			onToggled: Config.dashboard.performance.showMemory = checked
		}

		ToggleRow {
			checked: Config.dashboard.performance.showStorage
			text: qsTr("Storage")

			onToggled: Config.dashboard.performance.showStorage = checked
		}

		ToggleRow {
			checked: Config.dashboard.performance.showNetwork
			last: true
			text: qsTr("Network")

			onToggled: Config.dashboard.performance.showNetwork = checked
		}
	}
}
