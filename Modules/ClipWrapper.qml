pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Config

Item {
	id: root

	readonly property alias content: content
	property real offsetScale: x > 0 || content.hasCurrent ? 0 : 1
	required property ShellScreen screen

	clip: true
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth * (1 - offsetScale)
	visible: width > 0 && height > 0

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}
	Behavior on x {
		Anim {
			duration: content.animLength
			easing.bezierCurve: content.animCurve
		}
	}
	Behavior on y {
		enabled: root.offsetScale < 1

		Anim {
			duration: content.animLength
			easing.bezierCurve: content.animCurve
		}
	}

	Wrapper {
		id: content

		anchors.left: parent.left
		anchors.leftMargin: (-implicitWidth - 5) * root.offsetScale
		anchors.verticalCenter: parent.verticalCenter
		offsetScale: root.offsetScale
		screen: root.screen
	}
}
