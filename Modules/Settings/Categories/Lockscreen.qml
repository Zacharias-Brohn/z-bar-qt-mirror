import qs.Modules.Settings.Categories.Lockscreen
import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	id: root

	SettingsSection {
		sectionId: "Lockscreen"

		SettingsHeader {
			name: "Lockscreen"
		}

		SettingSwitch {
			name: "Recolor logo"
			object: Config.lock
			setting: "recolorLogo"
		}

		Separator {
		}

		SettingSwitch {
			name: "Enable fingerprint"
			object: Config.lock
			setting: "enableFprint"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Max fingerprint tries"
			object: Config.lock
			setting: "maxFprintTries"
			step: 1
		}

		Separator {
		}

		SettingSwitch {
			name: "Show notification details"
			object: Config.lock
			setting: "showNotifContent"
		}

		Separator {
		}

		SettingSwitch {
			name: "Show notification icon"
			object: Config.lock
			setting: "showNotifIcon"
		}

		Separator {
		}

		SettingSpinBox {
			min: 0
			name: "Blur amount"
			object: Config.lock
			setting: "blurAmount"
			step: 1
		}

		Separator {
		}

		SettingSpinBox {
			max: 2
			min: 0.1
			name: "Height multiplier"
			object: Config.lock.sizes
			setting: "heightMult"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			max: 4
			min: 0.5
			name: "Aspect ratio"
			object: Config.lock.sizes
			setting: "ratio"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			min: 100
			name: "Center width"
			object: Config.lock.sizes
			setting: "centerWidth"
			step: 10
		}
	}

	SettingsSection {
		sectionId: "Greeter"

		SettingsHeader {
			name: "Greeter"
		}

		SettingsIconButton {
			name: "Install wallpaper and color scheme to greeter"
		}
	}

	SettingsSection {
		sectionId: "Idle"

		Idle {
		}
	}
}
