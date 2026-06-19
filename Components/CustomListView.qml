import QtQuick
import qs.Helpers

ListView {
	id: root

	property bool doneFakeFlick

	interactive: !Visibilities.getForActive().isDrawing
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
