pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root

	property alias crops: adapter.monitorCrops
	property alias monitorCrops: monitorCrops
	property string previewPath
	property bool recentlyChanged
	property bool showPreview: false

	function getCrop(screen: string): var {
		return root.crops[screen];
	}

	function setCrop(screen: string, rect: rect, scaledRect: rect, zoom: real): void {
		let updated = Object.assign({}, root.crops);

		updated[screen] = {
			x: rect.x,
			y: rect.y,
			width: rect.width,
			height: rect.height,
			scaledX: scaledRect.x,
			scaledY: scaledRect.y,
			scaledWidth: scaledRect.width,
			scaledHeight: scaledRect.height,
			zoom: zoom
		};

		root.crops = updated;
		monitorCrops.writeAdapter();
		monitorCrops.reload();
	}

	FileView {
		id: monitorCrops

		path: `${Paths.state}/wallpaper-crops.json`
		watchChanges: true

		onAdapterUpdated: writeAdapter()
		onFileChanged: reload()

		JsonAdapter {
			id: adapter

			property var monitorCrops: ({})
		}
	}
}
