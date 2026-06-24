import QtQuick
import QtQuick.Layouts
import Quickshell
import ZShell.Services
import qs.Components
import qs.Config

CustomRect {
	id: root

	readonly property color accent: DynamicColors.palette.m3secondary
	readonly property real percentage: Storage.primaryDisk?.perc ?? 0

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + Appearance.padding.large * 2
	implicitWidth: layout.implicitWidth + layout.anchors.margins * 2
	radius: Appearance.rounding.large - Appearance.padding.normal

	ServiceRef {
		service: Storage
	}

	ColumnLayout {
		id: layout

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: 0

		RowLayout {
			id: row

			Layout.alignment: Qt.AlignHCenter
			spacing: Appearance.spacing.large

			CircularProgress {
				fgColor: root.accent
				implicitSize: usageColumn.implicitHeight + thickness + Appearance.padding.large * 2
				startAngle: -225
				sweepAngle: 270
				value: root.percentage

				Behavior on clampedVal {
					Anim {
					}
				}

				ColumnLayout {
					id: usageColumn

					anchors.centerIn: parent
					spacing: 0

					MaterialIcon {
						Layout.alignment: Qt.AlignHCenter
						color: root.accent
						font.pointSize: Appearance.font.size.medium
						text: "hard_drive"
					}

					CustomText {
						Layout.alignment: Qt.AlignHCenter
						color: root.accent
						font.pointSize: Appearance.font.size.large
						text: Math.round(root.percentage * 100) + "%"
					}

					CustomText {
						Layout.alignment: Qt.AlignHCenter
						color: DynamicColors.palette.m3onSurfaceVariant
						text: qsTr("Used")
					}
				}
			}

			ColumnLayout {
				spacing: Appearance.spacing.extraSmall

				CustomText {
					text: qsTr("Storage")
				}

				CustomText {
					color: root.accent
					text: {
						if (!Storage.primaryDisk)
							return qsTr("No disks detected");

						const fmt = UsageFmt.formatKib(Storage.primaryDisk.used, Storage.primaryDisk.total);
						return `${fmt.value.toFixed(1)} / ${Math.floor(fmt.total)} ${fmt.unit}`;
					}
				}
			}
		}

		CustomSplitButton {
			Layout.alignment: Qt.AlignHCenter
			active: menuItems.find(m => m.modelData === Storage.primaryDisk) ?? menuItems[0] ?? null
			enabled: Storage.disks.length
			fallbackIcon: "storage"
			fallbackText: qsTr("No disks")
			menuItems: disks.instances
			minLeftWidth: row.implicitWidth * 0.6
			type: CustomSplitButton.Tonal

			menu.onItemSelected: item => Storage.manualPrimaryDisk = (item as DiskItem).modelData

			Variants {
				id: disks

				model: Storage.disks

				DiskItem {
				}
			}
		}
	}

	component DiskItem: MenuItem {
		required property var modelData

		activeIcon: "storage"
		icon: modelData === Storage.primaryDisk ? "check" : ""
		text: modelData.mount
	}
}
