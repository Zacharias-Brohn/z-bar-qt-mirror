//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
// @ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QSG_NO_VSYNC=1
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_SCALE_FACTOR_ROUNDING_POLICY=Round
//@ pragma DropExpensiveFonts
import Quickshell
import qs.Modules
import qs.Modules.Wallpaper
import qs.Modules.Lock
import qs.Drawers
import qs.Helpers
import qs.Modules.Polkit

ShellRoot {
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

	Shortcuts {
	}

	IdleMonitors {
		lock: lock
	}

	Polkit {
	}
}
