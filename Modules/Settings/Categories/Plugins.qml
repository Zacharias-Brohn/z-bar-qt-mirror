import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		sectionId: "Plugins"

		SettingsHeader {
			name: "Plugins"
		}

		SettingBarEntryList {
			name: "Enable or disable plugins"
			object: Config.plugins
			setting: "entries"
		}
	}
}
