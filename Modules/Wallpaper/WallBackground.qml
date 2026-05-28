pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config
import ZShell.Internal

Item {
	id: root

	required property ShellScreen screen
	property string source: Wallpapers.current

	function refreshData(): void {
		Hyprland.refreshMonitors();
		let scale = Hyprland.monitorFor(root.screen).scale;
		if (scale <= 0)
			scale = 1.0; // Fallback to avoid zeroes on initialization

		if (root.screen.width > 0 && root.screen.height > 0) {
			img.screenResolution = Qt.size(root.screen.width * scale, root.screen.height * scale);
		}

		const displayData = Wallpapers.getCrop(root.screen.name);

		if (displayData) {
			img.cropX = displayData.x !== undefined ? displayData.x : 0.0;
			img.cropY = displayData.y !== undefined ? displayData.y : 0.0;
			img.cropWidth = (displayData.width !== undefined && displayData.width > 0) ? displayData.width : 1.0;
			img.cropHeight = (displayData.height !== undefined && displayData.height > 0) ? displayData.height : 1.0;
		}
	}

	anchors.fill: parent

	Component.onCompleted: root.refreshData()

	Connections {
		function onHeightChanged() {
			root.refreshData();
		}

		function onWidthChanged() {
			root.refreshData();
		}

		target: root.screen
	}

	WallpaperImage {
		id: img

		anchors.fill: parent
		source: root.source

		Behavior on cropHeight {
			Anim {
			}
		}
		Behavior on cropWidth {
			Anim {
			}
		}
		Behavior on cropX {
			Anim {
			}
		}
		Behavior on cropY {
			Anim {
			}
		}
		Behavior on zoom {
			Anim {
			}
		}

		Connections {
			function onAdapterUpdated(): void {
				root.refreshData();
			}

			function onLoaded(): void {
				root.refreshData();
			}

			target: Wallpapers.monitorCrops
		}
	}
}
