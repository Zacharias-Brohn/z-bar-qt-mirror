import qs.Modules.Settings.Controls
import qs.Config
import qs.Components

SettingsPage {
	SettingsSection {
		sectionId: "Screenshot"

		SettingsHeader {
			name: "Screenshot"
		}

		SettingSwitch {
			name: "Enable effects"
			object: Config.screenshot
			setting: "enable_pp"
		}

		Separator {
		}

		CustomSplitButtonRow {
			active: Config.screenshot.mode === "manual" ? menuItems[0] : menuItems[1]
			enabled: Config.screenshot.enable_pp
			label: qsTr("Effects mode")

			menuItems: [
				MenuItem {
					icon: "build"
					text: qsTr("Manual")
					value: "manual"
				},
				MenuItem {
					icon: "rotate_auto"
					text: qsTr("Auto")
					value: "auto"
				}
			]

			onSelected: item => {
				Config.screenshot.mode = item.value;
				Config.save();
			}
		}

		Separator {
			shouldBeActive: Config.screenshot.mode === "manual"
		}

		SettingSwitch {
			enabled: Config.screenshot.enable_pp
			name: "Enable rounded corners"
			object: Config.screenshot
			setting: "rounding"
			shouldBeActive: Config.screenshot.mode === "manual"
		}

		Separator {
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.rounding
		}

		SettingSpinBox {
			enabled: Config.screenshot.enable_pp
			min: 0
			name: "Corner radius"
			object: Config.screenshot
			setting: "radius"
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.rounding
			step: 1
		}

		Separator {
			shouldBeActive: Config.screenshot.mode === "manual"
		}

		SettingSwitch {
			enabled: Config.screenshot.enable_pp
			name: "Enable shadow"
			object: Config.screenshot
			setting: "shadow"
			shouldBeActive: Config.screenshot.mode === "manual"
		}

		Separator {
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.shadow
		}

		SettingSpinBox {
			enabled: Config.screenshot.enable_pp
			min: 0
			name: "Shadow blur amount"
			object: Config.screenshot
			setting: "shadow_blur"
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.shadow
			step: 1
		}

		Separator {
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.shadow
		}

		// SettingSwitch {
		// 	name: "Shadow color broken atm"
		// 	object: Config.Screenshot
		// 	setting: "shadow_color"
		// 	shouldBeActive: Config.screenshot.mode === "manual"
		// }
		//
		// Separator {
		// 	shouldBeActive: Config.screenshot.mode === "manual"
		// }

		// SettingSpinBox {
		// 	min: 1
		// 	name: "Shadow passes"
		// 	object: Config.screenshot
		// 	setting: "shadow_blur_passes"
		// 	shouldBeActive: Config.screenshot.mode === "manual"
		// 	step: 1
		// }
		//
		// Separator {
		// 	shouldBeActive: Config.screenshot.mode === "manual"
		// }

		SettingSpinBox {
			enabled: Config.screenshot.enable_pp
			min: 0
			name: "Shadow offset X"
			object: Config.screenshot
			setting: "shadow_offset_x"
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.shadow
			step: 1
		}

		Separator {
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.shadow
		}

		SettingSpinBox {
			enabled: Config.screenshot.enable_pp
			min: 0
			name: "Shadow offset Y"
			object: Config.screenshot
			setting: "shadow_offset_y"
			shouldBeActive: Config.screenshot.mode === "manual" && Config.screenshot.shadow
			step: 1
		}
	}
}
