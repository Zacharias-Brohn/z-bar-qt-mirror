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

		anchors.fill: parent
		asynchronous: true
		fillMode: Image.PreserveAspectCrop
		opacity: 1
		retainWhileLoading: true
		source: root.source
		sourceClipRect: Wallpapers.recentlyChanged ? null : Qt.rect(Config.background.sourceClipX, Config.background.sourceClipY, Config.background.sourceClipW, Config.background.sourceClipH)
		sourceSize.height: root.screen.height
		sourceSize.width: root.screen.width

		onSourceChanged: {
			if (Wallpapers.recentlyChanged) {
				Config.background.sourceClipH = 0;
				Config.background.sourceClipW = 0;
				Config.background.sourceClipY = 0;
				Config.background.sourceClipX = 0;
				Config.background.zoom = 1.0;
				Config.save();
			}
			Wallpapers.recentlyChanged = true;
		}
	}
}
