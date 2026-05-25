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
			// active: true
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
			visible: Config.screenshot.mode === "manual"
		}

		SettingSpinBox {
			min: 0
			name: "Corner radius"
			object: Config.screenshot
			setting: "corner_radius"
			step: 1
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSwitch {
			name: "Enable drop shadow"
			object: Config.screenshot
			setting: "drop_shadow"
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSwitch {
			name: "Enable rounded corners"
			object: Config.screenshot
			setting: "rounded_corners"
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSpinBox {
			min: 0
			name: "Shadow blur radius"
			object: Config.screenshot
			setting: "shadow_blur_radius"
			step: 1
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSwitch {
			name: "Shadow color broken atm"
			object: Config.Screenshot
			setting: "shadow_color"
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSpinBox {
			min: 1
			name: "Shadow passes"
			object: Config.screenshot
			setting: "shadow_blur_passes"
			step: 1
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSpinBox {
			min: 0
			name: "Shadow offset X"
			object: Config.screenshot
			setting: "shadow_offset_x"
			step: 1
			visible: Config.screenshot.mode === "manual"
		}

		Separator {
			visible: Config.screenshot.mode === "manual"
		}

		SettingSpinBox {
			min: 0
			name: "Shadow offset Y"
			object: Config.screenshot
			setting: "shadow_offset_y"
			step: 1
			visible: Config.screenshot.mode === "manual"
		}
	}
}
