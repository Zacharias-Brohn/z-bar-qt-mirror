pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	readonly property PersistentProperties dashState: PersistentProperties {
		property date currentDate: new Date()
		property int currentTab

		reloadableId: "dashboardState"
	}
	readonly property real nonAnimHeight: state === "visible" ? (content.item?.nonAnimHeight ?? 0) : 0
	required property PersistentProperties visibilities

	readonly property bool shouldBeActive: root.visibilities.dashboard && Config.dashboard.enabled
	property real offsetScale: shouldBeActive ? 0 : 1

	visible: offsetScale < 1
	anchors.topMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 854 // Hard coded fallback for first open
	opacity: 1 - offsetScale

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	Loader {
		id: content

		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter

		active: root.shouldBeActive || root.visible

		sourceComponent: Content {
			state: root.dashState
			visibilities: root.visibilities
		}
	}
}
