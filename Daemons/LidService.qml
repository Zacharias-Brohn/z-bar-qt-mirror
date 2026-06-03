import Quickshell
import QtQuick

Scope {
	id: root

	signal requestLock

	Connections {
		function onStateChanged(): void {
			if (LidWatcher.state === LidWatcher.Closed)
				root.requestLock();
		}

		target: LidWatcher
	}
}
