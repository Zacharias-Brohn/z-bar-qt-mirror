pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules
import qs.Helpers

CustomClippingRect {
	id: root

	required property var wrapper

	anchors.horizontalCenter: parent.horizontalCenter
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: 500 + 5 * 2
	implicitWidth: 500 + 8 * 2
	radius: (20 - Appearance.padding.small) * Appearance.rounding.scale

	Item {
		id: networkPopContent

		anchors.fill: parent
		anchors.margins: Appearance.padding.small

		CustomText {
			anchors.left: parent.left
			anchors.margins: Appearance.padding.large
			anchors.top: parent.top
			font.pointSize: Appearance.font.size.large
			text: qsTr("Network")
		}

		StateLayer {
			id: buttonScan

			onClicked: {
				console.log(Network.network.length);
			}
		}
	}
}
