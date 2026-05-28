pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import ZShell.Models
import qs.Config
import qs.Modules
import qs.Helpers
import qs.Paths

Searcher {
	id: root

	property string actualCurrent: WallpaperPath.currentWallpaperPath
	property alias crops: adapter.monitorCrops
	readonly property string current: showPreview ? previewPath : actualCurrent
	property alias monitorCrops: monitorCrops
	property string previewPath
	property bool recentlyChanged
	property bool showPreview: false

	function getCrop(screen: string): var {
		return root.crops[screen];
	}

	function preview(path: string): void {
		previewPath = path;
		if (Config.general.color.schemeGeneration)
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--image-path", `${previewPath}`, "--scheme", `${Config.colors.schemeType}`, "--mode", `${Config.general.color.mode}`]);
		showPreview = true;
	}

	function setCrop(screen: string, rect: rect, scaledRect: rect, zoom: real): void {
		let updated = Object.assign({}, root.crops);

		if (zoom <= 0)
			zoom = 1.0;
		else if (zoom > 5.0)
			zoom = 5.0;

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
	}

	function setWallpaper(path: string): void {
		actualCurrent = path;
		WallpaperPath.currentWallpaperPath = path;
		Quickshell.screens.forEach(n => setCrop(n.name, Qt.rect(0, 0, 1, 1), Qt.rect(0, 0, 0, 0), 1.0));
		Quickshell.execDetached(["zshell-cli", "wallpaper", "lockscreen", "--input-image", `${root.actualCurrent}`, "--output-path", `${Paths.state}/lockscreen_bg.png`, "--blur-amount", `${Config.lock.blurAmount}`]);
		if (Config.general.color.schemeGeneration)
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--image-path", `${root.actualCurrent}`, "--scheme", `${Config.colors.schemeType}`, "--mode", `${Config.general.color.mode}`]);
	}

	function stopPreview(): void {
		showPreview = false;
		if (Config.general.color.schemeGeneration)
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--image-path", `${root.actualCurrent}`, "--scheme", `${Config.colors.schemeType}`, "--mode", `${Config.general.color.mode}`]);
	}

	extraOpts: useFuzzy ? ({}) : ({
			forward: false
		})
	key: "relativePath"
	list: wallpapers.entries
	useFuzzy: true

	IpcHandler {
		function set(path: string): void {
			root.setWallpaper(path);
		}

		target: "wallpaper"
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

	FileSystemModel {
		id: wallpapers

		filter: FileSystemModel.Images
		path: Config.general.wallpaperPath
		recursive: true
	}
}
