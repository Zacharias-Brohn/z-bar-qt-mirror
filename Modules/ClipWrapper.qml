pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Config

Item {
	id: root

	readonly property alias content: content
	property real offsetScale: y > 0 || content.hasCurrent ? 0 : 1
	required property ShellScreen screen

	clip: true
	implicitHeight: content.implicitHeight * (1 - offsetScale)
	implicitWidth: content.implicitWidth
	visible: width > 0 && height > 0
	x: {
		if (content.isDetached)
			return (parent.width - content.nonAnimWidth) / 2;

		const off = content.currentCenter - Config.barConfig.border - content.nonAnimWidth / 2;
		const diff = parent.width - Math.floor(off + content.nonAnimWidth);
		if (diff < 0)
			return off + diff;
		return Math.max(off, 0);
	}
	y: content.isDetached ? (parent.height - content.nonAnimHeight) / 2 : 0

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}
	Behavior on x {
		enabled: root.offsetScale < 1

		Anim {
			duration: content.animLength
			easing.bezierCurve: content.animCurve
		}
	}
	Behavior on y {
		Anim {
			duration: content.animLength
			easing.bezierCurve: content.animCurve
		}
	}

	Wrapper {
		id: content

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: (-implicitHeight - 5) * root.offsetScale
		offsetScale: root.offsetScale
		screen: root.screen
	}
}
