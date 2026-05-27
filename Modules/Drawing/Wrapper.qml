pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

Item {
	id: root

	required property Canvas drawing
	property bool expanded: true
	property real offsetScale: shouldBeActive ? 0 : 1
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.isDrawing
	required property var visibilities

	anchors.leftMargin: (-implicitWidth - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: root.expanded ? content.implicitWidth : icon.implicitWidth
	opacity: 1 - offsetScale
	visible: offsetScale < 1

	Behavior on implicitWidth {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}
	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	onVisibleChanged: {
		if (!visible)
			root.expanded = true;
	}

	Loader {
		id: icon

		active: root.shouldBeActive || root.visible
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		asynchronous: true
		height: content.item.height
		opacity: root.expanded ? 0 : 1

		Behavior on opacity {
			Anim {
			}
		}
		sourceComponent: MaterialIcon {
			font.pointSize: Appearance.font.size.larger
			text: "arrow_forward_ios"
		}
	}

	Loader {
		id: content

		active: root.shouldBeActive || root.visible
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		asynchronous: true
		opacity: root.expanded ? 1 : 0

		Behavior on opacity {
			Anim {
			}
		}
		sourceComponent: Content {
			drawing: root.drawing
			visibilities: root.visibilities
		}
	}
}
