import QtQuick
import QtQuick.Layouts
import ZShell.Services
import qs.Components
import qs.Config

CustomRect {
	id: root

	readonly property color accent: DynamicColors.palette.m3tertiary

	Layout.fillWidth: true
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + Appearance.padding.large * 2
	implicitWidth: layout.implicitWidth + Appearance.padding.extraLargeIncreased
	radius: Appearance.rounding.medium

	ServiceRef {
		service: Gpu
	}

	ColumnLayout {
		id: layout

		anchors.centerIn: parent
		spacing: Appearance.spacing.extraSmall

		RowLayout {
			Layout.leftMargin: -Appearance.padding.extraSmall
			spacing: Appearance.spacing.small

			MaterialIcon {
				color: root.accent
				fill: 1
				text: "memory_alt"
			}

			CustomText {
				text: qsTr("Video memory")
			}
		}

		CircularProgress {
			id: circularIndicator

			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: Appearance.spacing.large
			fgColor: root.accent
			implicitSize: usageColumn.implicitHeight + thickness + Appearance.padding.largeIncreased * 2
			startAngle: -225
			sweepAngle: 270
			value: Gpu.memoryUsed / Gpu.memoryTotal

			Behavior on clampedVal {
				Anim {
				}
			}

			ColumnLayout {
				id: usageColumn

				anchors.centerIn: parent
				anchors.verticalCenterOffset: Appearance.padding.extraSmall
				spacing: 0

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: root.accent
					font.pointSize: Appearance.font.size.large
					text: Math.round(circularIndicator.value * 100) + "%"
				}

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3onSurfaceVariant
					text: qsTr("Used")
				}
			}
		}

		CustomText {
			Layout.alignment: Qt.AlignHCenter
			text: {
				const fmt = UsageFmt.formatKib(Gpu.memoryUsed, Gpu.memoryTotal);
				return `${fmt.value.toFixed(1)} / ${Math.floor(fmt.total)} ${fmt.unit}`;
			}
		}
	}
}
