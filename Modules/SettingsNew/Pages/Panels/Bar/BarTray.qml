pragma ComponentBehavior: Bound

import QtQuick.Layouts
import qs.Config
import qs.Modules.SettingsNew.Common

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
			last: true
			stepSize: 1
			text: qsTr("Icon size")
			to: 24
			value: Config.bar.tray.trayIconSize

			onMoved: value => Config.bar.tray.trayIconSize = value
		}
	}
}
