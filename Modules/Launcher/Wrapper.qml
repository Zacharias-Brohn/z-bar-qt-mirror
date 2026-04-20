pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property int contentHeight
	readonly property real maxHeight: {
		let max = screen.height - Appearance.spacing.large * 2;
		if (visibilities.resources)
			max -= panels.resources.nonAnimHeight;
		if (visibilities.dashboard && panels.dashboard.x < root.x + root.implicitWidth)
			max -= panels.dashboard.nonAnimHeight;
		if (panels.popouts.currentName.startsWith("updates"))
			max -= panels.popouts.nonAnimHeight;
		return max;
	}
	required property var panels
	required property ShellScreen screen
	required property PersistentProperties visibilities
	readonly property bool shouldBeActive: visibilities.launcher
	property real offsetScale: shouldBeActive ? 0 : 1

	onShouldBeActiveChanged: {
		if (shouldBeActive) {
			implicitHeight = Qt.binding(() => content.implicitHeight);
			timer.stop();
		} else {
			implicitHeight = implicitHeight;
		}
	}

	visible: offsetScale < 1
	anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
	implicitHeight: content.implicitHeight
	implicitWidth: content.implicitWidth || 400
	opacity: 1 - offsetScale

	Behavior on offsetScale {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	onMaxHeightChanged: timer.start()

	Connections {
		function onEnabledChanged(): void {
			timer.start();
		}

		function onMaxShownChanged(): void {
			timer.start();
		}

		target: Config.launcher
	}

	Connections {
		function onValuesChanged(): void {
			if (DesktopEntries.applications.values.length < Config.launcher.maxAppsShown)
				timer.start();
		}

		target: DesktopEntries.applications
	}

	Timer {
		id: timer

		interval: Appearance.anim.durations.small

		onRunningChanged: {
			if (running && !root.shouldBeActive) {
				content.visible = false;
				content.active = true;
			} else {
				root.contentHeight = Math.min(root.maxHeight, content.implicitHeight);
				content.active = Qt.binding(() => root.shouldBeActive || root.visible);
				content.visible = true;
			}
		}
	}

	Loader {
		id: content

		active: false
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top

		sourceComponent: Content {
			maxHeight: root.maxHeight
			panels: root.panels
			visibilities: root.visibilities

			Component.onCompleted: root.contentHeight = implicitHeight
		}

		Component.onCompleted: timer.start()
	}
}
