import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	readonly property bool shouldBeActive: Config.bar.tray.showPower

	Layout.preferredHeight: shouldBeActive ? implicitHeight : 0
	Layout.preferredWidth: shouldBeActive ? implicitWidth : 0
	implicitHeight: Battery.isLaptop ? batteryIconLoader.item.implicitHeight : upowerIconLoader.item.implicitHeight
	implicitWidth: Battery.isLaptop ? batteryIconLoader.item.implicitWidth : upowerIconLoader.item.implicitWidth
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0
	visible: opacity > 0

	Behavior on Layout.preferredHeight {
		Anim {
		}
	}
	Behavior on Layout.preferredWidth {
		Anim {
		}
	}
	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}

	Loader {
		id: batteryIconLoader

		active: Battery.isLaptop
		anchors.centerIn: parent

		sourceComponent: Row {
			id: batteryIcon

			property real batHeight: 16
			property real batWidth: 30
			property real nubHeight: 6
			property real nubWidth: 2
			property real radius: Appearance.rounding.smallest / 2

			spacing: 1

			CustomRect {
				id: track

				anchors.verticalCenter: parent.verticalCenter
				color: Battery.colors.bg
				height: batteryIcon.batHeight
				radius: batteryIcon.radius
				width: batteryIcon.batWidth

				CustomText {
					color: Battery.colors.fg
					font.pointSize: Appearance.font.size.larger / 1.5
					font.weight: 800
					height: track.height
					horizontalAlignment: Text.AlignHCenter
					text: Math.round(Battery.currentPerc * 100)
					verticalAlignment: Text.AlignVCenter
					width: track.width
				}

				Item {
					clip: true
					width: parent.width * Battery.currentPerc

					anchors {
						bottom: parent.bottom
						left: parent.left
						top: parent.top
					}

					CustomRect {
						id: fill

						color: Battery.colors.fg
						height: track.height
						radius: track.radius
						width: track.width

						CustomText {
							id: batteryLabel

							clip: true
							color: Battery.colors.bg
							font.pointSize: 7.5
							font.weight: 800
							height: track.height
							horizontalAlignment: Text.AlignHCenter
							text: Math.round(Battery.currentPerc * 100)
							verticalAlignment: Text.AlignVCenter
							width: track.width
						}
					}
				}
			}

			CustomRect {
				id: nub

				anchors.verticalCenter: parent.verticalCenter
				bottomRightRadius: 20
				color: Battery.currentPerc < 0.99 ? track.color : fill.color
				height: batteryIcon.nubHeight
				topRightRadius: 20
				width: batteryIcon.nubWidth
			}
		}
	}

	Loader {
		id: upowerIconLoader

		active: !Battery.isLaptop
		anchors.centerIn: parent

		sourceComponent: MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			animate: true
			fill: 1
			text: {
				if (PowerProfiles.profile === PowerProfile.PowerSaver)
					return "energy_savings_leaf";
				if (PowerProfiles.profile === PowerProfile.Performance)
					return "bolt";
				return "balance";
			}
		}
	}
}
