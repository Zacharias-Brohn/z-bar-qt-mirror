import Quickshell
import Quickshell.Services.UPower
import QtQuick
import ZShell
import qs.Config
import qs.Components.Toast

Scope {
	id: root

	readonly property real currentPerc: UPower.displayDevice.percentage
	readonly property list<var> popupThresholds: [...Config.general.battery.popupThresholds].sort((a, b) => b.perc - a.perc)

	Connections {
		function onOnBatteryChanged(): void {
			if (UPower.onBattery) {
				if (Config.utilities.toasts.chargingChanged)
					Toaster.toast(qsTr("Charger unplugged"), qsTr("Battery is discharging"), "power_off");
			} else {
				if (Config.utilities.toasts.chargingChanged)
					Toaster.toast(qsTr("Charger plugged in"), qsTr("Battery is charging"), "power");
				for (const level of root.popupThresholds)
					level.warned = false;
			}
		}

		target: UPower
	}

	Connections {
		function onPercentageChanged(): void {
			if (!UPower.onBattery)
				return;

			const p = UPower.displayDevice.percentage * 100;
			for (const perc of root.popupThresholds) {
				if (p <= perc.perc && !perc.warned) {
					perc.warned = true;
					console.log(perc.warned + "\n" + [...Config.general.battery.popupThresholds][0].warned);
					Toaster.toast(perc.title ?? qsTr("Battery warning"), perc.message ?? qsTr("Battery perc is low"), perc.icon ?? "battery_android_alert", perc.critical ? Toast.Error : Toast.Warning);
				}
			}
		}

		target: UPower.displayDevice
	}
}
