pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import ZShell.Components
import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons

LazyListView {
	id: root

	required property Flickable container
	required property Props props
	required property DrawerVisibilities visibilities

	anchors.left: parent?.left
	anchors.right: parent?.right
	asynchronous: true
	cacheBuffer: 400
	implicitHeight: contentHeight
	readyDelay: 1
	removeDuration: Appearance.anim.durations.normal
	spacing: Appearance.spacing.small
	useCustomViewport: true
	viewport: Qt.rect(0, container.contentY, width, container.height)

	delegate: Component {
		MouseArea {
			id: notif

			readonly property bool closed: notifInner.notifCount === 0
			required property int index
			required property string modelData
			property int startY

			function closeAll(): void {
				clearTimer.start();
			}

			LazyListView.preferredHeight: closed ? 0 : notifInner.nonAnimHeight
			LazyListView.trackViewport: !notifInner.expanded && notifInner.nonAnimHeight < notifInner.implicitHeight
			LazyListView.visibleHeight: notifInner.implicitHeight
			acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
			cursorShape: pressed ? Qt.ClosedHandCursor : undefined
			drag.axis: Drag.XAxis
			drag.target: this
			enabled: !closed
			hoverEnabled: true
			implicitHeight: notifInner.implicitHeight
			opacity: LazyListView.removing || closed || LazyListView.adding ? 0 : 1
			preventStealing: true
			scale: LazyListView.removing || closed ? 0.6 : LazyListView.adding ? 0 : 1

			Behavior on opacity {
				Anim {
				}
			}
			Behavior on scale {
				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
				}
			}
			Behavior on x {
				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
				}
			}
			Behavior on y {
				enabled: notif.LazyListView.ready

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
				}
			}

			onPositionChanged: event => {
				if (pressed) {
					const diffY = event.y - startY;
					if (Math.abs(diffY) > Config.notifs.expandThreshold)
						notifInner.toggleExpand(diffY > 0);
				}
			}
			onPressed: event => {
				startY = event.y;
				if (event.button === Qt.RightButton)
					notifInner.toggleExpand(!notifInner.expanded);
				else if (event.button === Qt.MiddleButton)
					closeAll();
			}
			onReleased: event => {
				if (Math.abs(x) < width * Config.notifs.clearThreshold)
					x = 0;
				else
					closeAll();
			}

			Timer {
				id: clearTimer

				interval: 15
				repeat: true
				triggeredOnStart: true

				onTriggered: {
					const notifs = Notifs.notClosed.filter(n => n.appName === notif.modelData);
					if (notifs.length === 0) {
						stop();
						return;
					}

					for (const n of notifs.slice(0, 30))
						n.close();
				}
			}

			NotifGroup {
				id: notifInner

				container: root.container
				modelData: notif.modelData
				props: root.props
				visibilities: root.visibilities
			}
		}
	}
	model: ScriptModel {
		values: {
			const map = new Map();
			for (const n of Notifs.notClosed)
				map.set(n.appName, null);
			for (const n of Notifs.list)
				map.set(n.appName, null);
			return [...map.keys()];
		}
	}

	onViewportAdjustNeeded: d => {
		if (contentYAnim.running)
			contentYAnim.complete();
		contentYAnim.to = Math.max(0, container.contentY + d);
		contentYAnim.start();
	}

	Anim {
		id: contentYAnim

		duration: Appearance.anim.durations.expressiveDefaultSpatial
		easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		property: "contentY"
		target: root.container
	}
}
