import QtQuick

ListView {
	id: root

	property bool doneFakeFlick

	maximumFlickVelocity: 3000

	rebound: Transition {
		onRunningChanged: {
			if (!running && !root.doneFakeFlick) {
				root.doneFakeFlick = true;
				root.flick(1, 1);
				root.flick(-1, -1);
				Qt.callLater(() => root.cancelFlick());
			}
		}

		Anim {
			properties: "x,y"
		}
	}

	Timer {
		interval: 10
		running: root.doneFakeFlick

		onTriggered: root.doneFakeFlick = false
	}
}
