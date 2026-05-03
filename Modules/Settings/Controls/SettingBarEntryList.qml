pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQml.Models
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	property var boxEntries: [[], [], []]
	property bool dragActive: false
	property real dragHeight: 0
	property real dragPointerStartX: 0
	property real dragPointerStartY: 0
	property real dragStartX: 0
	property real dragStartY: 0
	property real dragX: 0
	property real dragY: 0
	property int draggedBox: -1
	property int draggedIndex: -1
	property var draggedItemData: null
	property bool dropAnimating: false
	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	property var pendingCommitBoxes: []
	required property string setting
	property var spacerEntries: []

	function beginVisualDrag(wrapper, item, pointerX, pointerY) {
		const pos = item.mapToItem(root, 0, 0);
		const loc = root.locateEntry(wrapper.entry);

		root.draggedItemData = wrapper;

		if (loc) {
			root.draggedBox = loc.box;
			root.draggedIndex = loc.index;
		} else {
			root.draggedBox = -1;
			root.draggedIndex = -1;
		}

		root.dragHeight = item.height;
		root.dragStartX = pos.x;
		root.dragStartY = pos.y;
		root.dragPointerStartX = pointerX;
		root.dragPointerStartY = pointerY;
		root.dragX = pos.x;
		root.dragY = pos.y;
		root.dragActive = true;
		root.dropAnimating = false;
		root.pendingCommitBoxes = [];
	}

	function cloneAndUpdateEnabled(entry, value) {
		const list = root.object[root.setting].slice();

		for (let i = 0; i < list.length; i++) {
			if (list[i] === entry) {
				list[i] = {
					id: list[i].id,
					enabled: value
				};
				break;
			}
		}

		root.object[root.setting] = list;
		Config.save();
		root.rebuildBoxEntries();
	}

	function commitBoxEntries(boxes) {
		const spacers = root.spacerEntries.length === 2 ? root.spacerEntries : (root.object[root.setting] ?? []).filter(e => root.isSpacer(e));

		const next = [];
		next.push(...boxes[0].map(w => w.entry));
		next.push(spacers[0]);
		next.push(...boxes[1].map(w => w.entry));
		next.push(spacers[1]);
		next.push(...boxes[2].map(w => w.entry));

		root.object[root.setting] = next;
		Config.save();
		root.rebuildBoxEntries();
	}

	function endVisualDrag() {
		if (!root.draggedItemData)
			return;

		const boxes = root.boxEntries.map(box => box.slice());
		const loc = root.locateEntry(root.draggedItemData.entry);

		root.dragActive = false;

		if (!loc) {
			root.pendingCommitBoxes = boxes;
			root.finishVisualDrag();
			return;
		}

		const view = [boxView0, boxView1, boxView2][loc.box];
		const item = view ? view.itemAtIndex(loc.index) : null;

		root.pendingCommitBoxes = boxes;

		if (!item) {
			root.finishVisualDrag();
			return;
		}

		const pos = item.mapToItem(root, 0, 0);
		root.dropAnimating = true;
		settleX.to = pos.x;
		settleY.to = pos.y;
		settleAnim.start();
	}

	function finishVisualDrag() {
		const boxes = root.pendingCommitBoxes.slice();

		root.dragActive = false;
		root.dropAnimating = false;
		root.draggedItemData = null;
		root.draggedBox = -1;
		root.draggedIndex = -1;
		root.pendingCommitBoxes = [];
		root.dragHeight = 0;

		root.commitBoxEntries(boxes);
	}

	function iconForId(id) {
		switch (id) {
		case "workspaces":
			return "dashboard";
		case "audio":
			return "volume_up";
		case "media":
			return "play_arrow";
		case "resources":
			return "monitoring";
		case "updates":
			return "system_update";
		case "dash":
			return "space_dashboard";
		case "spacer":
			return "horizontal_rule";
		case "activeWindow":
			return "web_asset";
		case "tray":
			return "widgets";
		case "upower":
			return "battery_full";
		case "network":
			return "wifi";
		case "clock":
			return "schedule";
		case "notifBell":
			return "notifications";
		case "hyprsunset":
			return "wb_twilight";
		default:
			return "drag_indicator";
		}
	}

	function isSpacer(entry) {
		return entry && entry.id === "spacer";
	}

	function labelForId(id) {
		switch (id) {
		case "workspaces":
			return qsTr("Workspaces");
		case "audio":
			return qsTr("Audio");
		case "media":
			return qsTr("Media");
		case "resources":
			return qsTr("Resources");
		case "updates":
			return qsTr("Updates");
		case "dash":
			return qsTr("Dash");
		case "spacer":
			return qsTr("Spacer");
		case "activeWindow":
			return qsTr("Active window");
		case "tray":
			return qsTr("Tray");
		case "upower":
			return qsTr("Power");
		case "network":
			return qsTr("Network");
		case "clock":
			return qsTr("Clock");
		case "notifBell":
			return qsTr("Notification bell");
		case "hyprsunset":
			return qsTr("Sunset");
		default:
			return id;
		}
	}

	function locateEntry(entry) {
		for (let b = 0; b < root.boxEntries.length; b++) {
			for (let i = 0; i < root.boxEntries[b].length; i++) {
				if (root.boxEntries[b][i].entry === entry) {
					return {
						box: b,
						index: i
					};
				}
			}
		}

		return null;
	}

	function moveArrayItem(list, from, to) {
		const next = list.slice();
		const item = next.splice(from, 1)[0];
		next.splice(to, 0, item);
		return next;
	}

	function previewMoveToBox(sourceEntry, targetBox, targetIndex, before) {
		const current = root.boxEntries.map(box => box.slice());
		const loc = root.locateEntry(sourceEntry);

		if (!loc)
			return;

		const moved = current[loc.box].splice(loc.index, 1)[0];

		let insertAt = targetIndex + (before ? 0 : 1);

		if (loc.box === targetBox && insertAt > loc.index)
			insertAt -= 1;

		insertAt = Math.max(0, Math.min(current[targetBox].length, insertAt));
		current[targetBox].splice(insertAt, 0, moved);

		root.boxEntries = current;
	}

	function rebuildBoxEntries() {
		const list = root.object[root.setting] ?? [];
		const next = [[], [], []];
		const spacers = [];
		let box = 0;

		for (let i = 0; i < list.length; i++) {
			const entry = list[i];

			if (root.isSpacer(entry)) {
				spacers.push(entry);
				box = Math.min(2, box + 1);
				continue;
			}

			next[box].push({
				entry: entry
			});
		}

		root.spacerEntries = spacers;
		root.boxEntries = next;
	}

	function updateEntry(entry, value) {
		const list = root.object[root.setting].slice();

		for (let i = 0; i < list.length; i++) {
			if (list[i] === entry) {
				list[i] = {
					id: list[i].id,
					enabled: value
				};
				break;
			}
		}

		root.object[root.setting] = list;
		Config.save();
		root.rebuildBoxEntries();
	}

	Layout.fillWidth: true
	implicitHeight: mainLayout.implicitHeight

	Component.onCompleted: root.rebuildBoxEntries()

	Rectangle {
		anchors.fill: parent
		anchors.margins: -Appearance.padding.smaller
		color: DynamicColors.palette.m3primaryContainer
		opacity: root.highlighted ? 0.5 : 0
		radius: Appearance.rounding.small
		z: -1

		Behavior on opacity {
			Anim {
				duration: Appearance.anim.durations.normal
			}
		}
	}

	ParallelAnimation {
		id: settleAnim

		onFinished: root.finishVisualDrag()

		Anim {
			id: settleX

			duration: Appearance.anim.durations.normal
			property: "dragX"
			target: root
		}

		Anim {
			id: settleY

			duration: Appearance.anim.durations.normal
			property: "dragY"
			target: root
		}
	}

	ColumnLayout {
		id: mainLayout

		anchors.fill: parent
		spacing: Appearance.spacing.smaller

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		RowLayout {
			Layout.fillWidth: true
			spacing: Appearance.spacing.normal

			CustomRect {
				Layout.fillWidth: true
				Layout.preferredHeight: 260
				color: DynamicColors.tPalette.m3surface
				radius: Appearance.rounding.normal

				ListView {
					id: boxView0

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					clip: false
					delegate: entryDelegate
					interactive: false
					model: root.boxEntries[0]
					spacing: Appearance.spacing.small
				}
			}

			CustomRect {
				Layout.fillWidth: true
				Layout.preferredHeight: 260
				color: DynamicColors.tPalette.m3surface
				radius: Appearance.rounding.normal

				ListView {
					id: boxView1

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					clip: false
					delegate: entryDelegate
					interactive: false
					model: root.boxEntries[1]
					spacing: Appearance.spacing.small
				}
			}

			CustomRect {
				Layout.fillWidth: true
				Layout.preferredHeight: 260
				color: DynamicColors.tPalette.m3surface
				radius: Appearance.rounding.normal

				ListView {
					id: boxView2

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					clip: false
					delegate: entryDelegate
					interactive: false
					model: root.boxEntries[2]
					spacing: Appearance.spacing.small
				}
			}
		}
	}

	Loader {
		active: root.dragActive || root.dropAnimating
		asynchronous: false

		sourceComponent: Item {
			property real listWidth: boxView0.width

			Drag.active: root.dragActive
			Drag.hotSpot.x: width / 2
			Drag.hotSpot.y: height / 2
			height: proxyRect.implicitHeight
			width: listWidth
			x: root.dragX
			y: root.dragY
			z: 100

			Drag.source: QtObject {
				property var entry: root.draggedItemData ? root.draggedItemData.entry : null
			}

			CustomRect {
				id: proxyRect

				color: DynamicColors.tPalette.m3surface
				implicitHeight: proxyRow.implicitHeight + Appearance.padding.small * 2
				implicitWidth: parent.width
				opacity: 0.95
				radius: Appearance.rounding.normal
				width: parent.width

				RowLayout {
					id: proxyRow

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					spacing: Appearance.spacing.normal

					CustomRect {
						color: Qt.alpha(DynamicColors.palette.m3onSurface, 0.12)
						implicitHeight: 32
						implicitWidth: implicitHeight
						radius: Appearance.rounding.small

						MaterialIcon {
							anchors.centerIn: parent
							color: DynamicColors.palette.m3onSurfaceVariant
							text: "drag_indicator"
						}
					}

					MaterialIcon {
						color: DynamicColors.palette.m3onSurfaceVariant
						text: root.iconForId(root.draggedItemData?.entry?.id ?? "")
					}

					CustomText {
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: root.labelForId(root.draggedItemData?.entry?.id ?? "")
					}

					CustomSwitch {
						checked: root.draggedItemData?.entry?.enabled ?? true
						enabled: false
					}
				}
			}
		}
	}

	Component {
		id: entryDelegate

		DropArea {
			id: slot

			readonly property int boxIndex: ListView.view === boxView0 ? 0 : ListView.view === boxView1 ? 1 : 2
			readonly property var entryData: modelData.entry
			required property int index
			required property var modelData

			function previewReorder(drag) {
				const source = drag.source;
				if (!source || !source.entry || source.entry === slot.entryData)
					return;

				root.previewMoveToBox(source.entry, slot.boxIndex, slot.index, drag.y < height / 2);
			}

			height: entryRow.implicitHeight
			implicitHeight: entryRow.implicitHeight
			implicitWidth: ListView.view ? ListView.view.width : 0
			width: ListView.view ? ListView.view.width : 0

			onEntered: drag => previewReorder(drag)
			onPositionChanged: drag => previewReorder(drag)

			CustomRect {
				id: entryRow

				anchors.fill: parent
				color: DynamicColors.tPalette.m3surface
				implicitHeight: entryLayout.implicitHeight + Appearance.padding.small * 2
				opacity: root.draggedItemData?.entry === slot.entryData ? 0 : 1
				radius: Appearance.rounding.full

				Behavior on opacity {
					Anim {
					}
				}

				RowLayout {
					id: entryLayout

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					spacing: Appearance.spacing.normal

					CustomRect {
						id: handle

						color: Qt.alpha(DynamicColors.palette.m3onSurface, handleMouse.pressed ? 0.12 : handleMouse.containsMouse ? 0.09 : 0.06)
						implicitHeight: 32
						implicitWidth: implicitHeight
						radius: Appearance.rounding.full

						Behavior on color {
							CAnim {
							}
						}

						MaterialIcon {
							anchors.centerIn: parent
							color: DynamicColors.palette.m3onSurfaceVariant
							text: "drag_indicator"
						}

						MouseArea {
							id: handleMouse

							acceptedButtons: Qt.LeftButton
							anchors.fill: parent
							cursorShape: pressed ? Qt.ClosedHandCursor : containsMouse ? Qt.OpenHandCursor : Qt.ArrowCursor
							hoverEnabled: true
							preventStealing: true

							onCanceled: {
								if (root.draggedItemData && root.draggedItemData.entry === slot.entryData)
									root.endVisualDrag();
							}
							onPositionChanged: mouse => {
								if (!pressed || !root.dragActive || !root.draggedItemData || root.draggedItemData.entry !== slot.entryData)
									return;

								const pointer = handle.mapToItem(root, mouse.x, mouse.y);
								const offsetX = root.dragPointerStartX - root.dragStartX;
								const offsetY = root.dragPointerStartY - root.dragStartY;

								root.dragX = pointer.x - offsetX;
								root.dragY = pointer.y - offsetY;
							}
							onPressed: mouse => {
								const pointer = handle.mapToItem(root, mouse.x, mouse.y);
								root.beginVisualDrag(slot.modelData, entryRow, pointer.x, pointer.y);
							}
							onReleased: {
								if (root.draggedItemData && root.draggedItemData.entry === slot.entryData)
									root.endVisualDrag();
							}
						}
					}

					MaterialIcon {
						color: DynamicColors.palette.m3onSurfaceVariant
						text: root.iconForId(slot.entryData.id)
					}

					CustomText {
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: root.labelForId(slot.entryData.id)
					}

					CustomSwitch {
						Layout.rightMargin: Appearance.padding.small
						checked: slot.entryData.enabled ?? true

						onToggled: root.cloneAndUpdateEnabled(slot.entryData, checked)
					}
				}
			}
		}
	}
}
