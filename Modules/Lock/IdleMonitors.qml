pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import ZShell.internal
import qs.Config
import qs.Helpers

Scope {
	id: root

	readonly property bool enabled: !Players.list.some(p => p.isPlaying)
	required property Lock lock

	function handleIdleAction(action: var): void {
		if (!action)
			return;

		if (action === "lock")
			lock.lock.locked = true;
		else if (action === "unlock")
			lock.lock.locked = false;
		else if (action === "dpms on")
			Hypr.dispatch('hl.dsp.dpms({ action = "enable" })');
		else if (action === "dpms off")
			Hypr.dispatch('hl.dsp.dpms({ action = "disable" })');
		else if (typeof action === "string")
			Hypr.dispatch(action);
		else
			Quickshell.execDetached(action);
	}

    LidWatcher {
        onAboutToSleep: root.lock.lock.locked = true
    }

	Variants {
		model: Config.general.idle.timeouts

		IdleMonitor {
			required property var modelData

			enabled: root.enabled && modelData.timeout > 0 ? true : false
			timeout: modelData.timeout

			onIsIdleChanged: root.handleIdleAction(isIdle ? modelData.idleAction : modelData.activeAction)
		}
	}
}
