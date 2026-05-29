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

	function nearestThresholdAbove(p: real): var {
		const thresholds = [...root.popupThresholds];
		for (const perc of thresholds) {
			console.log(perc.message);
			if (p < perc.perc)
				return perc;
		}

		return null;
	}

	Connections {
		function onOnBatteryChanged(): void {
			if (!UPower.displayDevice.ready)
				return;

			if (UPower.onBattery) {
				if (Config.utilities.toasts.chargingChanged)
					Toaster.toast(qsTr("Charger unplugged"), qsTr("Battery is discharging"), "power_off");
				const p = root.currentPerc * 100;
				const perc = root.nearestThresholdAbove(p);
				if (perc)
					Toaster.toast(perc.title ?? qsTr("Battery warning"), perc.message ?? qsTr("Battery is low"), perc.icon ?? "battery_android_alert", perc.critical ? Toast.Error : Toast.Warning);
			} else {
				if (Config.utilities.toasts.chargingChanged)
					Toaster.toast(qsTr("Charger plugged in"), qsTr("Battery is charging"), "power");
			}
		}

		target: UPower
	}

	Connections {
		function onPercentageChanged(): void {
			if (!UPower.onBattery)
				return;

			const p = root.currentPerc * 100;
			for (const perc of root.popupThresholds) {
				if (p == perc.perc) {
					Toaster.toast(perc.title ?? qsTr("Battery warning"), perc.message ?? qsTr("Battery perc is low"), perc.icon ?? "battery_android_alert", perc.critical ? Toast.Error : Toast.Warning);
				}
			}
		}

		function onReadyChanged(): void {
			if (!UPower.displayDevice.ready)
				return;

			const p = root.currentPerc * 100;
			const perc = root.nearestThresholdAbove(p);
			if (perc)
				Toaster.toast(perc.title ?? qsTr("Battery warning"), perc.message ?? qsTr("Battery is low"), perc.icon ?? "battery_android_alert", perc.critical ? Toast.Error : Toast.Warning);
		}

		target: UPower.displayDevice
	}
}
