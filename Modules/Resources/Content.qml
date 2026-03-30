import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.UPower
import ZShell.Internal
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	readonly property int minWidth: 400 + 400 + Appearance.spacing.normal + 120 + Appearance.padding.large * 2

	function displayTemp(temp: real): string {
		return `${Math.ceil(temp)}°C`;
	}

	implicitHeight: content.implicitHeight
	implicitWidth: Math.max(minWidth, content.implicitWidth)

	RowLayout {
		id: content

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: Appearance.spacing.normal

		Ref {
			service: SystemUsage
		}

		ColumnLayout {
			id: mainColumn

			Layout.fillWidth: true
			spacing: Appearance.spacing.normal

			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal
				visible: Config.dashboard.performance.showCpu || (Config.dashboard.performance.showGpu && SystemUsage.gpuType !== "NONE")

				HeroCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 400
					Layout.preferredHeight: 150
					accentColor: DynamicColors.palette.m3primary
					icon: "memory"
					mainLabel: qsTr("Usage")
					mainValue: `${Math.round(SystemUsage.cpuPerc * 100)}%`
					secondaryLabel: qsTr("Temp")
					secondaryValue: root.displayTemp(SystemUsage.cpuTemp)
					temperature: SystemUsage.cpuTemp
					title: SystemUsage.cpuName ? `CPU - ${SystemUsage.cpuName}` : qsTr("CPU")
					usage: SystemUsage.cpuPerc
					visible: Config.dashboard.performance.showCpu
				}

				HeroCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 400
					Layout.preferredHeight: 150
					accentColor: DynamicColors.palette.m3secondary
					icon: "desktop_windows"
					mainLabel: qsTr("Usage")
					mainValue: `${Math.round(SystemUsage.gpuPerc * 100)}%`
					secondaryLabel: qsTr("Temp")
					secondaryValue: root.displayTemp(SystemUsage.gpuTemp)
					temperature: SystemUsage.gpuTemp
					title: SystemUsage.gpuName ? `GPU - ${SystemUsage.gpuName}` : qsTr("GPU")
					usage: SystemUsage.gpuPerc
					visible: Config.dashboard.performance.showGpu && SystemUsage.gpuType !== "NONE"
				}
			}

			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal
				visible: Config.dashboard.performance.showMemory || Config.dashboard.performance.showStorage || Config.dashboard.performance.showNetwork

				GaugeCard {
					Layout.fillWidth: !Config.dashboard.performance.showStorage && !Config.dashboard.performance.showNetwork
					Layout.minimumWidth: 250
					Layout.preferredHeight: 220
					accentColor: DynamicColors.palette.m3tertiary
					icon: "memory_alt"
					percentage: SystemUsage.memPerc
					subtitle: {
						const usedFmt = SystemUsage.formatKib(SystemUsage.memUsed);
						const totalFmt = SystemUsage.formatKib(SystemUsage.memTotal);
						return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
					}
					title: qsTr("Memory")
					visible: Config.dashboard.performance.showMemory
				}

				StorageGaugeCard {
					Layout.fillWidth: !Config.dashboard.performance.showNetwork
					Layout.minimumWidth: 250
					Layout.preferredHeight: 220
					visible: Config.dashboard.performance.showStorage
				}

				NetworkCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 200
					Layout.preferredHeight: 220
					visible: Config.dashboard.performance.showNetwork
				}
			}
		}

		BatteryTank {
			Layout.preferredHeight: mainColumn.implicitHeight
			Layout.preferredWidth: 120
			visible: UPower.displayDevice.isLaptopBattery && Config.dashboard.performance.showBattery
		}
	}

	component BatteryTank: CustomClippingRect {
		id: batteryTank

		property color accentColor: DynamicColors.palette.m3primary
		property real animatedPercentage: 0
		property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
		property real percentage: UPower.displayDevice.percentage

		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large

		Behavior on animatedPercentage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: animatedPercentage = percentage
		onPercentageChanged: animatedPercentage = percentage

		// Background Fill
		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			color: Qt.alpha(batteryTank.accentColor, 0.15)
			height: parent.height * batteryTank.animatedPercentage
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.small

			// Header Section
			ColumnLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.small

				MaterialIcon {
					color: batteryTank.accentColor
					font.pointSize: Appearance.font.size.large
					text: {
						if (!UPower.displayDevice.isLaptopBattery) {
							if (PowerProfiles.profile === PowerProfile.PowerSaver)
								return "energy_savings_leaf";

							if (PowerProfiles.profile === PowerProfile.Performance)
								return "rocket_launch";

							return "balance";
						}
						if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
							return "battery_full";

						const perc = UPower.displayDevice.percentage;
						const charging = [UPowerDeviceState.Charging, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state);
						if (perc >= 0.99)
							return "battery_full";

						let level = Math.floor(perc * 7);
						if (charging && (level === 4 || level === 1))
							level--;

						return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
					}
				}

				CustomText {
					Layout.fillWidth: true
					color: DynamicColors.palette.m3onSurface
					font.pointSize: Appearance.font.size.normal
					text: qsTr("Battery")
				}
			}

			Item {
				Layout.fillHeight: true
			}

			// Bottom Info Section
			ColumnLayout {
				Layout.fillWidth: true
				spacing: -4

				CustomText {
					Layout.alignment: Qt.AlignRight
					color: batteryTank.accentColor
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: Font.Medium
					text: `${Math.round(batteryTank.percentage * 100)}%`
				}

				CustomText {
					Layout.alignment: Qt.AlignRight
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.smaller
					text: {
						if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
							return qsTr("Full");

						if (batteryTank.isCharging)
							return qsTr("Charging");

						const s = UPower.displayDevice.timeToEmpty;
						if (s === 0)
							return qsTr("...");

						const hr = Math.floor(s / 3600);
						const min = Math.floor((s % 3600) / 60);
						if (hr > 0)
							return `${hr}h ${min}m`;

						return `${min}m`;
					}
				}
			}
		}
	}
	component CardHeader: RowLayout {
		property color accentColor: DynamicColors.palette.m3primary
		property string icon
		property string title

		Layout.fillWidth: true
		spacing: Appearance.spacing.small

		MaterialIcon {
			color: parent.accentColor
			fill: 1
			font.pointSize: Appearance.spacing.large
			text: parent.icon
		}

		CustomText {
			Layout.fillWidth: true
			elide: Text.ElideRight
			font.pointSize: Appearance.font.size.normal
			text: parent.title
		}
	}
	component GaugeCard: CustomRect {
		id: gaugeCard

		property color accentColor: DynamicColors.palette.m3primary
		property real animatedPercentage: 0
		readonly property real arcStartAngle: 0.75 * Math.PI
		readonly property real arcSweep: 1.5 * Math.PI
		property string icon
		property real percentage: 0
		property string subtitle
		property string title

		clip: true
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large

		Behavior on animatedPercentage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: animatedPercentage = percentage
		onPercentageChanged: animatedPercentage = percentage

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.smaller

			CardHeader {
				accentColor: gaugeCard.accentColor
				icon: gaugeCard.icon
				title: gaugeCard.title
			}

			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true

				ArcGauge {
					accentColor: gaugeCard.accentColor
					anchors.centerIn: parent
					height: width
					percentage: gaugeCard.animatedPercentage
					startAngle: gaugeCard.arcStartAngle
					sweepAngle: gaugeCard.arcSweep
					trackColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
					width: Math.min(parent.width, parent.height)
				}

				CustomText {
					anchors.centerIn: parent
					color: gaugeCard.accentColor
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: Font.Medium
					text: `${Math.round(gaugeCard.percentage * 100)}%`
				}
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.smaller
				text: gaugeCard.subtitle
			}
		}
	}
	component HeroCard: CustomClippingRect {
		id: heroCard

		property color accentColor: DynamicColors.palette.m3primary
		property real animatedTemp: 0
		property real animatedUsage: 0
		property string icon
		property string mainLabel
		property string mainValue
		readonly property real maxTemp: 100
		property string secondaryLabel
		property string secondaryValue
		readonly property real tempProgress: Math.min(1, Math.max(0, temperature / maxTemp))
		property real temperature: 0
		property string title
		property real usage: 0

		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large

		Behavior on animatedTemp {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}
		Behavior on animatedUsage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: {
			animatedUsage = usage;
			animatedTemp = tempProgress;
		}
		onTempProgressChanged: animatedTemp = tempProgress
		onUsageChanged: animatedUsage = usage

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: parent.top
			color: Qt.alpha(heroCard.accentColor, 0.15)
			implicitWidth: parent.width * heroCard.animatedUsage
		}

		CardHeader {
			accentColor: heroCard.accentColor
			anchors.left: parent.left
			anchors.leftMargin: Appearance.padding.large
			anchors.top: parent.top
			anchors.topMargin: Math.round(Appearance.padding.large * 1.2)
			icon: heroCard.icon
			title: heroCard.title
			width: parent.width - anchors.leftMargin - usageColumn.anchors.rightMargin - usageLabel.width - Appearance.spacing.normal
		}

		Column {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: Math.round(Appearance.padding.large * 1.3)
			anchors.left: parent.left
			anchors.margins: Math.round(Appearance.padding.large * 1.2)
			anchors.right: parent.right
			spacing: Appearance.spacing.small

			Row {
				spacing: Appearance.spacing.small

				CustomText {
					font.pointSize: Appearance.font.size.normal
					font.weight: Font.Medium
					text: heroCard.secondaryValue
				}

				CustomText {
					anchors.baseline: parent.children[0].baseline
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: heroCard.secondaryLabel
				}
			}

			ProgressBar {
				bgColor: Qt.alpha(heroCard.accentColor, 0.2)
				fgColor: heroCard.accentColor
				implicitHeight: 6
				implicitWidth: parent.width * 0.5
				value: heroCard.tempProgress
			}
		}

		Column {
			id: usageColumn

			anchors.margins: Appearance.padding.large
			anchors.right: parent.right
			anchors.rightMargin: 32
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0

			CustomText {
				id: usageLabel

				anchors.right: parent.right
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.normal
				text: heroCard.mainLabel
			}

			CustomText {
				anchors.right: parent.right
				color: heroCard.accentColor
				font.pointSize: Appearance.font.size.extraLarge
				font.weight: Font.Medium
				text: heroCard.mainValue
			}
		}
	}
	component NetworkCard: CustomRect {
		id: networkCard

		property color accentColor: DynamicColors.palette.m3primary

		clip: true
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large

		Ref {
			service: NetworkUsage
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.small

			CardHeader {
				accentColor: networkCard.accentColor
				icon: "swap_vert"
				title: qsTr("Network")
			}

			// Sparkline graph
			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true

				SparklineItem {
					id: sparkline

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

					Behavior on smoothMax {
						Anim {
							duration: Appearance.anim.durations.large
						}
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
						from: 0
						property: "slideProgress"
						target: sparkline
						to: 1
					}
				}

				// "No data" placeholder
				CustomText {
					anchors.centerIn: parent
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					opacity: 0.6
					text: qsTr("Collecting data...")
					visible: NetworkUsage.downloadBuffer.count < 2
				}
			}

			// Download row
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				MaterialIcon {
					color: DynamicColors.palette.m3tertiary
					font.pointSize: Appearance.font.size.normal
					text: "download"
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: qsTr("Download")
				}

				Item {
					Layout.fillWidth: true
				}

				CustomText {
					color: DynamicColors.palette.m3tertiary
					font.pointSize: Appearance.font.size.normal
					font.weight: Font.Medium
					text: {
						const fmt = NetworkUsage.formatBytes(NetworkUsage.downloadSpeed ?? 0);
						return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit}` : "0.0 B/s";
					}
				}
			}

			// Upload row
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				MaterialIcon {
					color: DynamicColors.palette.m3secondary
					font.pointSize: Appearance.font.size.normal
					text: "upload"
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: qsTr("Upload")
				}

				Item {
					Layout.fillWidth: true
				}

				CustomText {
					color: DynamicColors.palette.m3secondary
					font.pointSize: Appearance.font.size.normal
					font.weight: Font.Medium
					text: {
						const fmt = NetworkUsage.formatBytes(NetworkUsage.uploadSpeed ?? 0);
						return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit}` : "0.0 B/s";
					}
				}
			}

			// Session totals
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.normal

				MaterialIcon {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.normal
					text: "history"
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: qsTr("Total")
				}

				Item {
					Layout.fillWidth: true
				}

				CustomText {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.small
					text: {
						const down = NetworkUsage.formatBytesTotal(NetworkUsage.downloadTotal ?? 0);
						const up = NetworkUsage.formatBytesTotal(NetworkUsage.uploadTotal ?? 0);
						return (down && up) ? `↓${down.value.toFixed(1)}${down.unit} ↑${up.value.toFixed(1)}${up.unit}` : "↓0.0B ↑0.0B";
					}
				}
			}
		}
	}
	component ProgressBar: CustomRect {
		id: progressBar

		property real animatedValue: 0
		property color bgColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		property color fgColor: DynamicColors.palette.m3primary
		property real value: 0

		color: bgColor
		radius: Appearance.rounding.full

		Behavior on animatedValue {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: animatedValue = value
		onValueChanged: animatedValue = value

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: parent.top
			color: progressBar.fgColor
			radius: Appearance.rounding.full
			width: parent.width * progressBar.animatedValue
		}
	}
	component StorageGaugeCard: CustomRect {
		id: storageGaugeCard

		property color accentColor: DynamicColors.palette.m3secondary
		property real animatedPercentage: 0
		readonly property real arcStartAngle: 0.75 * Math.PI
		readonly property real arcSweep: 1.5 * Math.PI
		readonly property var currentDisk: SystemUsage.disks.length > 0 ? SystemUsage.disks[currentDiskIndex] : null
		property int currentDiskIndex: 0
		property int diskCount: 0

		clip: true
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.large

		Behavior on animatedPercentage {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		Component.onCompleted: {
			diskCount = SystemUsage.disks.length;
			if (currentDisk)
				animatedPercentage = currentDisk.perc;
		}
		onCurrentDiskChanged: {
			if (currentDisk)
				animatedPercentage = currentDisk.perc;
		}

		// Update diskCount and animatedPercentage when disks data changes
		Connections {
			function onDisksChanged() {
				if (SystemUsage.disks.length !== storageGaugeCard.diskCount)
					storageGaugeCard.diskCount = SystemUsage.disks.length;

				// Update animated percentage when disk data refreshes
				if (storageGaugeCard.currentDisk)
					storageGaugeCard.animatedPercentage = storageGaugeCard.currentDisk.perc;
			}

			target: SystemUsage
		}

		MouseArea {
			anchors.fill: parent

			onWheel: wheel => {
				if (wheel.angleDelta.y > 0)
					storageGaugeCard.currentDiskIndex = (storageGaugeCard.currentDiskIndex - 1 + storageGaugeCard.diskCount) % storageGaugeCard.diskCount;
				else if (wheel.angleDelta.y < 0)
					storageGaugeCard.currentDiskIndex = (storageGaugeCard.currentDiskIndex + 1) % storageGaugeCard.diskCount;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			spacing: Appearance.spacing.smaller

			CardHeader {
				accentColor: storageGaugeCard.accentColor
				icon: "hard_disk"
				title: {
					const base = qsTr("Storage");
					if (!storageGaugeCard.currentDisk)
						return base;

					return `${base} - ${storageGaugeCard.currentDisk.mount}`;
				}

				// Scroll hint icon
				MaterialIcon {
					ToolTip.delay: 500
					ToolTip.text: qsTr("Scroll to switch disks")
					ToolTip.visible: hintHover.hovered
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.normal
					opacity: 0.7
					text: "unfold_more"
					visible: storageGaugeCard.diskCount > 1

					HoverHandler {
						id: hintHover
					}
				}
			}

			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true

				ArcGauge {
					accentColor: storageGaugeCard.accentColor
					anchors.centerIn: parent
					height: width
					percentage: storageGaugeCard.animatedPercentage
					startAngle: storageGaugeCard.arcStartAngle
					sweepAngle: storageGaugeCard.arcSweep
					trackColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
					width: Math.min(parent.width, parent.height)
				}

				CustomText {
					anchors.centerIn: parent
					color: storageGaugeCard.accentColor
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: Font.Medium
					text: storageGaugeCard.currentDisk ? `${Math.round(storageGaugeCard.currentDisk.perc * 100)}%` : "—"
				}
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.smaller
				text: {
					if (!storageGaugeCard.currentDisk)
						return "—";

					const usedFmt = SystemUsage.formatKib(storageGaugeCard.currentDisk.used);
					const totalFmt = SystemUsage.formatKib(storageGaugeCard.currentDisk.total);
					return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
				}
			}
		}
	}
}
