pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ZShell.Components
import qs.Helpers
import qs.Components
import qs.Config
import qs.Modules.SettingsNew
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	title: qsTr("Wallpaper & style")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.large
		width: root.cappedWidth

		CustomClippingRect {
			id: wallWrapper

			Layout.alignment: Qt.AlignHCenter
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitHeight: {
				const screen = root.sState.screen;
				const cWidth = root.cappedWidth;
				return Math.min(Math.round(cWidth * 0.4), cWidth / screen.width * screen.height);
			}
			implicitWidth: {
				const screen = root.sState.screen;
				return implicitHeight / screen.height * screen.width;
			}
			radius: Appearance.rounding.large

			Loader {
				active: opacity > 0
				anchors.centerIn: parent
				opacity: Config.background.enabled ? 0 : 1

				Behavior on opacity {
					Anim {
						type: Anim.SlowEffects
					}
				}
				sourceComponent: ColumnLayout {
					spacing: Appearance.spacing.extraSmall

					MaterialIcon {
						Layout.alignment: Qt.AlignHCenter
						color: DynamicColors.palette.m3onSurfaceVariant
						text: "hide_image"
					}

					CustomText {
						Layout.alignment: Qt.AlignHCenter
						color: DynamicColors.palette.m3onSurfaceVariant
						text: qsTr("Wallpaper disabled")
					}
				}
			}

			Item {
				anchors.fill: parent
				opacity: Config.background.enabled ? 1 : 0

				Behavior on opacity {
					Anim {
						type: Anim.SlowEffects
					}
				}

				Loader {
					id: wallIndicatorLoader

					active: opacity > 0
					anchors.fill: parent
					opacity: 0

					Behavior on opacity {
						Anim {
							type: Anim.DefaultEffects
						}
					}
					sourceComponent: CustomRect {
						color: DynamicColors.palette.m3primaryContainer
						radius: Appearance.rounding.normal
					}
				}

				Timer {
					id: wallLoadDebounceTimer

					interval: 100

					onTriggered: {
						if (wallImg.status !== Image.Ready)
							wallIndicatorLoader.opacity = 1;
					}
				}

				FadeImage {
					id: wallImg

					anchors.fill: parent
					fadeInAnim: Anim.SlowEffects
					fadeOutAnim: Anim.DefaultEffects
					preventInit: wallIndicatorLoader.opacity > 0
					source: Wallpapers.current

					onSourceChanged: wallLoadDebounceTimer.restart()
					onStatusChanged: {
						if (status === Image.Ready) {
							wallLoadDebounceTimer.stop();
							wallIndicatorLoader.opacity = 0;
						}
					}
				}
			}
		}

		IconTextButton {
			Layout.alignment: Qt.AlignHCenter
			enabled: Config.background.enabled
			horizontalPadding: Appearance.padding.extraLarge
			icon: "wallpaper"
			isRound: true
			shapeMorph: true
			text: qsTr("Wallpapers")
			type: IconTextButton.Tonal
			verticalPadding: Appearance.padding.normal

			onClicked: root.sState.openSubPage(1) // Wallpaper page
		}

		ToggleRow {
			checked: Config.background.enabled
			first: true
			text: qsTr("Display wallpaper")

			onToggled: Config.background.enabled = checked
		}

		ToggleRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			checked: DynamicColors.transparency.enabled
			subtext: qsTr("Base %1, layers %2").arg(DynamicColors.transparency.base).arg(DynamicColors.transparency.layers)
			text: qsTr("Transparency")

			onToggled: Config.appearance.transparency.enabled = checked
		}

		ToggleRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			checked: !DynamicColors.light
			last: true
			text: qsTr("Dark theme")

			onToggled: DynamicColors.setMode(checked ? "dark" : "light")
		}

		PopupRow {
			checked: Config.general.color.scheduleDark
			first: true
			subtext: qsTr("Dark mode will turn on at %1, and turn off at %2.").arg(Config.general.color.scheduleDarkStart).arg(Config.general.color.scheduleDarkEnd)
			text: qsTr("Schedule dark mode")

			popup: Component {
				TimeInput {
					object: Config.general.color
					settings: ["scheduleDark", "scheduleDarkStart", "scheduleDarkEnd"]

					onApplySettings: (start, end) => {
						Config.general.color.scheduleDarkStart = start;
						Config.general.color.scheduleDarkEnd = end;
						Config.save();
						ModeScheduler.checkStartup();
						PopupManager.requestClose();
					}
					onClose: PopupManager.requestClose()
				}
			}

			onClicked: value => {
				Config.general.color.scheduleDark = value;
			}
		}

		PopupRow {
			Layout.topMargin: Appearance.spacing.extraSmall / 2 - parent.spacing
			checked: Config.general.color.scheduleHyprsunset
			last: true
			subtext: qsTr("Hyprsunset will turn on at %1, and turn off at %2.").arg(Config.general.color.scheduleHyprsunsetStart).arg(Config.general.color.scheduleHyprsunsetEnd)
			text: qsTr("Schedule hyprsunset")

			popup: Component {
				TimeInput {
					object: Config.general.color
					settings: ["scheduleHyprsunset", "scheduleHyprsunsetStart", "scheduleHyprsunsetEnd"]

					onApplySettings: (start, end) => {
						Config.general.color.scheduleHyprsunsetStart = start;
						Config.general.color.scheduleHyprsunsetEnd = end;
						Config.save();
						Hyprsunset.checkStartup();
						PopupManager.requestClose();
					}
					onClose: PopupManager.requestClose()
				}
			}

			onClicked: value => {
				Config.general.color.scheduleHyprsunset = value;
			}
		}
	}
}
