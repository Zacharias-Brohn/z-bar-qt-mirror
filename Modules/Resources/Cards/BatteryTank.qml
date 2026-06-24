import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.Components
import qs.Config

CustomClippingRect {
	id: root

	property real animPerc: UPower.displayDevice.percentage

	color: DynamicColors.palette.m3secondaryContainer
	implicitWidth: 120
	radius: Appearance.rounding.large

	Behavior on animPerc {
		Anim {
		}
	}

	Contents {
		id: layout

		accentColor: DynamicColors.palette.m3primary
		anchors.fill: parent
		anchors.margins: Appearance.padding.larger
		subTextColor: DynamicColors.palette.m3onSurfaceVariant
		textColor: DynamicColors.palette.m3onSurface
	}

	CustomRect {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		clip: true
		color: DynamicColors.palette.m3secondary
		implicitHeight: parent.height * root.animPerc
		radius: Appearance.rounding.extraSmall

		Contents {
			accentColor: DynamicColors.palette.m3primaryContainer
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.margins: layout.anchors.margins
			anchors.right: parent.right
			height: layout.height
			subTextColor: DynamicColors.palette.m3secondaryContainer
			textColor: DynamicColors.palette.m3onSecondary
		}
	}

	component Contents: ColumnLayout {
		id: contents

		required property color accentColor
		readonly property bool charging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state)
		required property color subTextColor
		required property color textColor

		spacing: 0

		MaterialIcon {
			Layout.leftMargin: -Appearance.padding.extraSmall
			color: contents.accentColor
			text: "battery_full"
		}

		CustomText {
			Layout.fillWidth: true
			color: contents.textColor
			text: qsTr("Battery")
		}

		Item {
			Layout.fillHeight: true
		}

		CustomText {
			Layout.alignment: Qt.AlignRight
			animate: true
			color: contents.subTextColor
			text: {
				if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
					return qsTr("Full");

				if (contents.charging)
					return qsTr("Charging");

				const s = UPower.displayDevice.timeToEmpty;
				if (s === 0)
					return qsTr("...");

				const hr = Math.floor(s / 3600);
				const min = Math.floor((s % 3600) / 60);
				if (hr > 0)
					return `${hr}h ${min}m`;

				return `${min}m`;
			}
		}

		RowLayout {
			Layout.alignment: Qt.AlignRight
			Layout.bottomMargin: -Appearance.padding.small
			Layout.rightMargin: -Appearance.padding.extraSmall
			Layout.topMargin: -Appearance.padding.extraSmall
			spacing: Appearance.spacing.extraSmall

			MaterialIcon {
				color: contents.accentColor
				fill: 1
				opacity: contents.charging ? 1 : 0
				scale: contents.charging ? 1 : 0
				text: "bolt"

				Behavior on opacity {
					Anim {
						type: Anim.FastEffects
					}
				}
				Behavior on scale {
					Anim {
						type: Anim.FastSpatial
					}
				}
			}

			CustomText {
				color: contents.accentColor
				text: `${Math.round(UPower.displayDevice.percentage * 100)}%`
			}
		}
	}
}
