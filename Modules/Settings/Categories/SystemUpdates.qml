pragma ComponentBehavior: Bound

import Quickshell
import QtQuick.Layouts
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components
import qs.Modules.Settings.Controls

CustomClippingRect {
	id: root

	radius: Appearance.rounding.normal - Appearance.padding.smaller

	ColumnLayout {
		anchors.fill: parent

		RowLayout {
			Layout.fillWidth: true
			Layout.margins: Appearance.padding.large
			spacing: Appearance.spacing.large

			MaterialIcon {
				font.pointSize: Appearance.font.size.larger * 4
				text: "update"
			}

			ColumnLayout {
				CustomText {
					font.pointSize: Appearance.font.size.large * 2
					text: "System updates"
				}

				RowLayout {
					id: row

					Layout.fillWidth: true

					CustomText {
						id: text

						Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: `${Updates.availableUpdates} available updates`
					}

					CustomRect {
						Layout.preferredHeight: 40
						Layout.preferredWidth: 150
						color: Updates.updating ? DynamicColors.layer(DynamicColors.palette.m3outline, 2) : DynamicColors.palette.m3primary
						radius: Appearance.rounding.full

						RowLayout {
							anchors.centerIn: parent

							MaterialIcon {
								animate: true
								color: DynamicColors.palette.m3onPrimary
								font.pointSize: Appearance.font.size.large
								text: Updates.updating ? "update" : "download"
							}

							CustomText {
								color: Updates.updating ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onPrimary
								text: "Update all"
							}
						}

						StateLayer {
							color: DynamicColors.palette.m3onPrimary
							disabled: Updates.updating

							onClicked: Updates.performSystemUpdate()
						}
					}
				}
			}
		}

		CustomListView {
			id: view

			readonly property int itemHeight: 50 + Appearance.padding.smaller * 2

			Layout.fillHeight: true
			Layout.fillWidth: true
			clip: true
			contentHeight: height
			spacing: Appearance.spacing.normal

			delegate: CustomRect {
				id: update

				required property var modelData
				readonly property list<string> sections: modelData.update.split(" ")

				color: DynamicColors.tPalette.m3surfaceContainer
				implicitHeight: view.itemHeight
				implicitWidth: parent.width
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
						Layout.preferredWidth: 500

						MarqueeText {
							id: versionFrom

							Layout.fillHeight: true
							Layout.preferredWidth: 225
							animate: true
							color: DynamicColors.palette.m3tertiary
							font.pointSize: Appearance.font.size.large
							horizontalAlignment: Text.AlignHCenter
							marqueeEnabled: true
							pauseMs: 4000
							text: update.sections[1]
							width: 225
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
							Layout.preferredWidth: 225
							animate: true
							color: DynamicColors.palette.m3primary
							font.pointSize: Appearance.font.size.large
							horizontalAlignment: Text.AlignHCenter
							marqueeEnabled: true
							pauseMs: 4000
							text: update.sections[3]
							width: 225
						}
					}

					IconButton {
						Layout.preferredHeight: width
						icon: "download"

						onClicked: {
							Updates.performPackageUpdate(update.sections[0]);
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
