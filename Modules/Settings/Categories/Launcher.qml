import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		sectionId: "Launcher"

		SettingsHeader {
			name: "Launcher"
		}

		SettingSpinBox {
			min: 1
			name: "Max apps shown"
			object: Config.launcher
			setting: "maxAppsShown"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Max wallpapers shown"
			object: Config.launcher
			setting: "maxWallpapers"
		}

		Separator {
		}

		SettingInput {
			name: "Action prefix"
			object: Config.launcher
			setting: "actionPrefix"
		}

		Separator {
		}

		SettingInput {
			name: "Special prefix"
			object: Config.launcher
			setting: "specialPrefix"
		}

		Separator {
		}

		SettingSwitch {
			name: "Use UWSM launch command"
			object: Config.launcher
			setting: "uwsm"
		}
	}

	SettingsSection {
		sectionId: "Fuzzy Search"

		SettingsHeader {
			name: "Fuzzy Search"
		}

		SettingSwitch {
			name: "Apps"
			object: Config.launcher.useFuzzy
			setting: "apps"
		}

		Separator {
		}

		SettingSwitch {
			name: "Actions"
			object: Config.launcher.useFuzzy
			setting: "actions"
		}

		Separator {
		}

		SettingSwitch {
			name: "Schemes"
			object: Config.launcher.useFuzzy
			setting: "schemes"
		}

		Separator {
		}

		SettingSwitch {
			name: "Variants"
			object: Config.launcher.useFuzzy
			setting: "variants"
		}

		Separator {
		}

		SettingSwitch {
			name: "Wallpapers"
			object: Config.launcher.useFuzzy
			setting: "wallpapers"
		}
	}

	SettingsSection {
		sectionId: "Sizes"

		SettingsHeader {
			name: "Sizes"
		}

		SettingSpinBox {
			min: 1
			name: "Item width"
			object: Config.launcher.sizes
			setting: "itemWidth"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Item height"
			object: Config.launcher.sizes
			setting: "itemHeight"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Wallpaper width"
			object: Config.launcher.sizes
			setting: "wallpaperWidth"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Wallpaper height"
			object: Config.launcher.sizes
			setting: "wallpaperHeight"
		}
	}

	SettingsSection {
		sectionId: "Actions"

		SettingsHeader {
			name: "Actions"
		}

		SettingActionList {
			name: "Launcher actions"
			object: Config.launcher
			setting: "actions"
		}
	}
}
