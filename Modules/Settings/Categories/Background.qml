import Quickshell
import QtQuick.Layouts
import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	id: root

	required property ShellScreen screen

	SettingsSection {
		sectionId: "Wallpaper"

		SettingsHeader {
			name: "Wallpaper"
		}

		SettingSwitch {
			name: "Enable wallpaper rendering"
			object: Config.background
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			min: 0
			name: "Fade duration"
			object: Config.background
			setting: "wallFadeDuration"
			step: 50
		}

		Separator {
		}

		WallpaperCropper {
		}
	}

	SettingsSection {
		sectionId: "Wallpapers"

		WallpaperGrid {
			Layout.fillWidth: true
		}
	}
}
