import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	required property Item panels
	required property Item sidebarPanel
	required property var visibilities

	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth
	visible: height > 0

	states: State {
		name: "hidden"
		when: root.visibilities.sidebar || root.visibilities.dashboard || (root.panels.popouts.hasCurrent && root.panels.popouts.currentName.startsWith("traymenu"))

		PropertyChanges {
			root.implicitHeight: 0
		}
	}
	transitions: Transition {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
			property: "implicitHeight"
			target: root
		}
	}

	Content {
		id: content

		panels: root.panels
		visibilities: root.visibilities
	}
}
