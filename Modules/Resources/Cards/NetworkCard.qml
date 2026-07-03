import QtQuick
import QtQuick.Layouts
import ZShell.Internal
import qs.Helpers
import qs.Components
import qs.Config

CustomRect {
	id: root

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: 220
	implicitWidth: 300
	radius: Appearance.rounding.large - Appearance.padding.normal

	Ref {
		service: NetworkUsage
	}

	ColumnLayout {
		id: layout

		anchors.bottomMargin: Appearance.padding.larger
		anchors.fill: parent
		anchors.margins: Appearance.padding.large
		spacing: 0

		RowLayout {
			spacing: Appearance.spacing.small

			MaterialIcon {
				color: DynamicColors.palette.m3primary
				text: "swap_vert"
			}

			CustomText {
				text: qsTr("Network")
			}
		}

		Item {
			Layout.bottomMargin: Appearance.spacing.small
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.topMargin: Appearance.spacing.larger

			SparklineItem {
				id: sparkline

				property bool initialized: false
				property real smoothMax: targetMax
				property real targetMax: 1024

				anchors.fill: parent
				historyLength: NetworkUsage.historyLength
				line1: NetworkUsage.uploadBuffer // qmllint disable missing-type
				line1Color: DynamicColors.palette.m3secondary
				line1FillAlpha: 0.15
				line2: NetworkUsage.downloadBuffer // qmllint disable missing-type
				line2Color: DynamicColors.palette.m3tertiary
				line2FillAlpha: 0.2
				maxValue: smoothMax
				slideProgress: 1

				Behavior on smoothMax {
					enabled: sparkline.initialized

					Anim {
					}
				}

				Component.onCompleted: {
					sparkline.targetMax = Math.max(NetworkUsage.downloadBuffer.maximum, NetworkUsage.uploadBuffer.maximum, 1024);

					sparkline.smoothMax = Qt.binding(() => sparkline.targetMax);

					sparkline.initialized = true;
				}

				Connections {
					function onValuesChanged(): void {
						sparkline.targetMax = Math.max(NetworkUsage.downloadBuffer.maximum, NetworkUsage.uploadBuffer.maximum, 1024);
						slideAnim.restart();
					}

					target: NetworkUsage.downloadBuffer
				}

				NumberAnimation {
					id: slideAnim

					duration: Config.dashboard.resourceUpdateInterval
					easing.type: Easing.Linear
					from: 0
					property: "slideProgress"
					target: sparkline
					to: 1
				}
			}

			// "Collecting data" placeholder
			CustomText {
				anchors.centerIn: parent
				color: DynamicColors.palette.m3outline
				text: qsTr("Collecting data...")
				visible: NetworkUsage.downloadBuffer.count < 2
			}
		}

		// Download row
		RowLayout {
			Layout.fillWidth: true
			spacing: Appearance.spacing.small

			MaterialIcon {
				color: DynamicColors.palette.m3tertiary
				text: "download"
			}

			CustomText {
				color: DynamicColors.palette.m3onSurfaceVariant
				text: qsTr("Download")
			}

			Item {
				Layout.fillWidth: true
			}

			CustomText {
				color: DynamicColors.palette.m3tertiary
				text: {
					const fmt = NetworkUsage.formatBytes(NetworkUsage.downloadSpeed ?? 0);
					return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit}` : "0.0 B/s";
				}
			}
		}

		// Upload row
		RowLayout {
			Layout.fillWidth: true
			spacing: Appearance.spacing.small

			MaterialIcon {
				color: DynamicColors.palette.m3secondary
				text: "upload"
			}

			CustomText {
				color: DynamicColors.palette.m3onSurfaceVariant
				text: qsTr("Upload")
			}

			Item {
				Layout.fillWidth: true
			}

			CustomText {
				color: DynamicColors.palette.m3secondary
				text: {
					const fmt = NetworkUsage.formatBytes(NetworkUsage.uploadSpeed ?? 0);
					return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit}` : "0.0 B/s";
				}
			}
		}

		// Session totals
		RowLayout {
			Layout.fillWidth: true
			spacing: Appearance.spacing.small

			MaterialIcon {
				color: DynamicColors.palette.m3onSurfaceVariant
				text: "history"
			}

			CustomText {
				color: DynamicColors.palette.m3onSurfaceVariant
				text: qsTr("Total")
			}

			Item {
				Layout.fillWidth: true
			}

			CustomText {
				color: DynamicColors.palette.m3onSurfaceVariant
				text: {
					const down = NetworkUsage.formatBytesTotal(NetworkUsage.downloadTotal ?? 0);
					const up = NetworkUsage.formatBytesTotal(NetworkUsage.uploadTotal ?? 0);
					return (down && up) ? `↓${down.value.toFixed(1)}${down.unit} ↑${up.value.toFixed(1)}${up.unit}` : "↓0.0B ↑0.0B";
				}
			}
		}
	}
}
