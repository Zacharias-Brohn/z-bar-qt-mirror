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
		const off = content.currentCenter - content.nonAnimWidth / 2;
		const diff = parent.width - Math.floor(off + content.nonAnimWidth);
		if (diff < 0)
			return off + diff;
		return Math.floor(Math.max(off, 0));
	}

	Behavior on offsetScale {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
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
