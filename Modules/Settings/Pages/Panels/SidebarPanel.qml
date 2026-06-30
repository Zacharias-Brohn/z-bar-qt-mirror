pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Sidebar")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		SectionHeader {
			first: true
			text: qsTr("General")
		}

		ToggleRow {
			checked: Config.sidebar.enabled
			first: true
			text: qsTr("Enabled")

			onToggled: Config.sidebar.enabled = checked
		}

		SpinRow {
			from: 0
			last: true
			stepSize: 5
			subtext: qsTr("Pixels dragged before the sidebar opens")
			text: qsTr("Drag threshold")
			to: 200
			value: Config.sidebar.dragThreshold

			onMoved: v => Config.sidebar.dragThreshold = v
		}
	}
}
