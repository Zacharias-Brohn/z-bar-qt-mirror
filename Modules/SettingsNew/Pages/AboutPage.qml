import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ZShell
import qs.Modules.SettingsNew.Common
import qs.Config
import qs.Helpers
import qs.Components

PageBase {
	id: root

	property string cliVersion
	readonly property int pluginCount: 0
	property string quickshellVersion

	title: qsTr("About")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		Process {
			command: ["quickshell", "--version"]
			running: true

			stdout: StdioCollector {
				onStreamFinished: root.quickshellVersion = text.trim().split(" ")[1] ?? ""
			}
		}

		ConnectedRect {
			Layout.fillWidth: true
			first: true
			implicitHeight: hero.implicitHeight + Appearance.padding.extraLarge * 2
			last: true

			ColumnLayout {
				id: hero

				anchors.centerIn: parent
				spacing: Appearance.spacing.small
				width: parent.width - Appearance.padding.largeIncreased * 2

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					Layout.topMargin: Appearance.spacing.small
					font.pointSize: Appearance.font.size.large
					text: "ZShell"
				}

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3onSurfaceVariant
					font: Appearance.font.body.medium
					text: ZUtils.version ? `v${ZUtils.version}` : "…"
				}
			}
		}

		// System
		SectionHeader {
			text: qsTr("System")
		}

		InfoRow {
			first: true
			label: qsTr("Hostname")
			value: SystemInfo.hostname
		}

		InfoRow {
			label: qsTr("Device")
			value: SystemInfo.device
		}

		InfoRow {
			label: qsTr("Distro")
			value: SystemInfo.osPrettyName || SystemInfo.osName
		}

		InfoRow {
			label: qsTr("Kernel")
			value: SystemInfo.kernel
		}

		InfoRow {
			label: qsTr("Firmware")
			last: true
			value: SystemInfo.firmware
		}

		// Software
		SectionHeader {
			text: qsTr("Software")
		}

		InfoRow {
			first: true
			label: qsTr("Shell")
			value: ZUtils.version || "…"
		}

		InfoRow {
			label: qsTr("Quickshell")
			value: root.quickshellVersion || "…"
		}

		InfoRow {
			label: qsTr("Qt")
			last: true
			value: ZUtils.qtVersion || "…"
		}
	}
}
