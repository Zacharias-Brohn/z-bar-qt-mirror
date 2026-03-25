pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	property string highlightedSetting: ""

	function clear() {
		highlightedSetting = "";
	}

	function highlight(settingName: string) {
		highlightedSetting = settingName;
		highlightTimer.restart();
	}

	Timer {
		id: highlightTimer

		interval: 2000

		onTriggered: root.clear()
	}
}
