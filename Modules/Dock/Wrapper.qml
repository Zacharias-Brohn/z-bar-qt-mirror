pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property int contentHeight
	property real offsetScale: shouldBeActive ? 0 : 1
	required property var panels
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.dock && Config.dock.enable
	required property PersistentProperties visibilities

	anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 400
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
		anchors.left: parent.left
		anchors.top: parent.top
		asynchronous: true

		sourceComponent: Content {
			panels: root.panels
			screen: root.screen
			visibilities: root.visibilities
		}
	}
}
