pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property int contentHeight
	property real offsetScale: shouldBeActive ? 0 : 1
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.clipboard && Config.clipboard.enabled
	required property PersistentProperties visibilities

	anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight + Appearance.padding.normal * 2
	implicitWidth: content.implicitWidth + Appearance.padding.normal * 2 || 400
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
			screen: root.screen
			visibilities: root.visibilities
		}
	}
}
