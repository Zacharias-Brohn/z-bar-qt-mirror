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

	// states: State {
	// 	name: "visible"
	// 	when: root.visibilities.settings
	//
	// 	PropertyChanges {
	// 		root.implicitHeight: content.implicitHeight
	// 	}
	// }
	// transitions: [
	// 	Transition {
	// 		from: ""
	// 		to: "visible"
	//
	// 		Anim {
	// 			duration: MaterialEasing.expressiveEffectsTime
	// 			easing.bezierCurve: MaterialEasing.expressiveEffects
	// 			property: "implicitHeight"
	// 			target: root
	// 		}
	// 	},
	// 	Transition {
	// 		from: "visible"
	// 		to: ""
	//
	// 		Anim {
	// 			easing.bezierCurve: MaterialEasing.expressiveEffects
	// 			property: "implicitHeight"
	// 			target: root
	// 		}
	// 	}
	// ]

	CustomClippingRect {
		anchors.fill: parent

		Loader {
			id: content

			active: true
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			visible: true

			sourceComponent: Content {
				screen: root.screen
				visibilities: root.visibilities
			}
		}
	}
}
