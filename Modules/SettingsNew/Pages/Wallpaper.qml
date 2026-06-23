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

		Item {
			id: wallWrapper

			Layout.alignment: Qt.AlignHCenter
			implicitHeight: cropper.height
			implicitWidth: {
				const screen = root.sState.screen;
				return implicitHeight / screen.height * screen.width;
			}

			WallpaperCropper {
				id: cropper
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

		OverlayRow {
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

		OverlayRow {
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
