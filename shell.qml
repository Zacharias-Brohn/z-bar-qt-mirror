//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
// @ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QSG_NO_VSYNC=1
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_SCALE_FACTOR_ROUNDING_POLICY=Round
//@ pragma DropExpensiveFonts
import Quickshell
import Quickshell.Services.UPower
import ZShell
import qs.Modules
import qs.Modules.Wallpaper
import qs.Modules.Lock
import qs.Drawers
import qs.Helpers
import qs.Modules.Polkit
import qs.Daemons

ShellRoot {
	id: root

	readonly property bool laptop: UPower.displayDevice.isLaptopBattery

	settings.watchFiles: true

	Windows {
	}

	Wallpaper {
	}

	AreaPicker {
	}

	Lock {
		id: lock
	}

	Connections {
		function onLidClosing(): void {
			lock.locked = true;
		}

		target: LidWatcher
	}

	Shortcuts {
	}

	IdleMonitors {
		lock: lock
	}

	Polkit {
	}

	LazyLoader {
		activeAsync: root.laptop

		component: BatteryService {
		}
	}
}
