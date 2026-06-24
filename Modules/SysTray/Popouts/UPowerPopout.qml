pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower
import qs.Config
import qs.Helpers
import qs.Components

Column {
	id: root

	readonly property int panelRadius: ((profiles.height / 2) + Appearance.padding.small) * Appearance.rounding.scale

	spacing: Appearance.spacing.normal

	Loader {
		active: Battery.isLaptop

		CustomText {
			text: qsTr("Remaining: %1%").arg(Math.round(UPower.displayDevice.percentage * 100))
		}
	}

	CustomText {
		function formatSeconds(s: int, fallback: string): string {
			const day = Math.floor(s / 86400);
			const hr = Math.floor(s / 3600) % 60;
			const min = Math.floor(s / 60) % 60;

			let comps = [];
			if (day > 0)
				comps.push(`${day} days`);
			if (hr > 0)
				comps.push(`${hr} hours`);
			if (min > 0)
				comps.push(`${min} mins`);

			return comps.join(", ") || fallback;
		}

		anchors.left: parent.left
		anchors.leftMargin: Appearance.padding.normal
		text: Battery.isLaptop ? qsTr("Time %1: %2").arg(Battery.onBattery ? "remaining" : "until charged").arg(Battery.onBattery ? formatSeconds(Battery.timeToEmpty, "Calculating...") : formatSeconds(Battery.timeToFull, "Fully charged!")) : qsTr("Power profile: %1").arg(PowerProfile.toString(PowerProfiles.profile))
	}

	Loader {
		active: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
		anchors.horizontalCenter: parent.horizontalCenter
		asynchronous: true
		height: active ? ((item as Item)?.implicitHeight ?? 0) : 0

		sourceComponent: CustomRect {
			color: DynamicColors.palette.m3error
			implicitHeight: child.implicitHeight + Appearance.padding.large
			implicitWidth: child.implicitWidth + Appearance.padding.larger * 2
			radius: Appearance.rounding.large

			Column {
				id: child

				anchors.centerIn: parent

				Row {
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: Appearance.spacing.small

					MaterialIcon {
						anchors.verticalCenter: parent.verticalCenter
						anchors.verticalCenterOffset: -font.pointSize / 10
						color: DynamicColors.palette.m3onError
						text: "warning"
					}

					CustomText {
						anchors.verticalCenter: parent.verticalCenter
						color: DynamicColors.palette.m3onError
						font.family: Appearance.font.family.mono
						text: qsTr("Performance Degraded")
					}

					MaterialIcon {
						anchors.verticalCenter: parent.verticalCenter
						anchors.verticalCenterOffset: -font.pointSize / 10
						color: DynamicColors.palette.m3onError
						text: "warning"
					}
				}

				CustomText {
					anchors.horizontalCenter: parent.horizontalCenter
					color: DynamicColors.palette.m3onError
					text: qsTr("Reason: %1").arg(PerformanceDegradationReason.toString(PowerProfiles.degradationReason))
				}
			}
		}
	}

	CustomRect {
		id: profiles

		property string current: {
			const p = PowerProfiles.profile;
			if (p === PowerProfile.PowerSaver)
				return saver.icon;
			if (p === PowerProfile.Performance)
				return perf.icon;
			return balance.icon;
		}

		anchors.horizontalCenter: parent.horizontalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: indicator.height + Appearance.padding.extraSmall * 2
		implicitWidth: saver.implicitHeight + balance.implicitHeight + perf.implicitHeight + Appearance.padding.larger * 2 + Appearance.spacing.small * 8
		radius: Appearance.rounding.full

		CustomRect {
			id: indicator

			color: DynamicColors.palette.m3primary
			radius: Appearance.rounding.full
			state: profiles.current

			states: [
				State {
					name: saver.icon

					Fill {
						item: saver
					}
				},
				State {
					name: balance.icon

					Fill {
						item: balance
					}
				},
				State {
					name: perf.icon

					Fill {
						item: perf
					}
				}
			]
			transitions: Transition {
				AnchorAnim {
				}
			}
		}

		Profile {
			id: saver

			anchors.left: parent.left
			anchors.leftMargin: Appearance.padding.extraSmall
			anchors.verticalCenter: parent.verticalCenter
			icon: "energy_savings_leaf"
			profile: PowerProfile.PowerSaver
		}

		Profile {
			id: balance

			anchors.centerIn: parent
			icon: "balance"
			profile: PowerProfile.Balanced
		}

		Profile {
			id: perf

			anchors.right: parent.right
			anchors.rightMargin: Appearance.padding.extraSmall
			anchors.verticalCenter: parent.verticalCenter
			icon: "bolt"
			profile: PowerProfile.Performance
		}
	}

	component Fill: AnchorChanges {
		required property Item item

		anchors.bottom: item.bottom
		anchors.left: item.left
		anchors.right: item.right
		anchors.top: item.top
		target: indicator
	}
	component Profile: Item {
		required property string icon
		required property int profile

		implicitHeight: icon.implicitHeight + Appearance.padding.small
		implicitWidth: icon.implicitHeight + Appearance.padding.small

		StateLayer {
			color: profiles.current === parent.icon ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			radius: Appearance.rounding.full

			onClicked: {
				PowerProfiles.profile = parent.profile;
			}
		}

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			color: profiles.current === text ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			fill: profiles.current === text ? 1 : 0
			font.pointSize: Appearance.font.size.large * 2
			grade: DynamicColors.light ? 0 : (text === "balance" ? -25 : 0)
			text: parent.icon

			Behavior on fill {
				Anim {
					type: Anim.DefaultEffects
				}
			}
		}
	}
}
