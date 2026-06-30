pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Dashboard")

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
			checked: Config.dashboard.enabled
			first: true
			last: true
			text: qsTr("Enabled")

			onToggled: Config.dashboard.enabled = checked
		}
	}
}
