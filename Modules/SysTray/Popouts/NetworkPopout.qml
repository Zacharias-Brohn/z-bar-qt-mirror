pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules
import qs.Helpers as Helpers

Item {
	id: root

	required property var wrapper

	implicitHeight: networkPop.implicitHeight
	implicitWidth: networkPop.implicitWidth

	CustomRect {
		id: networkPop

		anchors.horizontalCenter: parent.horizontalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 500 + 5 * 2
		implicitWidth: 500 + 8 * 2
		radius: (20 - Appearance.padding.small) * Appearance.rounding.scale

		Item {
			id: networkPopContent

			anchors.fill: parent
			anchors.margins: Appearance.padding.small

			// text {
			// 	font.pixelSize: 20
			// 	text: qsTr("Network Settings")
			// }
		}
	}
}
