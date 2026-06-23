pragma Singleton

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules.SettingsNew.Common
import qs.Modules.SettingsNew.Pages
import qs.Modules.SettingsNew.Pages.Wallpaper

QtObject {
	id: root

	readonly property list<Component> pageComps: [
		// Appearance
		Component {
			// Wallpaper & style
			StackPage {
				Component {
					Wallpaper {
					}
				}

				Component {
					WallpaperSelect {
					}
				}
			}
		},

		// Screenshot
		Component {
			StackPage {
				Component {
					Screenshot {
					}
				}
			}
		}
	]
	readonly property Component placeholderComp: Component {
		PlaceholderComp {
		}
	}

	component PlaceholderComp: Item {
		property SettingsState sState // To avoid the warning from non-existent property

		ColumnLayout {
			anchors.centerIn: parent
			spacing: Appearance.padding.extraSmall

			MaterialIcon {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3outlineVariant
				font.pointSize: Appearance.font.size.extraLarge
				text: "handyman"
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3outlineVariant
				text: qsTr("Page under construction")
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3outlineVariant
				text: qsTr("This page will be available in a future update.")
			}
		}
	}
}
