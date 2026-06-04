pragma Singleton

import Quickshell
import QtQuick
import ZShell.Services
import qs.Config

Singleton {
	id: root

	readonly property bool enabled: service.enabled
	readonly property int end: Config.general.color.scheduleHyprsunsetEnd
	property bool manualToggle: false
	readonly property int start: Config.general.color.scheduleHyprsunsetStart
	readonly property int temp: Config.general.color.hyprsunsetTemp

	function checkStartup(): void {
		if (!Config.general.color.scheduleHyprsunset)
			return;

		service.apply();
	}

	function toggleNightLight(): void {
		service.manualToggle = true;
		service.toggle();
	}

	HyprsunsetManager {
		id: service

		activeAuto: Config.general.color.scheduleHyprsunset
		endTime: root.end
		startTime: root.start
		temp: root.temp
	}
}
