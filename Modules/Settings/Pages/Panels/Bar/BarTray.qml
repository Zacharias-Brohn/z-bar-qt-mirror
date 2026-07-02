pragma ComponentBehavior: Bound

import QtQuick.Layouts
import qs.Config
import qs.Modules.Settings.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Tray")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		SpinRow {
			first: true
			from: 12
			settingAnchor: "bar-tray-iconsize"
			stepSize: 1
			text: qsTr("Icon size")
			to: 24
			value: Config.bar.tray.trayIconSize

			onMoved: value => Config.bar.tray.trayIconSize = value
		}

		ToggleRow {
			checked: Config.bar.tray.showOnHover
			settingAnchor: "bar-tray-show-popout-on-hover"
			subtext: Config.bar.tray.showOnHover ? qsTr("Will show context menu on hover") : qsTr("Will show context menu on right-click")
			text: qsTr("Show popout on hover")

			onToggled: Config.bar.tray.showOnHover = checked
		}

		ToggleRow {
			checked: Config.bar.tray.recolorIcons
			last: true
			settingAnchor: "bar-tray-recolor-icons"
			subtext: qsTr("Recolors icons to fit current scheme")
			text: qsTr("Recolor icons")

			onToggled: Config.bar.tray.recolorIcons = checked
		}
	}
}
