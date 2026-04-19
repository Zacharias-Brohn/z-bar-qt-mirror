pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property int contentHeight
	required property var panels
	required property ShellScreen screen
	required property PersistentProperties visibilities

	readonly property bool shouldBeActive: visibilities.dock
	property real offsetScale: shouldBeActive ? 0 : 1

	visible: offsetScale < 1
	anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 400
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
		anchors.top: parent.top

		active: root.shouldBeActive || root.visible

		sourceComponent: Content {
			panels: root.panels
			screen: root.screen
			visibilities: root.visibilities
		}
	}
}
