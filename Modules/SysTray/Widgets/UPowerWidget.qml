import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers as Helpers

RowLayout {
	id: root

	MaterialIcon {
		Layout.alignment: Qt.AlignVCenter
		animate: true
		color: !Helpers.UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3error
		fill: 1
		text: {
			if (!Helpers.UPower.displayDevice.isLaptopBattery) {
				if (PowerProfiles.profile === PowerProfile.PowerSaver)
					return "nest_eco_leaf";
				if (PowerProfiles.profile === PowerProfile.Performance)
					return "bolt";
				return "power_settings_new";
			}

			const perc = Helpers.UPower.displayDevice.percentage;
			const charging = [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(Helpers.UPower.displayDevice.state);
			if (perc === 1)
				return charging ? "battery_charging_full" : "battery_full";
			let level = Math.floor(perc * 7);
			if (charging && (level === 4 || level === 1))
				level--;
			return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
		}
	}
}
