import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	property real offsetScale: shouldBeActive ? 0 : 1
	required property var panels
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.settings
	required property PersistentProperties visibilities

	anchors.topMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth
	opacity: 1 - offsetScale
	visible: offsetScale < 1

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	CustomClippingRect {
		anchors.fill: parent

		Loader {
			id: content

			active: root.shouldBeActive || root.visible
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter

			sourceComponent: Content {
				screen: root.screen
				visibilities: root.visibilities
			}
		}
	}
}
