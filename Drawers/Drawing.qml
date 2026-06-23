pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import ZShell.Internal

Item {
	id: root

	readonly property alias content: contentLoader.item
	readonly property PersistentProperties drawingState: PersistentProperties {
		property color penColor: "white"
		property int penWidth: 4

		reloadableId: "drawingState"
	}
	required property PersistentProperties visibilities

	Loader {
		id: contentLoader

		active: root.visibilities.isDrawing
		anchors.fill: parent

		sourceComponent: StrokeCanvas {
			penColor: root.drawingState.penColor
			penWidth: root.drawingState.penWidth
		}
	}
}
