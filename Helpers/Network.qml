pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
	id: root

	property bool active: false
	readonly property list<NetworkDevice> devices: Networking.devices.values
	readonly property list<Network> knownNetworks: networks.filter(n => n.known)

	// Original code

	readonly property list<NetworkDevice> netDevice: Networking.devices.values
	readonly property string networkName: getNetworkName()
	readonly property list<Network> networks: {
		const list = [];
		for (const d of wifiDevices)
			list.push(...d.networks.values);
		return list;
	}
	readonly property list<string> nicNames: networkInterfaceCardNames()
	property bool scanning: false
	readonly property list<Network> unknownNetworks: networks.filter(n => !n.known)
	readonly property list<WifiDevice> wifiDevices: devices.filter(d => wifiDevice(d))
	readonly property bool wifiEnabled: Networking.wifiEnabled

	// Useless will prob remove
	function getConnectedDevices() {
		let connectedDevices = [];

		for (var i = 0; i < netDevice.length; i++) {
			if (netDevice[i].connected === true) {
				connectedDevices.push(netDevice[i].name);
			}
		}
		return connectedDevices;
	}

	// SHOULD retrieve network names of connected devices
	// Currently only gives connected nic name
	function getNetworkName() {
		const devices = netDevice.filter(device => device.connected === true);
		for (var i = 0; i < devices.length; i++) {
			return devices[i].name;
		}
		return "Failed network name";
	}

	//

	function isSecure(security): bool {
		return (security === WifiSecurityType.WpaPsk || security === WifiSecurityType.Wpa2Psk || security === WifiSecurityType.Sae);
	}

	// Searches wired/wireless devices and sets them in a list
	function networkInterfaceCardNames() {
		let nicList = [];

		for (let i = 0; i < netDevice.length; ++i) {
			nicList.push(netDevice[i].name);
		}

		return nicList;
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
