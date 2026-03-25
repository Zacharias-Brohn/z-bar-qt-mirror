//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QSG_USE_SIMPLE_ANIMATION_DRIVER=0
//@ pragma Env QS_NO_RELOAD_POPUP=1
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Components

ShellRoot {
	id: root

	GreeterState {
		id: greeter

	}

	GreeterSurface {
		id: greeterSurface

		greeter: greeter
	}

	Connections {
		function onLastWindowClosed(): void {
			Qt.quit();
		}

		target: Quickshell
	}
}
