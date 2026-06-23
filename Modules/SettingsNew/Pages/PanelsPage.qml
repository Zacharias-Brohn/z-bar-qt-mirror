import QtQuick.Layouts
import qs.Config
import qs.Modules.SettingsNew.Common

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
			icon: "dashboard"
			label: qsTr("Dashboard")
			status: Config.dashboard.enabled ? qsTr("Enabled") : qsTr("Disabled")

			onClicked: root.sState.openSubPage(1)
		}

		NavRow {
			icon: "dock_to_bottom"
			label: qsTr("Taskbar")
			status: !Config.barConfig.autoHide ? qsTr("Always visible") : qsTr("Reveal on hover")

			onClicked: root.sState.openSubPage(2)
		}

		NavRow {
			icon: "apps"
			label: qsTr("Launcher")
			status: Config.launcher.enabled ? qsTr("Enabled") : qsTr("Disabled")

			onClicked: root.sState.openSubPage(3)
		}

		NavRow {
			icon: "dock_to_right"
			label: qsTr("Sidebar")
			last: true
			status: Config.sidebar.enabled ? qsTr("Enabled") : qsTr("Disabled")

			onClicked: root.sState.openSubPage(4)
		}
	}
}
