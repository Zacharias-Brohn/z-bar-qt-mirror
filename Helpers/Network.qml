pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
	id: root

	readonly property list<NetworkDevice> network: Networking.devices.values
}
