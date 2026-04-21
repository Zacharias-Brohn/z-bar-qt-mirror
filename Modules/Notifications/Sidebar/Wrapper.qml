pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import QtQuick

Item {
	id: root

	required property var panels
	readonly property Props props: Props {
	}
	required property var visibilities

	readonly property bool shouldBeActive: root.visibilities.sidebar && Config.sidebar.enabled
	property real offsetScale: shouldBeActive ? 0 : 1

	visible: offsetScale < 1
	anchors.rightMargin: (-implicitWidth - 5) * offsetScale
	implicitWidth: Config.sidebar.sizes.width
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
		anchors.bottomMargin: 0
		anchors.left: parent.left
		anchors.margins: 8
		anchors.top: parent.top

		active: root.shouldBeActive || root.visible

		sourceComponent: Content {
			implicitWidth: Config.sidebar.sizes.width - 8 * 2
			props: root.props
			visibilities: root.visibilities
		}
	}
}
