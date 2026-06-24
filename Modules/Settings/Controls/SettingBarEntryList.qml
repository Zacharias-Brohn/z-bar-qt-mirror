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

	property bool dragActive: false
	property real dragHeight: 0
	property real dragStartX: 0
	property real dragStartY: 0
	property real dragX: 0
	property real dragY: 0
	property var draggedModelData: null
	property string draggedUid: ""
	property bool dropAnimating: false
	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	property var pendingCommitEntries: []
	required property string setting
	property bool shouldBeActive: true
	property int uidCounter: 0
	property var visualEntries: []

	function ensureVisualEntries() {
		if (!root.dragActive && !root.dropAnimating)
			root.rebuildVisualEntries();
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
		default:
			return "drag_indicator";
		}
	}

	function indexForUid(uid) {
		for (let i = 0; i < root.visualEntries.length; i++) {
			if (root.visualEntries[i].uid === uid)
				return i;
		}

		return -1;
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
			return qsTr("Title");
		case "tray":
			return qsTr("Tray");
		case "upower":
			return qsTr("Power");
		case "network":
			return qsTr("Network");
		case "clock":
			return qsTr("Clock");
		case "notifBell":
			return qsTr("Notifs");
		case "hyprsunset":
			return qsTr("Night light");
		default:
			return id;
		}
	}

	function rebuildVisualEntries() {
		const entries = root.object[root.setting] ?? [];
		const next = [];

		for (let i = 0; i < entries.length; i++) {
			const entry = entries[i];
			let existing = null;

			for (let j = 0; j < root.visualEntries.length; j++) {
				if (root.visualEntries[j].entry === entry) {
					existing = root.visualEntries[j];
					break;
				}
			}

			if (existing)
				next.push(existing);
			else
				next.push({
					uid: `entry-${root.uidCounter++}`,
					entry
				});
		}

		root.visualEntries = next;
	}

	function updateEntry(index, value) {
		const list = [...root.object[root.setting]];
		const entry = list[index];
		entry.enabled = value;
		list[index] = entry;
		root.object[root.setting] = list;
		Config.save();
	}

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? layout.implicitHeight : 0
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}
	Behavior on y {
		Anim {
		}
	}

	Component.onCompleted: root.rebuildVisualEntries()

	CustomRect {
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

	RowLayout {
		id: layout

		anchors.fill: parent

		// spacing: Appearance.spacing.smaller

		DelegateModel {
			id: visualModel

			delegate: entryDelegate

			model: ScriptModel {
				objectProp: "uid"
				values: root.visualEntries
			}
		}

		Repeater {
			delegate: entryDelegate
			model: visualModel
		}
	}

	Component {
		id: entryDelegate

		IconButton {
			required property int index
			required property var modelData

			Layout.fillWidth: true
			Layout.preferredWidth: implicitWidth + (stateLayer.pressed ? 18 : internalChecked ? 7 : 0)
			checked: modelData.entry.enabled ?? true
			font: Appearance.font.family.sans
			// icon: root.iconForId(modelData.entry.id)
			icon: root.labelForId(modelData.entry.id)
			inactiveColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
			isToggle: true
			radius: stateLayer.pressed ? 6 / 2 : internalChecked ? 6 : 8
			radiusAnim.duration: MaterialEasing.expressiveEffectsTime
			radiusAnim.easing.bezierCurve: MaterialEasing.expressiveEffects
			visible: !["spacer", "upower", "dash", "audio"].some(prefix => modelData.entry.id.startsWith(prefix))

			Behavior on Layout.preferredWidth {
				Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
				}
			}

			onClicked: root.updateEntry(index, internalChecked)
		}
	}
}
