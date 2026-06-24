pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import qs.Config

Singleton {
	id: root

	readonly property var colors: {
		if (deviceState === UPowerDeviceState.Charging || deviceState === UPowerDeviceState.FullyCharged)
			return {
				fg: DynamicColors.swapRG(DynamicColors.palette.m3error),
				bg: DynamicColors.swapRG(DynamicColors.palette.m3onError)
			};
		else if (currentPerc <= 0.2)
			return {
				fg: DynamicColors.palette.m3error,
				bg: DynamicColors.palette.m3onError
			};
		else
			return {
				fg: DynamicColors.palette.m3onSurface,
				bg: DynamicColors.palette.m3surface
			};
	}
	readonly property real currentPerc: UPower.displayDevice.percentage
	readonly property var deviceState: UPower.displayDevice.state
	readonly property bool isLaptop: UPower.displayDevice.isLaptopBattery
	readonly property bool onBattery: UPower.onBattery
	readonly property bool ready: UPower.displayDevice.ready
	readonly property real timeToEmpty: UPower.displayDevice.timeToEmpty
	readonly property real timeToFull: UPower.displayDevice.timeToFull
}
