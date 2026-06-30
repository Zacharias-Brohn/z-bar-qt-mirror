pragma ComponentBehavior: Bound

import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules.Settings.Common

PageBase {
	id: root

	readonly property list<MenuItem> clockFormats: [
		MenuItem {
			text: qsTr("Long format")
			value: "dddd d MMM - hh:mm"
		},
		MenuItem {
			text: qsTr("Short format")
			value: "ddd d MMM - hh:mm"
		},
		MenuItem {
			text: qsTr("Time only")
			value: "hh:mm"
		},
		MenuItem {
			text: qsTr("Long format seconds")
			value: "dddd d MMM - hh:mm:ss"
		},
		MenuItem {
			text: qsTr("Short format seconds")
			value: "ddd d MMM - hh:mm:ss"
		},
		MenuItem {
			text: qsTr("Time only seconds")
			value: "hh:mm:ss"
		}
	]

	isSubPage: true
	title: qsTr("Clock")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		SelectRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			active: root.clockFormats.find(item => item.value === Config.general.dateFormat)
			first: true
			last: true
			menuItems: root.clockFormats
			settingAnchor: "bar-clock-format"
			subtext: qsTr("Change how time is displayed in the widget")
			text: qsTr("Time format")

			onSelected: item => {
				Config.general.dateFormat = item.value;
			}
		}
	}
}
