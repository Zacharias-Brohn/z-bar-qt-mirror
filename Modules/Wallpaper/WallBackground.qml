pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property ShellScreen screen
	property string source: Wallpapers.current

	anchors.fill: parent

	Image {
		id: img

		asynchronous: true
		fillMode: Image.Stretch
		opacity: 1
		retainWhileLoading: true
		source: root.source
		sourceSize.height: root.screen.height
		sourceSize.width: root.screen.width

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

		Connections {
			function onAdapterUpdated(): void {
				const displayData = Wallpapers.getCrop(root.screen.name);
				const displayRect = Qt.rect(displayData.x, displayData.y, displayData.width, displayData.height);
				const scale = root.screen.width / displayData.width;
				if (displayRect.width > 0 && displayRect.height > 0) {
					img.anchors.fill = null;
					img.x = -displayRect.x;
					img.y = -displayRect.y;
					img.width = img.implicitWidth * scale;
					img.height = img.implicitHeight * scale;
				} else {
					img.anchors.fill = root;
				}
			}

			function onLoaded(): void {
				const displayData = Wallpapers.getCrop(root.screen.name);
				const displayRect = Qt.rect(displayData.x, displayData.y, displayData.width, displayData.height);
				const scale = root.screen.width / displayData.width;
				if (displayRect.width > 0 && displayRect.height > 0) {
					img.anchors.fill = null;
					img.x = -displayRect.x;
					img.y = -displayRect.y;
					img.width = img.implicitWidth * scale;
					img.height = img.implicitHeight * scale;
				} else {
					img.anchors.fill = root;
				}
			}

			target: Wallpapers.monitorCrops
		}
	}
}
