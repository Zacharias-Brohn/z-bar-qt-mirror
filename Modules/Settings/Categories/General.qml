import Quickshell
import qs.Modules.Settings.Controls
import qs.Config
import qs.Components
import qs.Helpers

SettingsPage {
	id: root

	function schemeTypeItem(items, value) {
		for (let i = 0; i < items.length; i++) {
			const item = items[i];
			if (item.value === value)
				return item;
		}

		return items[0] ?? null;
	}

	SettingsSection {
		sectionId: "General"

		SettingsHeader {
			name: "General"
		}

		SettingInput {
			name: "Logo"
			object: Config.general
			setting: "logo"
		}

		Separator {
		}

		SettingInput {
			name: "Wallpaper path"
			object: Config.general
			setting: "wallpaperPath"
		}

		Separator {
		}

		SettingSwitch {
			name: "Desktop icons"
			object: Config.general
			setting: "desktopIcons"
		}

		Separator {
		}

		SettingInput {
			name: "Date format"
			object: Config.general
			setting: "dateFormat"
		}
	}

	SettingsSection {
		sectionId: "Color"

		SettingsHeader {
			name: "Color"
		}

		CustomSplitButtonRow {
			active: Config.general.color.mode === "light" ? menuItems[0] : menuItems[1]
			label: qsTr("Scheme mode")

			menuItems: [
				MenuItem {
					icon: "light_mode"
					text: qsTr("Light")
					value: "light"
				},
				MenuItem {
					icon: "dark_mode"
					text: qsTr("Dark")
					value: "dark"
				}
			]

			onSelected: item => {
				Config.general.color.mode = item.value;
				Config.save();

				if (item.value === "light")
					ModeScheduler.applyLightMode();
				else if (item.value === "dark")
					ModeScheduler.applyDarkMode();
			}
		}

		Separator {
		}

		CustomSplitButtonRow {
			id: schemeType

			active: root.schemeTypeItem(menuItems, Config.colors.schemeType)
			label: qsTr("Scheme type")
			z: 2

			menuItems: [
				MenuItem {
					icon: "palette"
					text: qsTr("Vibrant")
					value: "vibrant"
				},
				MenuItem {
					icon: "gesture"
					text: qsTr("Expressive")
					value: "expressive"
				},
				MenuItem {
					icon: "contrast"
					text: qsTr("Monochrome")
					value: "monochrome"
				},
				MenuItem {
					icon: "tonality"
					text: qsTr("Neutral")
					value: "neutral"
				},
				MenuItem {
					icon: "gradient"
					text: qsTr("Tonal spot")
					value: "tonal-spot"
				},
				MenuItem {
					icon: "target"
					text: qsTr("Fidelity")
					value: "fidelity"
				},
				MenuItem {
					icon: "article"
					text: qsTr("Content")
					value: "content"
				},
				MenuItem {
					icon: "colors"
					text: qsTr("Rainbow")
					value: "rainbow"
				},
				MenuItem {
					icon: "nutrition"
					text: qsTr("Fruit salad")
					value: "fruit-salad"
				}
			]

			onSelected: item => {
				Config.colors.schemeType = item.value;
				Config.save();

				Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--scheme", item.value]);
			}
		}

		Separator {
		}

		SettingSwitch {
			name: "Automatic color scheme"
			object: Config.general.color
			setting: "schemeGeneration"
		}

		Separator {
		}

		SettingSwitch {
			name: "Smart color scheme"
			object: Config.general.color
			setting: "smart"
		}

		Separator {
		}

		SettingSpinner {
			name: "Schedule dark mode"
			object: Config.general.color
			settings: ["scheduleDarkStart", "scheduleDarkEnd", "scheduleDark"]
		}

		Separator {
		}

		SettingHyprSpinner {
			name: "Schedule Hyprsunset"
			object: Config.general.color
			settings: ["scheduleHyprsunsetStart", "scheduleHyprsunsetEnd", "scheduleHyprsunset", "hyprsunsetTemp"]
		}
	}

	SettingsSection {
		sectionId: "Default Apps"
		z: -1

		SettingsHeader {
			name: "Default Apps"
		}

		SettingStringList {
			addLabel: qsTr("Add terminal command")
			name: "Terminal"
			object: Config.general.apps
			setting: "terminal"
		}

		Separator {
		}

		SettingStringList {
			addLabel: qsTr("Add audio command")
			name: "Audio"
			object: Config.general.apps
			setting: "audio"
		}

		Separator {
		}

		SettingStringList {
			addLabel: qsTr("Add playback command")
			name: "Playback"
			object: Config.general.apps
			setting: "playback"
		}

		Separator {
		}

		SettingStringList {
			addLabel: qsTr("Add explorer command")
			name: "Explorer"
			object: Config.general.apps
			setting: "explorer"
		}
	}
}
