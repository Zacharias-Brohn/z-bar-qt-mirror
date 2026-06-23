pragma ComponentBehavior: Bound

import QtQuick.Layouts
import qs.Config
import qs.Modules.SettingsNew.Common

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
			checked: Config.barConfig.autoHide
			first: true
			last: true
			subtext: qsTr("Hide the bar, reveal on hover")
			text: qsTr("Auto hide")

			onToggled: Config.barConfig.autoHide = checked
		}

		// Components
		SectionHeader {
			text: qsTr("Components")
		}

		NavRow {
			first: true
			icon: "workspaces"
			label: qsTr("Workspaces")
			status: qsTr("Indicators, window icons")

			onClicked: root.sState.openSubPage(5)
		}

		NavRow {
			icon: "web_asset"
			label: qsTr("Active window")
			status: qsTr("Title display, popout")

			onClicked: root.sState.openSubPage(6)
		}

		NavRow {
			icon: "widgets"
			label: qsTr("Tray")
			status: qsTr("System tray icons")

			onClicked: root.sState.openSubPage(7)
		}

		NavRow {
			icon: "signal_cellular_alt"
			label: qsTr("Status icons")
			status: qsTr("Visible indicators")

			onClicked: root.sState.openSubPage(8)
		}

		NavRow {
			icon: "schedule"
			label: qsTr("Clock")
			last: true
			status: qsTr("Date, icon, background")

			onClicked: root.sState.openSubPage(9)
		}
	}
}
