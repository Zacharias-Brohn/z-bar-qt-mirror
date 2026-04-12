pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import Quickshell
import QtQuick
import QtQuick.Layouts

LazyListView {
	id: root

	required property Flickable container
	required property bool expanded
	required property list<var> notifs
	required property Props props
	required property DrawerVisibilities visibilities

	signal requestToggleExpand(expand: bool)

	Layout.fillWidth: true
	asynchronous: true
	cacheBuffer: 400
	implicitHeight: contentHeight
	readyDelay: 1
	removeDuration: Appearance.anim.durations.normal
	spacing: Math.round(Appearance.spacing.small / 2)
	useCustomViewport: true
	viewport: {
		tWatcher.transform; // mapToItem is not reactive so use this to trigger updates
		return Qt.rect(0, container.contentY - mapToItem(container.contentItem, 0, 0).y, width, container.height);
	}

	delegate: Component {
		MouseArea {
			id: notif

			required property int index
			required property NotifData modelData
			property int startY

			LazyListView.preferredHeight: modelData?.closed || LazyListView.removing ? 0 : notifInner.nonAnimHeight
			LazyListView.visibleHeight: modelData?.closed || LazyListView.removing ? 0 : notifInner.implicitHeight
			acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
			cursorShape: notifInner.body?.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
			drag.axis: Drag.XAxis
			drag.target: this
			enabled: !(modelData?.closed ?? true)
			hoverEnabled: true
			implicitHeight: notifInner.implicitHeight
			opacity: LazyListView.removing || LazyListView.adding ? 0 : 1
			preventStealing: !root.expanded
			scale: LazyListView.removing || LazyListView.adding ? 0.7 : 1

			Behavior on opacity {
				Anim {
				}
			}
			Behavior on scale {
				Anim {
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

			Component.onCompleted: modelData?.lock(this)
			Component.onDestruction: modelData?.unlock(this)
			onPositionChanged: event => {
				if (pressed && !root.expanded) {
					const diffY = event.y - startY;
					if (Math.abs(diffY) > Config.notifs.expandThreshold)
						root.requestToggleExpand(diffY > 0);
				}
			}
			onPressed: event => {
				startY = event.y;
				if (event.button === Qt.RightButton)
					root.requestToggleExpand(!root.expanded);
				else if (event.button === Qt.MiddleButton)
					modelData?.close();
			}
			onReleased: event => {
				if (Math.abs(x) < width * Config.notifs.clearThreshold)
					x = 0;
				else
					modelData?.close();
			}

			ParallelAnimation {
				running: notif.modelData?.closed ?? false

				onFinished: notif.modelData?.unlock(notif)

				Anim {
					property: "opacity"
					target: notif
					to: 0
				}

				Anim {
					property: "x"
					target: notif
					to: notif.x >= 0 ? notif.width : -notif.width
				}
			}

			Notif {
				id: notifInner

				anchors.fill: parent
				expanded: root.expanded
				modelData: notif.modelData
				props: root.props
				visibilities: root.visibilities
			}
		}
	}
	model: ScriptModel {
		values: {
			if (root.expanded)
				return root.notifs;

			let count = 0;
			let i = 0;
			const previewNum = Config.notifs.groupPreviewNum;
			while (i < root.notifs.length && count < previewNum) {
				if (!(root.notifs[i]?.closed ?? true))
					count++;
				i++;
			}

			return root.notifs.slice(0, i);
		}
	}

	TransformWatcher {
		id: tWatcher

		a: root.container.contentItem
		b: root
	}
}
