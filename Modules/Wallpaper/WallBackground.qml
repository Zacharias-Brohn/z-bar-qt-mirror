pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property ShellScreen screen
	property string source: Wallpapers.current

	function refreshData(): void {
		Hyprland.refreshMonitors();
		const scale = Hyprland.monitorFor(root.screen).scale;
		if (scale > 0 && img.resScale !== scale) {
			img.resScale = scale;
			img.sourceSize.width = root.screen.width * scale;
		}
		const displayData = Wallpapers.getCrop(root.screen.name);
		const displayRect = Qt.rect(img.sourceSize.width * displayData.x, img.implicitHeight * displayData.y, img.sourceSize.width * displayData.width, img.implicitHeight * displayData.height);
		img.anchors.fill = null;
		img.zoom = displayData.zoom;
		img.x = -(displayRect.x * displayData.zoom / img.resScale);
		img.y = -(displayRect.y * displayData.zoom / img.resScale);
	}

	anchors.fill: parent

	Image {
		id: img

		property int displayH
		property int displayW
		property real resScale
		property real zoom: 1.0

		asynchronous: true
		fillMode: Image.PreserveAspectCrop
		height: implicitHeight * zoom / resScale
		opacity: 1
		retainWhileLoading: true
		source: root.source
		sourceSize.width: root.screen.width * resScale
		width: implicitWidth * zoom / resScale

		Behavior on height {
			Anim {
			}
		}
		Behavior on width {
			Anim {
			}
		}
		Behavior on x {
			Anim {
			}
		}
		Behavior on y {
			Anim {
			}
		}

		onStatusChanged: {
			if (img.status == Image.Ready) {
				root.refreshData();
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
