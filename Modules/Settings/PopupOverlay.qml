import QtQuick
import qs.Config
import qs.Components

CustomRect {
	id: root

	readonly property bool closing: PopupManager.closed
	readonly property var currentPopup: PopupManager.currentPopup
	property bool shouldBeVisible: loader.status === Loader.Ready

	color: Qt.alpha(DynamicColors.palette.m3shadow, 0.3)
	opacity: shouldBeVisible && !closing ? 1 : 0
	visible: opacity > 0

	Behavior on opacity {
		Anim {
		}
	}

	onVisibleChanged: if (!visible)
		PopupManager.currentPopup = null

	CustomMouseArea {
		anchors.fill: parent
		hoverEnabled: true
		preventStealing: true
		propagateComposedEvents: false

		onClicked: {
			const insideItemWidth = mouseX < loader.x + loader.item.width && mouseX > loader.x;
			const insideItemHeight = mouseY < loader.y + loader.item.height && mouseY > loader.y;
			if (insideItemHeight && insideItemWidth)
				return;

			PopupManager.requestClose();
		}
	}

	Loader {
		id: loader

		anchors.centerIn: parent
		sourceComponent: root.currentPopup
	}
}
