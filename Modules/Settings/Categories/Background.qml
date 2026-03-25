import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	id: root

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
			name: "Fade duration"
			min: 0
			object: Config.background
			setting: "wallFadeDuration"
			step: 50
		}
	}
}
