pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import ZShell
import qs.Helpers
import qs.Components
import qs.Config
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	title: qsTr("Apps")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Default applications
		SectionHeader {
			first: true
			text: qsTr("Default applications")
		}

		DefaultRow {
			first: true
			icon: "terminal"
			status: Config.general.apps.terminal.join(" ")
			text: qsTr("Terminal")

			onSelected: app => Config.general.apps.terminal = app.command
		}

		DefaultRow {
			icon: "volume_up"
			status: Config.general.apps.audio.join(" ")
			text: qsTr("Audio")

			onSelected: app => Config.general.apps.audio = app.command
		}

		DefaultRow {
			icon: "play_circle"
			status: Config.general.apps.playback.join(" ")
			text: qsTr("Media playback")

			onSelected: app => Config.general.apps.playback = app.command
		}

		DefaultRow {
			icon: "folder"
			last: true
			status: Config.general.apps.explorer.join(" ")
			text: qsTr("File manager")

			onSelected: app => Config.general.apps.explorer = app.command
		}

		// Library
		SectionHeader {
			text: qsTr("Library")
		}

		NavRow {
			first: true
			icon: "apps"
			last: true
			status: qsTr("Browse installed apps, set favorites and hidden")
			text: qsTr("All apps")

			onClicked: root.sState.openSubPage(1)
		}
	}

	component DefaultRow: PopupRow {
		id: row

		readonly property int popupHeight: root.flickable.height - y + root.flickable.contentY - Appearance.padding.large - Appearance.padding.extraLarge

		signal selected(app: DesktopEntry)

		keepPopupAsChild: {
			if (root.sState.animatingContainer || root.opacity < 1)
				return true;

			let p = root.parent;
			while (p && p.objectName !== "PageContainer")
				p = p.parent;
			return p?.opacity < 1;
		}
		popup.topMovement: Math.max(0 - popupHeight, Appearance.padding.large)

		Loader {
			active: row.popup.animDriver > 0
			anchors.centerIn: parent

			sourceComponent: VerticalFadeListView {
				id: list

				fadeAmount: 0.05
				implicitHeight: ZUtils.clamp(row.popupHeight, 200, 800)
				implicitWidth: 300
				model: {
					const apps = [...DesktopEntries.applications.values];
					const favorited = new Set(apps.filter(a => Strings.testRegexList(Config.launcher.favoriteApps, a.id)));
					return apps.sort((a, b) => (favorited.has(b) - favorited.has(a)) || a.name.localeCompare(b.name));
				}

				delegate: StateLayer {
					id: appItem

					required property int index
					required property DesktopEntry modelData

					anchors.fill: undefined
					anchors.left: list.contentItem.left
					anchors.right: list.contentItem.right
					implicitHeight: itemLayout.implicitHeight + itemLayout.anchors.margins * 2
					radius: Appearance.rounding.small

					onClicked: {
						row.popup.open = false;
						row.selected(modelData);
					}

					RowLayout {
						id: itemLayout

						anchors.fill: parent
						anchors.margins: Appearance.padding.normal
						spacing: Appearance.spacing.small

						IconImage {
							asynchronous: true
							implicitSize: Math.round(Appearance.font.size.large * 1.8)
							source: Quickshell.iconPath(appItem.modelData.icon, "image-missing")
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 0

							CustomText {
								Layout.fillWidth: true
								elide: Text.ElideRight
								font.pointSize: Appearance.font.size.small
								text: appItem.modelData.name
							}

							CustomText {
								Layout.fillWidth: true
								color: DynamicColors.palette.m3outline
								elide: Text.ElideRight
								font.pointSize: Appearance.font.size.small
								text: (appItem.modelData.comment || appItem.modelData.genericName) ?? ""
								visible: text
							}
						}

						MaterialIcon {
							color: DynamicColors.palette.m3primary
							fill: 1
							font.pointSize: Appearance.font.size.small
							text: "favorite"
							visible: Strings.testRegexList(Config.launcher.favoriteApps, appItem.modelData.id)
						}
					}
				}
			}
		}
	}
}
