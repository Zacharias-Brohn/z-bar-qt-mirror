pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking
import qs.Components
import qs.Config
import qs.Modules
import qs.Helpers as Helpers

item {
	id: root

	function networkScan() {
		Networking.scanForNetworks();
	}
}
