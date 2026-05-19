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

	component Img: Image {
		id: img

		function update(): void {
			if (source === root.source) {
				root.current = this;
			} else {
				source = root.source;
			}
		}

		anchors.fill: parent
		asynchronous: true
		fillMode: Image.PreserveAspectCrop
		opacity: 0
		retainWhileLoading: true
		scale: Wallpapers.showPreview ? 1 : 0.8
		sourceClipRect: Qt.rect(Config.background.sourceClipX, Config.background.sourceClipY, Config.background.sourceClipW, Config.background.sourceClipH)

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
