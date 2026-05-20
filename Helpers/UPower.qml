pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
	id: root

	readonly property real batteryPercent: UPower.displayDevice.percentage
	readonly property list<UPowerDevice> devices: UPower.devices.values
	readonly property UPowerDevice displayDevice: UPower.displayDevice
	readonly property bool onBattery: UPower.onBattery
	// property bool toastShown
	//
	// Connections {
	// 	target: UPower
	//
	// 	function onPercentageChanged(): {
	// 		if (root.batteryPercent >= 0.2 && toastShown)
	// 			return;
	//
	// 		root.toastShown = true;
	// 		Toaster.toast(qsTr("Battery "))
	// 	}
	// }
}
