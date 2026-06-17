//@ pragma UseQApplication
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
// @ pragma DefaultEnv QSG_RHI_BACKEND=vulkan
//@ pragma DefaultEnv QSG_NO_VSYNC=1
//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QT_SCALE_FACTOR_ROUNDING_POLICY=Round
//@ pragma DefaultEnv QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma DropExpensiveFonts
import Quickshell
import Quickshell.Services.UPower
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

	Drawers {
	}

	Wallpaper {
	}

	AreaPicker {
	}

	Lock {
		id: lock
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
