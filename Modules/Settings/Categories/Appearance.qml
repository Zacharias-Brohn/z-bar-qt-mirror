import QtQuick
import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	id: root

	SettingsSection {
		sectionId: "Scale"

		SettingsHeader {
			name: "Scale"
		}

		SettingSpinBox {
			name: "Rounding scale"
			object: Config.appearance.rounding
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Spacing scale"
			object: Config.appearance.spacing
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Padding scale"
			object: Config.appearance.padding
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Font size scale"
			object: Config.appearance.font.size
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Animation duration scale"
			object: Config.appearance.anim.durations
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Deform animation scale"
			object: Config.appearance.deform
			setting: "scale"
			step: 0.1
		}
	}

	SettingsSection {
		sectionId: "Fonts"

		SettingsHeader {
			name: "Fonts"
		}

		SettingListView {
			name: "Sans family"
			object: Config.appearance.font.family
			setting: "sans"
			stringList: Qt.fontFamilies()
		}

		Separator {
		}

		SettingListView {
			name: "Monospace family"
			object: Config.appearance.font.family
			setting: "mono"
			stringList: Qt.fontFamilies()
		}
	}

	SettingsSection {
		sectionId: "Animation"

		SettingsHeader {
			name: "Animation"
		}

		SettingSpinBox {
			name: "Media GIF speed adjustment"
			object: Config.appearance.anim
			setting: "mediaGifSpeedAdjustment"
			step: 10
		}

		Separator {
		}

		SettingSpinBox {
			max: 5
			min: 0
			name: "Session GIF speed"
			object: Config.appearance.anim
			setting: "sessionGifSpeed"
			step: 0.1
		}
	}

	SettingsSection {
		sectionId: "Transparency"

		SettingsHeader {
			name: "Transparency"
		}

		SettingSwitch {
			name: "Enable transparency"
			object: Config.appearance.transparency
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			max: 1
			min: 0
			name: "Base opacity"
			object: Config.appearance.transparency
			setting: "base"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			max: 1
			min: 0
			name: "Layer opacity"
			object: Config.appearance.transparency
			setting: "layers"
			step: 0.05
		}
	}
}
