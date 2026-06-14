pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	readonly property real nonAnimHeight: content.item?.nonAnimHeight ?? 0
	property real offsetScale: shouldBeActive ? 0 : 1
	readonly property bool shouldBeActive: root.visibilities.resources
	required property PersistentProperties visibilities

	anchors.topMargin: (-implicitHeight - 5) * offsetScale
	clip: true
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 854 // Hard coded fallback for first open
	opacity: 1 - offsetScale
	visible: offsetScale < 1

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	Loader {
		id: content

		active: root.shouldBeActive || root.visible
		anchors.centerIn: parent

		sourceComponent: Content {
		}
	}
}
