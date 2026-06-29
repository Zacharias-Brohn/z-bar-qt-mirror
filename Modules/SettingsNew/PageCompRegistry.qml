pragma Singleton

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules.SettingsNew.Common
import qs.Modules.SettingsNew.Pages
import qs.Modules.SettingsNew.Pages.Wallpaper
import qs.Modules.SettingsNew.Pages.Audio
import qs.Modules.SettingsNew.Pages.Apps
import qs.Modules.SettingsNew.Pages.Panels
import qs.Modules.SettingsNew.Pages.Panels.Bar
import qs.Modules.SettingsNew.Pages.Services

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
		Component {
			// Screenshot
			StackPage {
				Component {
					Screenshot {
					}
				}
			}
		},

		// Connectivity
		Component {
			PlaceholderComp {
			}
		},
		Component {
			PlaceholderComp {
			}
		},
		Component {
			// Audio
			StackPage {
				Component {
					AudioPage {
					}
				}

				Component {
					AppVolumes {
					}
				}
			}
		},

		// Shell
		Component {
			StackPage {
				Component {
					PanelsPage {
					}
				}

				Component {
					BarPanel {
					}
				}

				Component {
					DashboardPanel {
					}
				}

				Component {
					ResourcesPanel {
					}
				}

				Component {
					LauncherPanel {
					}
				}

				Component {
					SidebarPanel {
					}
				}

				// Bar sub pages
				Component {
					BarTray {
					}
				}

				Component {
					BarStatusIcons {
					}
				}

				Component {
					BarClock {
					}
				}
			}
		},

		// Apps
		Component {
			StackPage {
				Component {
					AppsPage {
					}
				}

				Component {
					AllApps {
					}
				}

				Component {
					AppInfo {
					}
				}
			}
		},

		// Services
		Component {
			StackPage {
				Component {
					ServicesPage {
					}
				}

				Component {
					NotificationsPage {
					}
				}
			}
		},

		// About
		Component {
			StackPage {
				Component {
					AboutPage {
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
