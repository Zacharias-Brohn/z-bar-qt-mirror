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
				sState.animatingContainer: content.opacity < 1
				sState.currentPageIdx: ["wallpaper"][0]
				sState.screen: root.screen

				onClose: console.log("shouldclose")
			}
		}
	}
}
