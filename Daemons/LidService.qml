import Quickshell
import ZShell
import QtQuick

Scope {
	id: root

	required property var lock

	Connections {
		function onLidClosing(): void {
			root.lock.lock.locked = true;
		}

		target: LidWatcher
	}
}
