pragma Singleton

import Quickshell
import QtQuick
import qs.Config

Singleton {
	id: root

	property bool enabled
	readonly property int end: Config.general.color.scheduleHyprsunsetEnd
	property bool manualToggle: false
	readonly property int start: Config.general.color.scheduleHyprsunsetStart
	readonly property int temp: Config.general.color.hyprsunsetTemp

	function checkStartup(): void {
		if (!Config.general.color.scheduleHyprsunset)
			return;

		var now = new Date();
		if (now.getHours() >= root.start || now.getHours() < root.end) {
			root.startNightLight(root.temp);
		} else {
			root.stopNightLight();
		}
	}

	function startNightLight(temp: int): void {
		Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", `${temp}`]);
		root.enabled = true;
	}

	function stopNightLight(): void {
		Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
		root.enabled = false;
	}

	function toggleNightLight(): void {
		if (enabled)
			stopNightLight();
		else
			startNightLight(temp);
	}

	onManualToggleChanged: {
		if (root.manualToggle)
			manualTimer.start();
	}

	Timer {
		id: manualTimer

		interval: 60000 * 60
		repeat: false
		running: false

		onTriggered: {
			root.manualToggle = false;
		}
	}

	Timer {
		interval: 5000
		repeat: true
		running: true
		triggeredOnStart: true

		onTriggered: {
			if (!Config.general.color.scheduleHyprsunset)
				return;

			if (root.manualToggle)
				return;

			var now = new Date();
			if (now.getHours() >= root.start || now.getHours() < root.end) {
				if (!root.enabled)
					root.startNightLight(root.temp);
			} else {
				if (root.enabled)
					root.stopNightLight();
			}
		}
	}
}
