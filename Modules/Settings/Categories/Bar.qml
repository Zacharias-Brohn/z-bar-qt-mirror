import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		sectionId: "Bar"

		SettingsHeader {
			name: "Bar"
		}

		SettingSwitch {
			name: "Auto hide"
			object: Config.barConfig
			setting: "autoHide"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Height"
			object: Config.barConfig
			setting: "height"
		}

		Separator {
		}

		SettingSpinBox {
			min: 0
			name: "Rounding"
			object: Config.barConfig
			setting: "rounding"
		}

		Separator {
		}

		SettingSpinBox {
			min: 0
			name: "Border"
			object: Config.barConfig
			setting: "border"
		}

		Separator {
		}

		SettingSpinBox {
			min: 0
			name: "Smoothing"
			object: Config.barConfig
			setting: "smoothing"
		}
	}

	SettingsSection {
		sectionId: "Tray"

		SettingsHeader {
			name: "System tray"
		}

		SettingSpinBox {
			min: 16
			name: "Tray icon size"
			object: Config.barConfig.tray
			setting: "trayIconSize"
		}
	}

	SettingsSection {
		sectionId: "Popouts"

		SettingsHeader {
			name: "Popouts"
		}

		SettingSwitch {
			name: "Tray"
			object: Config.barConfig.popouts
			setting: "tray"
		}

		Separator {
		}

		SettingSwitch {
			name: "Audio"
			object: Config.barConfig.popouts
			setting: "audio"
		}

		Separator {
		}

		SettingSwitch {
			name: "Active window"
			object: Config.barConfig.popouts
			setting: "activeWindow"
		}

		Separator {
		}

		SettingSwitch {
			name: "Resources"
			object: Config.barConfig.popouts
			setting: "resources"
		}

		Separator {
		}

		SettingSwitch {
			name: "Clock"
			object: Config.barConfig.popouts
			setting: "clock"
		}

		Separator {
		}

		SettingSwitch {
			name: "Network"
			object: Config.barConfig.popouts
			setting: "network"
		}

		Separator {
		}

		SettingSwitch {
			name: "Power"
			object: Config.barConfig.popouts
			setting: "upower"
		}
	}

	SettingsSection {
		sectionId: "Entries"

		SettingsHeader {
			name: "Entries"
		}

		SettingBarEntryList {
			name: "Bar entries"
			object: Config.barConfig
			setting: "entries"
		}
	}

	SettingsSection {
		sectionId: "Dock"

		SettingsHeader {
			name: "Dock"
		}

		SettingSwitch {
			name: "Enable dock"
			object: Config.dock
			setting: "enable"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Dock height"
			object: Config.dock
			setting: "height"
		}

		Separator {
		}

		SettingSwitch {
			name: "Hover to reveal"
			object: Config.dock
			setting: "hoverToReveal"
		}

		Separator {
		}

		SettingSwitch {
			name: "Pin on startup"
			object: Config.dock
			setting: "pinnedOnStartup"
		}

		Separator {
		}

		SettingStringList {
			addLabel: qsTr("Add pinned app")
			name: "Pinned apps"
			object: Config.dock
			setting: "pinnedApps"
		}

		Separator {
		}

		SettingStringList {
			addLabel: qsTr("Add ignored regex")
			name: "Ignored app regexes"
			object: Config.dock
			setting: "ignoredAppRegexes"
		}
	}
}
