pragma ComponentBehavior: Bound

import QtQuick
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	property Image current: one
	property string source: Wallpapers.current

	anchors.fill: parent

	Component.onCompleted: {
		if (source)
			Qt.callLater(() => one.update());
	}
	onSourceChanged: {
		if (!source) {
			current = null;
		} else if (current === one) {
			two.update();
		} else {
			one.update();
		}
	}

	Img {
		id: one
	}

	Img {
		id: two
	}

	component Img: CachingImage {
		id: img

		property real imageRatio: Math.max(1, sourceSize.width) / Math.max(1, sourceSize.height)
		property bool isValid: sourceSize.width > 0 && sourceSize.height > 0 && root.width > 0 && root.height > 0
		property real windowRatio: root.width / Math.max(1, root.height)

		function update(): void {
			if (path === root.source) {
				root.current = this;
			} else {
				path = root.source;
			}
		}

		anchors.fill: undefined
		asynchronous: true
		fillMode: Image.PreserveAspectCrop
		height: isValid ? (imageRatio > windowRatio ? root.height : root.width / imageRatio) * Config.background.zoom : root.height
		opacity: 0
		scale: Wallpapers.showPreview ? 1 : 0.8
		width: isValid ? (imageRatio > windowRatio ? root.height * imageRatio : root.width) * Config.background.zoom : root.width
		x: isValid ? (root.width - width) * Config.background.alignX : 0
		y: isValid ? (root.height - height) * Config.background.alignY : 0

		states: State {
			name: "visible"
			when: root.current === img

			PropertyChanges {
				img.opacity: 1
				img.scale: 1
			}
		}
		transitions: Transition {
			Anim {
				duration: Config.background.wallFadeDuration
				properties: "opacity,scale"
				target: img
			}
		}

		onStatusChanged: {
			if (status === Image.Ready) {
				root.current = this;
			}
		}
	}
}
