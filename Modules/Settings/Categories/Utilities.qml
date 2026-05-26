import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		sectionId: "Utilities"

		SettingsHeader {
			name: "Utilities"
		}

		SettingSwitch {
			name: "Enable utilities"
			object: Config.utilities
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Max toasts"
			object: Config.utilities
			setting: "maxToasts"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Panel width"
			object: Config.utilities.sizes
			setting: "width"
		}

		Separator {
		}

		SettingSpinBox {
			min: 1
			name: "Toast width"
			object: Config.utilities.sizes
			setting: "toastWidth"
		}
	}

	SettingsSection {
		sectionId: "Toasts"

		SettingsHeader {
			name: "Toasts"
		}

		SettingSwitch {
			name: "Config loaded"
			object: Config.utilities.toasts
			setting: "configLoaded"
		}

		Separator {
		}

		SettingSwitch {
			name: "Charging changed"
			object: Config.utilities.toasts
			setting: "chargingChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Game mode changed"
			object: Config.utilities.toasts
			setting: "gameModeChanged"
		}

		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Do not disturb changed"
		// 	object: Config.utilities.toasts
		// 	setting: "dndChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Audio output changed"
		// 	object: Config.utilities.toasts
		// 	setting: "audioOutputChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Audio input changed"
		// 	object: Config.utilities.toasts
		// 	setting: "audioInputChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Caps lock changed"
		// 	object: Config.utilities.toasts
		// 	setting: "capsLockChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Num lock changed"
		// 	object: Config.utilities.toasts
		// 	setting: "numLockChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Keyboard layout changed"
		// 	object: Config.utilities.toasts
		// 	setting: "kbLayoutChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "VPN changed"
		// 	object: Config.utilities.toasts
		// 	setting: "vpnChanged"
		// }
		//
		// Separator {
		// }
		//
		// SettingSwitch {
		// 	name: "Now playing"
		// 	object: Config.utilities.toasts
		// 	setting: "nowPlaying"
		// }
	}

	// SettingsSection {
	// 	sectionId: "VPN"
	//
	// 	SettingsHeader {
	// 		name: "VPN"
	// 	}
	//
	// 	SettingSwitch {
	// 		name: "Enable VPN integration"
	// 		object: Config.utilities.vpn
	// 		setting: "enabled"
	// 	}
	//
	// 	Separator {
	// 	}
	//
	// 	SettingStringList {
	// 		name: "Provider"
	// 		addLabel: qsTr("Add VPN provider")
	// 		object: Config.utilities.vpn
	// 		setting: "provider"
	// 	}
	// }
}
