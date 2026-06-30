import QtQuick.Layouts
import qs.Config
import qs.Modules.Settings.Common

PageBase {
	id: root

	title: qsTr("Panels")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		NavRow {
			first: true
			icon: "dock_to_bottom"
			status: !Config.bar.autoHide ? qsTr("Always visible") : qsTr("Reveal on hover")
			text: qsTr("Bar")

			onClicked: root.sState.openSubPage(1)
		}

		NavRow {
			icon: "dashboard"
			status: Config.dashboard.enabled ? qsTr("Enabled") : qsTr("Disabled")
			text: qsTr("Dashboard")

			onClicked: root.sState.openSubPage(2)
		}

		NavRow {
			icon: "insert_chart"
			status: Config.dashboard.performance.enabled ? qsTr("Enabled") : qsTr("Disabled")
			text: qsTr("Resources")

			onClicked: root.sState.openSubPage(3)
		}

		NavRow {
			icon: "apps"
			status: Config.launcher.enabled ? qsTr("Enabled") : qsTr("Disabled")
			text: qsTr("Launcher")

			onClicked: root.sState.openSubPage(4)
		}

		NavRow {
			icon: "dock_to_right"
			last: true
			status: Config.sidebar.enabled ? qsTr("Enabled") : qsTr("Disabled")
			text: qsTr("Sidebar")

			onClicked: root.sState.openSubPage(5)
		}
	}
}
