//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
// @ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QSG_NO_VSYNC=1
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_SCALE_FACTOR_ROUNDING_POLICY=Round
//@ pragma DropExpensiveFonts
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import qs.Modules
import qs.Modules.Wallpaper
import qs.Modules.Lock
import qs.Drawers
import qs.Helpers
import qs.Config
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

        lid: lid
	}

	Shortcuts {
	}

	IdleMonitors {
		lock: lock
	}

	Polkit {
	}

	LazyLoader {
		id: lid

		activeAsync: Config.lock.lidWatch && Battery.isLaptop

		component: LidService {
			onRequestLock: lock.lock.requestLock()
		}
	}

	LazyLoader {
		activeAsync: root.laptop

		component: BatteryService {
		}
	}
}
