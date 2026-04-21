pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import Quickshell
import QtQuick

Item {
	id: root

	required property Item popouts
	readonly property PersistentProperties props: PersistentProperties {
		property string recordingConfirmDelete
		property bool recordingListExpanded: false
		property string recordingMode

		reloadableId: "utilities"
	}
	readonly property bool shouldBeActive: visibilities.sidebar
	required property Item sidebar
	required property var visibilities

	property real offsetScale: shouldBeActive ? 0 : 1

	visible: offsetScale < 1
	anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight + 8 * 2
	implicitWidth: sidebar.width * (1 - sidebar.offsetScale)
	opacity: 1 - offsetScale

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	Loader {
		id: content

		anchors.left: parent.left
		anchors.margins: 8
		anchors.top: parent.top

		active: root.shouldBeActive || root.visible

		sourceComponent: Content {
			implicitWidth: root.implicitWidth - 8 * 2
			popouts: root.popouts
			props: root.props
			visibilities: root.visibilities
		}
	}
}
