pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules.Settings.Controls

ColumnLayout {
	id: root

	property bool shouldBeActive: true

	function addTimeoutEntry() {
		let list = [...Config.general.idle.timeouts];

		list.push({
			name: "New Entry",
			timeout: 600,
			idleAction: "lock"
		});

		Config.general.idle.timeouts = list;
		Config.save();
	}

	function deleteTimeoutEntry(index) {
		let list = [...Config.general.idle.timeouts];
		list.splice(index, 1);
		Config.general.idle.timeouts = list;
		Config.save();
	}

	function updateTimeoutEntry(i, key, value) {
		const list = [...Config.general.idle.timeouts];
		let entry = list[i];

		entry[key] = value;
		list[i] = entry;

		Config.general.idle.timeouts = list;
		Config.save();
	}

	anchors.left: parent.left
	anchors.right: parent.right
	height: shouldBeActive ? implicitHeight : 0
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	spacing: Appearance.spacing.smaller
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

	Settings {
		name: "Idle Monitors"
	}

	Repeater {
		model: [...Config.general.idle.timeouts]

		SettingList {
			Layout.fillWidth: true
			anchors.left: undefined
			anchors.right: undefined

			onAddActiveActionRequested: {
				root.updateTimeoutEntry(index, "activeAction", "");
			}
			onDeleteRequested: function (index) {
				root.deleteTimeoutEntry(index);
			}
			onFieldEdited: function (key, value) {
				root.updateTimeoutEntry(index, key, value);
			}
		}
	}

	IconButton {
		font.pointSize: Appearance.font.size.large
		icon: "add"

		onClicked: root.addTimeoutEntry()
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		Layout.preferredHeight: 60
		Layout.preferredWidth: 200

		CustomText {
			id: text

			anchors.fill: parent
			font.bold: true
			font.pointSize: Appearance.font.size.large * 2
			text: settingsItem.name
			verticalAlignment: Text.AlignVCenter
		}
	}
}
