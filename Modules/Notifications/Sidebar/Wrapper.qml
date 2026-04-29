pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import QtQuick

Item {
	id: root

	property real offsetScale: shouldBeActive ? 0 : 1
	required property var panels
	readonly property Props props: Props {
	}
	readonly property bool shouldBeActive: root.visibilities.sidebar && Config.sidebar.enabled
	required property var visibilities

	anchors.rightMargin: (-implicitWidth - 5) * offsetScale
	implicitWidth: Config.sidebar.sizes.width
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
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 0
		anchors.left: parent.left
		anchors.margins: 8
		anchors.top: parent.top

		sourceComponent: Content {
			implicitWidth: Config.sidebar.sizes.width - Appearance.padding.smaller * 2
			props: root.props
			visibilities: root.visibilities
		}
	}
}
