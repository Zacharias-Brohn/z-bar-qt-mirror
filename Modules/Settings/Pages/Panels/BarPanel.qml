pragma ComponentBehavior: Bound

import QtQuick.Layouts
import qs.Config
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Taskbar")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Behavior
		SectionHeader {
			first: true
			text: qsTr("Behavior")
		}

		ToggleRow {
			checked: Config.bar.autoHide
			first: true
			last: true
			settingAnchor: "bar-autohide"
			subtext: qsTr("Hide the bar, reveal on hover")
			text: qsTr("Auto hide")

			onToggled: Config.bar.autoHide = checked
		}

		// Components
		SectionHeader {
			text: qsTr("Components")
		}

		NavRow {
			first: true
			icon: "widgets"
			settingAnchor: "bar-tray"
			status: qsTr("System tray icons")
			text: qsTr("Tray")

			onClicked: root.sState.openSubPage(6)
		}

		NavRow {
			icon: "signal_cellular_alt"
			settingAnchor: "bar-statusicons"
			status: qsTr("Visible indicators")
			text: qsTr("Status icons")

			onClicked: root.sState.openSubPage(7)
		}

		NavRow {
			icon: "schedule"
			last: true
			settingAnchor: "bar-clock"
			status: qsTr("Date, icon, background")
			text: qsTr("Clock")

			onClicked: root.sState.openSubPage(8)
		}
	}
}
