pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
	id: root

	property bool active: false
	readonly property list<NetworkDevice> devices: Networking.devices.values
	readonly property list<Network> knownNetworks: networks.filter(n => n.known)
	readonly property list<Network> networks: {
		const list = [];
		for (const d of wifiDevices) {
			for (const n of d.networks.values) {
				if (!list.includes(n))
					list.push(n);
			}
		}
		return list;
	}
	property bool scanning: false
	readonly property list<Network> unknownNetworks: networks.filter(n => !n.known)
	readonly property list<WifiDevice> wifiDevices: devices.filter(d => wifiDevice(d))
	readonly property bool wifiEnabled: Networking.wifiEnabled

	function isSecure(security): bool {
		return (security === WifiSecurityType.WpaPsk || security === WifiSecurityType.Wpa2Psk || security === WifiSecurityType.Sae);
	}

	function setScan(value: bool): void {
		for (const d of wifiDevices) {
			d.scannerEnabled = value;
		}
	}

	function setWifi(value: bool): void {
		Networking.wifiEnabled = value;
	}

	function wifiDevice(dev): bool {
		return dev.type === DeviceType.Wifi;
	}

	onActiveChanged: {
		for (const d of wifiDevices)
			d.scannerEnabled = active;
	}
}
