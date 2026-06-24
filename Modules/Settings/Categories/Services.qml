import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		sectionId: "Services"

		SettingsHeader {
			name: "Services"
		}

		SettingInput {
			name: "Weather location"
			object: Config.services
			setting: "weatherLocation"
		}

		Separator {
		}

		SettingSwitch {
			name: "Check for updates"
			object: Config.services
			setting: "updates"
		}

		Separator {
		}

		SettingSwitch {
			name: "Use Fahrenheit"
			object: Config.services
			setting: "useFahrenheit"
		}

		Separator {
		}

		SettingSwitch {
			name: "Use twelve hour clock"
			object: Config.services
			setting: "useTwelveHourClock"
		}

		Separator {
		}

		SettingSwitch {
			name: "Enable ddcutil service"
			object: Config.services
			setting: "ddcutilService"
		}

		Separator {
		}

		SettingInput {
			name: "GPU type"
			object: Config.services
			setting: "gpuType"
		}
	}

	SettingsSection {
		sectionId: "Media"

		SettingsHeader {
			name: "Media"
		}

		SettingSpinBox {
			max: 1
			min: 0
			name: "Audio increment"
			object: Config.services
			setting: "audioIncrement"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			max: 1
			min: 0
			name: "Brightness increment"
			object: Config.services
			setting: "brightnessIncrement"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			max: 1.0
			min: 0
			name: "Minimum brightness"
			object: Config.services
			setting: "minBrightness"
			step: 0.01
		}

		Separator {
		}

		SettingSpinBox {
			max: 5
			min: 0
			name: "Max volume"
			object: Config.services
			setting: "maxVolume"
			step: 0.05
		}

		Separator {
		}

		SettingInput {
			name: "Default player"
			object: Config.services
			setting: "defaultPlayer"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Visualizer resolution"
			object: Config.services
			setting: "visualizerBars"
			step: 1
		}

		Separator {
		}

		SettingAliasList {
			name: "Player aliases"
			object: Config.services
			setting: "playerAliases"
		}
	}
}
