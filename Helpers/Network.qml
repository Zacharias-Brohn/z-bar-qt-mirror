pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
	id: root

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
}
