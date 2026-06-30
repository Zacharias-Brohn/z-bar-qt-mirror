pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	property bool closed: true
	property Component currentPopup: null

	function requestClose(): void {
		closed = true;
	}

	function requestOpen(component: Component): void {
		currentPopup = component;
		closed = false;
	}
}
