pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Config
import qs.Components
import qs.Modules
import qs.Helpers

CustomClippingRect {
	id: root

	readonly property bool hasUpdates: Object.keys(Updates.updates)?.length > 0
	readonly property int itemHeight: 50 + Appearance.padding.smaller * 2
	required property var wrapper

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: hasUpdates ? updatesListLoader.item?.implicitHeight + Appearance.padding.small * 2 : noUpdatesLoader.item.height
	implicitWidth: hasUpdates ? updatesListLoader.item?.contentWidth + Appearance.padding.small * 2 : noUpdatesLoader.item.width
	radius: Appearance.rounding.small

	Loader {
		id: noUpdatesLoader

		active: !root.hasUpdates
		anchors.centerIn: parent

		sourceComponent: Item {
			id: noUpdates

			height: 200
			width: 300

			MaterialIcon {
				id: noUpdatesIcon

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				color: DynamicColors.tPalette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.extraLarge * 3
				horizontalAlignment: Text.AlignHCenter
				text: "check"
			}

			CustomText {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: noUpdatesIcon.bottom
				color: DynamicColors.tPalette.m3onSurfaceVariant
				horizontalAlignment: Text.AlignHCenter
				text: qsTr("No updates available")
				verticalAlignment: Text.AlignVCenter
			}
		}
	}

	Loader {
		id: updatesListLoader

		active: root.hasUpdates
		anchors.centerIn: parent

		sourceComponent: CustomListView {
			id: updatesList

			contentHeight: childrenRect.height
			contentWidth: 600
			displayMarginBeginning: root.itemHeight
			displayMarginEnd: root.itemHeight
			implicitHeight: Math.min(contentHeight, (root.itemHeight + spacing) * 5 - spacing)
			implicitWidth: contentWidth
			spacing: Appearance.spacing.normal

			delegate: CustomRect {
				id: update

				required property var modelData
				readonly property list<string> sections: modelData.update.split(" ")

				// anchors.left: parent.left
				// anchors.right: parent.right
				color: DynamicColors.tPalette.m3surfaceContainer
				implicitHeight: root.itemHeight
				implicitWidth: 600
				radius: Appearance.rounding.small - Appearance.padding.small

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.smaller
					anchors.rightMargin: Appearance.padding.smaller

					MaterialIcon {
						font.pointSize: Appearance.font.size.large * 2
						text: "package_2"
					}

					ColumnLayout {
						Layout.fillWidth: true

						CustomText {
							Layout.fillWidth: true
							Layout.preferredHeight: 25
							elide: Text.ElideRight
							font.pointSize: Appearance.font.size.large
							text: update.sections[0]
						}

						CustomText {
							Layout.fillWidth: true
							color: DynamicColors.palette.m3onSurfaceVariant
							text: Updates.formatUpdateTime(update.modelData.timestamp)
						}
					}

					RowLayout {
						Layout.fillHeight: true
						Layout.preferredWidth: 300

						MarqueeText {
							id: versionFrom

							Layout.fillHeight: true
							Layout.preferredWidth: 125
							animate: true
							color: DynamicColors.palette.m3tertiary
							font.pointSize: Appearance.font.size.large
							horizontalAlignment: Text.AlignHCenter
							marqueeEnabled: true
							pauseMs: 4000
							text: update.sections[1]
							width: 125
						}

						MaterialIcon {
							Layout.fillHeight: true
							color: DynamicColors.palette.m3secondary
							font.pointSize: Appearance.font.size.extraLarge
							horizontalAlignment: Text.AlignHCenter
							text: "arrow_right_alt"
							verticalAlignment: Text.AlignVCenter
						}

						MarqueeText {
							id: versionTo

							Layout.fillHeight: true
							Layout.preferredWidth: 120
							animate: true
							color: DynamicColors.palette.m3primary
							font.pointSize: Appearance.font.size.large
							horizontalAlignment: Text.AlignHCenter
							marqueeEnabled: true
							pauseMs: 4000
							text: update.sections[3]
							width: 125
						}
					}
				}
			}
			model: ScriptModel {
				id: script

				objectProp: "update"
				values: Object.entries(Updates.updates).sort((a, b) => b[1] - a[1]).map(([update, timestamp]) => ({
							update,
							timestamp
						}))
			}
		}
	}
}
