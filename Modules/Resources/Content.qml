import QtQuick
import QtQuick.Layouts
import ZShell.Services
import qs.Modules.Resources.Cards
import qs.Helpers
import qs.Components
import qs.Config

Item {
	id: root

	required property Wrapper wrapper

	implicitHeight: content.implicitHeight + Appearance.padding.normal * 2
	implicitWidth: content.implicitWidth

	RowLayout {
		id: content

		anchors.left: parent.left
		anchors.margins: Appearance.padding.normal
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.larger

		ColumnLayout {
			id: mainColumn

			Layout.fillWidth: true
			spacing: Appearance.spacing.normal

			RowLayout {
				spacing: Appearance.spacing.normal
				visible: cpuCard.active || gpuCard.active

				WrappedLoader {
					id: cpuCard

					active: Config.dashboard.performance.showCpu

					sourceComponent: HeroCard {
						accent: DynamicColors.palette.m3primary
						icon: "memory"
						label: qsTr("CPU")
						subLabel: Cpu.name
						temperature: Cpu.temperature
						usage: Cpu.percentage

						ServiceRef {
							service: Cpu
						}
					}
				}

				WrappedLoader {
					id: gpuCard

					active: Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None

					sourceComponent: HeroCard {
						accent: DynamicColors.palette.m3secondary
						icon: "desktop_windows"
						label: qsTr("GPU")
						subLabel: Gpu.name
						temperature: Gpu.temperature
						usage: Gpu.percentage

						ServiceRef {
							service: Gpu
						}
					}
				}
			}

			RowLayout {
				spacing: Appearance.spacing.normal
				visible: storageCard.active || memoryCard.active || vramCard.active || networkCard1.active

				WrappedLoader {
					id: storageCard

					active: Config.dashboard.performance.showStorage

					sourceComponent: StorageCard {
					}
				}

				WrappedLoader {
					id: memoryCard

					active: Config.dashboard.performance.showMemory

					sourceComponent: MemoryCard {
					}
				}

				WrappedLoader {
					id: vramCard

					active: Config.dashboard.performance.showVram

					sourceComponent: VramCard {
					}
				}

				WrappedLoader {
					id: networkCard1

					active: Config.dashboard.performance.showNetwork && !vramCard.active

					sourceComponent: NetworkCard {
					}
				}
			}

			WrappedLoader {
				id: networkCard2

				active: Config.dashboard.performance.showNetwork && vramCard.active

				sourceComponent: NetworkCard {
				}
			}
		}

		WrappedLoader {
			Layout.fillWidth: false
			active: Battery.isLaptop && Config.dashboard.performance.showBattery

			sourceComponent: BatteryTank {
			}
		}
	}

	component WrappedLoader: Loader {
		Layout.fillHeight: true
		Layout.fillWidth: true
		visible: active
	}
}
