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
			text: qsTr("Network")
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
		anchors.margins: Appearance.padding.large
		anchors.right: parent.right
		anchors.top: networkPopContent.bottom

		Repeater {
			model: ScriptModel {
				values: [...Network.networks]
			}

			RowLayout {
				id: networkItem

				required property var modelData

				Layout.fillWidth: true
				Layout.preferredHeight: visible ? implicitHeight : 0
				Layout.rightMargin: Appearance.padding.extraSmall
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
					color: networkItem.modelData.active ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
					text: Icons.getNetworkIcon(networkItem.modelData.signalStrength * 100, Network.isSecure(networkItem.modelData.security))
				}

				CustomText {
					Layout.fillWidth: true
					Layout.leftMargin: Appearance.spacing.extraSmall
					Layout.rightMargin: Appearance.spacing.extraSmall
					color: networkItem.modelData.active ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
					elide: Text.ElideRight
					text: networkItem.modelData.name
				}

				CustomRect {
					color: Qt.alpha(DynamicColors.palette.m3primary, networkItem.modelData.active ? 1 : 0)
					implicitHeight: wirelessConnectIcon.implicitHeight + Appearance.padding.extraSmall
					implicitWidth: implicitHeight
					radius: Appearance.rounding.full

					// CircularIndicator {
					//     anchors.fill: parent
					//     running: networkItem.loading
					// }

					StateLayer {
						color: networkItem.modelData.active ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

						onClicked: {
							console.log(Network.devices[1].scannerEnabled, Network.devices[2].scannerEnabled, Network.devices[3].scannerEnabled, Network.devices[4].scannerEnabled);
						}
					}

					MaterialIcon {
						id: wirelessConnectIcon

						anchors.centerIn: parent
						animate: true
						color: networkItem.modelData.active ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
						text: networkItem.modelData.active ? "link_off" : "link"

						// opacity: networkItem.loading ? 0 : 1

						Behavior on opacity {
							Anim {
								type: Anim.DefaultEffects
							}
						}
					}
				}
			}
		}

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: visible ? implicitHeight : 0
			Layout.topMargin: visible ? Appearance.spacing.small : 0
			color: DynamicColors.palette.m3primaryContainer
			implicitHeight: rescanBtn.implicitHeight + Appearance.padding.small
			radius: Appearance.rounding.full

			StateLayer {
				color: DynamicColors.palette.m3onPrimaryContainer
				enabled: !Network.scanning

				onClicked: Network.rescanWifi()
			}

			RowLayout {
				id: rescanBtn

				anchors.centerIn: parent
				opacity: Network.scanning ? 0 : 1
				spacing: Appearance.spacing.small

				Behavior on opacity {
					Anim {
						type: Anim.DefaultEffects
					}
				}

				MaterialIcon {
					id: scanIcon

					Layout.topMargin: Math.round(fontInfo.pointSize * 0.0575)
					animate: true
					color: DynamicColors.palette.m3onPrimaryContainer
					text: "wifi_find"
				}

				CustomText {
					Layout.topMargin: -Math.round(scanIcon.fontInfo.pointSize * 0.0575)
					color: DynamicColors.palette.m3onPrimaryContainer
					text: qsTr("Rescan networks")
				}
			}

			CircularIndicator {
				anchors.centerIn: parent
				bgColor: "transparent"
				implicitSize: parent.implicitHeight - Appearance.padding.large
				running: Network.scanning
				strokeWidth: Appearance.padding.extraSmall / 2
			}
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
