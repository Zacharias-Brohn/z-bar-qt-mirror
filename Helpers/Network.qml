pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
	id: root

	readonly property list<NetworkDevice> devices: Networking.devices.values
	readonly property list<Network> networks: initialBuildNetworks()
	property bool scanning: false
	readonly property list<WifiDevice> wifiDevices: devices.filter(d => wifiDevice(d))
	readonly property bool wifiEnabled: Networking.wifiEnabled

	// Original code

	readonly property list<NetworkDevice> netDevice: Networking.devices.values
	readonly property string networkName: getNetworkName()
	readonly property list<string> nicNames: networkInterfaceCardNames()

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

	// Searches wired/wireless devices and sets them in a list
	function networkInterfaceCardNames() {
		let nicList = [];

		for (let i = 0; i < netDevice.length; ++i) {
			nicList.push(netDevice[i].name);
		}

		return nicList;
	}
	//

	function initialBuildNetworks(): void {
		const init = [];
		for (const d of wifiDevices) {
			d.scannerEnabled = true;
			init.push(...d.networks.values);
			d.scannerEnabled = false;
		}

		networks = init;
	}

	function isSecure(security): bool {
		return !(security === WifiSecurityType.Open);
	}

	function rebuildNetworks(): void {
		if (!scanning)
			return;

		const next = [];
		for (const d of wifiDevices) {
			next.push(...d.networks.values);
		}

		networks = next;
	}

	function rescanWifi(): void {
		scanning = true;
		setScan(true);
		scanTimer.restart();
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

	Timer {
		id: scanTimer

		interval: 5000
		repeat: false

		onTriggered: {
			root.rebuildNetworks();
			root.setScan(false);
			root.scanning = false;
		}
	}

	Timer {
		interval: 500
		repeat: true
		running: root.scanning

		onTriggered: {
			root.rebuildNetworks();
		}
	}
}
