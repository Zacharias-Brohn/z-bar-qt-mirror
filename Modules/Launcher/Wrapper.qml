pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Modules.Launcher.Services

Item {
	id: root

	property int contentHeight
	readonly property real maxHeight: {
		let max = screen.height - Appearance.spacing.large * 2;
		if (visibilities.resources && panels.resourcesWrapper.x + panels.resourcesWrapper.width > root.x)
			max -= panels.resources.nonAnimHeight;
		if (panels.popouts.hasCurrent)
			if (panels.popouts.current?.x + panels.popouts.current?.width > root.x && panels.popouts.current?.x < root.x + root.width)
				max -= panels.popouts.nonAnimHeight;
		return max;
	}
	property real offsetScale: shouldBeActive ? 0 : 1
	required property var panels
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.launcher
	required property PersistentProperties visibilities

	anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 400
	opacity: 1 - offsetScale
	visible: offsetScale < 1

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	Component.onCompleted: Qt.callLater(() => Apps)
	onShouldBeActiveChanged: {
		if (shouldBeActive)
			implicitHeight = Qt.binding(() => content.implicitHeight);
		else
			implicitHeight = implicitHeight;
	}

	Loader {
		id: content

		active: root.shouldBeActive || root.visible
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		asynchronous: true

		sourceComponent: Content {
			maxHeight: root.maxHeight
			panels: root.panels
			visibilities: root.visibilities
		}
	}
}
