import Quickshell
import QtQuick.Layouts
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components
import qs.Modules.Settings.Controls

SettingsPage {
	SettingsSection {
		sectionId: "Updates"

		SettingsHeader {
			name: "System updates"
		}

		CustomListView {
			id: view

			readonly property int itemHeight: 50 + Appearance.padding.smaller * 2

			Layout.fillWidth: true
			Layout.preferredHeight: contentHeight
			spacing: Appearance.spacing.normal

			delegate: CustomRect {
				id: update

				required property var modelData
				readonly property list<string> sections: modelData.update.split(" ")

				// anchors.left: parent.left
				// anchors.right: parent.right
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
							Quickshell.execDetached(["pkexec", "yay", "-Sy", update.sections[0], "--noconfirm"]);
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
