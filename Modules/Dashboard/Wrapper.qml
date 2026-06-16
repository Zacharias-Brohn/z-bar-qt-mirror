pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	readonly property PersistentProperties dashState: PersistentProperties {
		property date currentDate: new Date()
		property int currentTab

		reloadableId: "dashboardState"
	}
	readonly property real nonAnimHeight: state === "visible" ? (content.item?.nonAnimHeight ?? 0) : 0
	required property real offsetScale
	readonly property bool shouldBeActive: root.visibilities.dashboard && Config.dashboard.enabled
	required property PersistentProperties visibilities

	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 854
	opacity: 1 - offsetScale
	visible: offsetScale < 1

	Loader {
		id: content

		active: root.shouldBeActive || root.visible
		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter

		sourceComponent: Content {
			dashState: root.dashState
			visibilities: root.visibilities
		}
	}
}
