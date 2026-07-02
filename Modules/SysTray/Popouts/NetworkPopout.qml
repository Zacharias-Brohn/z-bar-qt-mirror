pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Config
import qs.Helpers

CustomClippingRect {
	id: root

	required property var wrapper

	anchors.horizontalCenter: parent.horizontalCenter
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: networkPopContent.height + networks.implicitHeight + networkPopContent.anchors.margins + networks.anchors.margins * 2
	implicitWidth: 500 + 8 * 2
	radius: (20 - Appearance.padding.small) * Appearance.rounding.scale

	Component.onCompleted: Network.active = true
	Component.onDestruction: Network.active = false

	ColumnLayout {
		id: networkPopContent

		anchors.left: parent.left
		anchors.margins: Appearance.padding.large
		anchors.right: parent.right
		anchors.top: parent.top

		CustomText {
			Layout.preferredHeight: visible ? implicitHeight : 0
			Layout.rightMargin: Appearance.padding.extraSmall
			font.pointSize: Appearance.font.size.large
			text: qsTr("Wifi")
		}

		Toggle {
			Layout.preferredHeight: visible ? implicitHeight : 0
			checked: Network.wifiEnabled
			label: qsTr("WiFi enabled")

			toggle.onToggled: Network.setWifi(checked)
		}

		CustomText {
			Layout.preferredHeight: visible ? implicitHeight : 0
			Layout.rightMargin: Appearance.padding.extraSmall
			Layout.topMargin: visible ? Appearance.spacing.small : 0
			color: DynamicColors.palette.m3onSurfaceVariant
			text: qsTr("%1 networks available").arg(Network.networks.length) // qmllint disable missing-property
		}
	}

	ColumnLayout {
		id: networks

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: Appearance.padding.normal
		anchors.right: parent.right
		anchors.top: networkPopContent.bottom

		CustomText {
			Layout.leftMargin: Appearance.padding.normal
			text: qsTr("Known networks")
		}

		Repeater {
			model: ScriptModel {
				values: [...Network.knownNetworks].sort((a, b) => {
					return b.signalStrength - a.signalStrength;
				})
			}

			NetworkItem {
			}
		}

		Item {
			id: spacer

			Layout.preferredHeight: networkRepeater.count > 0 ? Appearance.spacing.extraSmall : 0
		}

		CustomText {
			Layout.leftMargin: Appearance.padding.normal
			text: qsTr("Networks")
		}

		Repeater {
			id: networkRepeater

			model: ScriptModel {
				values: [...Network.unknownNetworks].sort((a, b) => {
					return b.signalStrength - a.signalStrength;
				})
			}

			NetworkItem {
			}
		}
	}

	component NetworkItem: CustomRect {
		id: knownNetworkItem

		required property var modelData

		Layout.fillWidth: true
		Layout.preferredHeight: visible ? knownNetworkRow.implicitHeight + Appearance.padding.smaller * 2 : 0
		Layout.rightMargin: Appearance.padding.extraSmall
		radius: Appearance.rounding.small

		RowLayout {
			id: knownNetworkRow

			anchors.fill: parent
			anchors.leftMargin: Appearance.padding.larger
			anchors.rightMargin: Appearance.padding.normal
			opacity: 0
			scale: 0.7
			spacing: Appearance.spacing.small

			Behavior on opacity {
				Anim {
					type: Anim.DefaultEffects
				}
			}
			Behavior on scale {
				Anim {
				}
			}

			Component.onCompleted: {
				opacity = 1;
				scale = 1;
			}

			MaterialIcon {
				color: knownNetworkItem.modelData.active ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
				text: Icons.getNetworkIcon(knownNetworkItem.modelData.signalStrength * 100, Network.isSecure(knownNetworkItem.modelData.security))
			}

			CustomText {
				Layout.fillWidth: true
				Layout.leftMargin: Appearance.spacing.extraSmall
				Layout.rightMargin: Appearance.spacing.extraSmall
				color: knownNetworkItem.modelData.active ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
				elide: Text.ElideRight
				text: knownNetworkItem.modelData.name
			}

			CustomRect {
				color: Qt.alpha(DynamicColors.palette.m3primary, knownNetworkItem.modelData.active ? 1 : 0)
				implicitHeight: knownWirelessConnectIcon.implicitHeight + Appearance.padding.extraSmall
				implicitWidth: implicitHeight
				radius: Appearance.rounding.full

				// CircularIndicator {
				//     anchors.fill: parent
				//     running: knownNetworkItem.loading
				// }
			}
		}

		StateLayer {
			color: knownNetworkItem.modelData.active ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

			onClicked: {}
		}
	}
	component Toggle: RowLayout {
		property alias checked: toggle.checked
		required property string label
		property alias toggle: toggle

		Layout.fillWidth: true
		Layout.rightMargin: Appearance.padding.extraSmall
		spacing: Appearance.spacing.small

		CustomText {
			Layout.fillWidth: true
			text: parent.label
		}

		CustomSwitch {
			id: toggle
		}
	}
}
