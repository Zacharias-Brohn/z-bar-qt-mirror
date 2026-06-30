pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Config
import qs.Components

Scope {
	id: root

	required property Item bar
	required property ShellScreen screen

	ExclusionZone {
		id: top

		anchors.top: true
		exclusiveZone: root.bar.exclusiveZone
	}

	ExclusionZone {
		id: left

		anchors.left: true
	}

	ExclusionZone {
		id: right

		anchors.right: true
	}

	ExclusionZone {
		id: bottom

		anchors.bottom: true
	}

	Timer {
		interval: 5000
		running: true

		onTriggered: console.log("top height:", top.exclusiveZone, "left width:", left.exclusiveZone, "right width:", right.exclusiveZone, "bottom height:", bottom.exclusiveZone)
	}

	component ExclusionZone: CustomWindow {
		exclusiveZone: Config.bar.border
		implicitHeight: 1
		implicitWidth: 1
		name: "Bar-Exclusion"
		screen: root.screen

		mask: Region {
		}
	}
}
