pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Components

Scope {
	id: root

	required property var lid
	property alias lock: lock
	property int seenOnce: 0

	WlSessionLock {
		id: lock

		signal requestLock
		signal unlock

		onRequestLock: lock.locked = true
		onUnlock: lock.locked = false

		Connections {
			target: root.lid
            function onRequestLock(): void {
                lock.locked = true
            }
		}

		LockSurface {
			id: lockSurface

			lock: lock
			pam: pam
		}
	}

	Pam {
		id: pam

		lock: lock
	}

	IpcHandler {
		function lock() {
			return lock.locked = true;
		}

		target: "lock"
	}

	CustomShortcut {
		description: "Lock the current session"
		name: "lock"

		onPressed: {
			lock.locked = true;
		}
	}
}
