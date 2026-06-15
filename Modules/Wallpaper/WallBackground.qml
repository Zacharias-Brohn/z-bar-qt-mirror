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

	property bool completed
	property real cropHeight: displayData.height ?? 1.0
	property real cropWidth: displayData.width ?? 1.0
	property real cropX: displayData.x ?? 0.0
	property real cropY: displayData.y ?? 0.0
	property WallpaperImage current
	readonly property var displayData: Wallpapers.getCrop(screen.name)
	required property ShellScreen screen
	property size screenResolution: Qt.size(screen.width * screenScale, screen.height * screenScale)
	property real screenScale: Hyprland.monitorFor(screen).scale
	property string source: Wallpapers.current

	anchors.fill: parent

	Component.onCompleted: {
		Hyprland.refreshMonitors();

		if (source)
			Qt.callLater(() => {
				current = imgComp.createObject(this, {
					source
				});
				completed = true;
			});
	}
	onSourceChanged: {
		if (!source)
			current = null;
		else
			current = imgComp.createObject(this, {
				source: source
			});
	}

	Component {
		id: imgComp

		WallpaperImage {
			id: img

			anchors.fill: parent
			cropHeight: root.cropHeight
			cropWidth: root.cropWidth
			cropX: root.cropX
			cropY: root.cropY
			opacity: 0
			screenResolution: root.screenResolution
			source: root.source

			Behavior on cropHeight {
				Anim {
					id: heightAnim
				}
			}
			Behavior on cropWidth {
				Anim {
					id: widthAnim
				}
			}
			Behavior on cropX {
				Anim {
					id: xAnim
				}
			}
			Behavior on cropY {
				Anim {
					id: yAnim
				}
			}
			Anim on opacity {
				id: anim

				from: 0
				running: false
				to: 1
				type: Anim.SlowEffects
			}

			onStatusChanged: {
				if (status === Image.Ready) {
					anim.start();
				}
			}

			Timer {
				id: destroyTimer

				interval: anim.duration * 2
				running: root.current !== img && root.current?.status === Image.Ready

				onTriggered: Qt.callLater(() => img.destroy())
			}
		}
	}
}
