import QtQuick
import QtQuick.Layouts
import ZShell.Services
import qs.Components
import qs.Config

CustomRect {
	id: root

	readonly property color accent: DynamicColors.palette.m3tertiary

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + Appearance.padding.large * 2
	implicitWidth: layout.implicitWidth + Appearance.padding.extraLargeIncreased * 2
	radius: Appearance.rounding.medium

	ServiceRef {
		service: Memory
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
				text: qsTr("Memory")
			}
		}

		CircularProgress {
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: Appearance.spacing.large
			fgColor: root.accent
			implicitSize: usageColumn.implicitHeight + thickness + Appearance.padding.largeIncreased * 2
			startAngle: -225
			sweepAngle: 270
			value: Memory.percentage

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
					text: Math.round(Memory.percentage * 100) + "%"
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
				const fmt = UsageFmt.formatKib(Memory.used, Memory.total);
				return `${fmt.value.toFixed(1)} / ${Math.floor(fmt.total)} ${fmt.unit}`;
			}
		}
	}
}
