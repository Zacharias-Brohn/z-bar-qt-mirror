pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Config
import qs.Helpers
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("All apps")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		Repeater {
			id: list

			model: [...DesktopEntries.applications.values].sort((a, b) => a.name.localeCompare(b.name))

			ConnectedRect {
				id: appItem

				required property int index
				required property DesktopEntry modelData

				Layout.fillWidth: true
				first: index === 0
				implicitHeight: appRow.implicitHeight + appRow.anchors.margins * 2
				last: index === list.count - 1

				StateLayer {
					onClicked: {
						root.sState.selectedApp = appItem.modelData;
						root.sState.openSubPage(2);
					}
				}

				RowLayout {
					id: appRow

					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.largeIncreased
					anchors.margins: Appearance.padding.normal
					anchors.rightMargin: Appearance.padding.largeIncreased
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

					MaterialIcon {
						color: DynamicColors.palette.m3onSurfaceVariant
						font.pointSize: Appearance.font.size.medium
						text: "chevron_right"
					}
				}
			}
		}
	}
}
