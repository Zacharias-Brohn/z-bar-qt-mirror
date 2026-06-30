pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Modules.Launcher.Services
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property real maxHeight
	readonly property int padding: Appearance.padding.small
	required property var panels
	readonly property int rounding: Appearance.rounding.large
	required property PersistentProperties visibilities

	implicitHeight: search.height + listWrapper.height + padding * 2
	implicitWidth: listWrapper.width + padding * 2

	Item {
		id: listWrapper

		anchors.bottom: search.top
		anchors.bottomMargin: root.padding
		anchors.horizontalCenter: parent.horizontalCenter
		implicitHeight: list.height + root.padding
		implicitWidth: list.width

		ContentList {
			id: list

			content: root
			maxHeight: root.maxHeight - search.implicitHeight - root.padding * 3
			padding: root.padding
			panels: root.panels
			rounding: root.rounding
			search: search
			visibilities: root.visibilities
		}
	}

	SearchBar {
		id: search

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: root.padding
		anchors.right: parent.right
		bottomPadding: Appearance.padding.larger
		placeholderText: qsTr("Type \"%1\" for commands").arg(Config.launcher.actionPrefix)
		topPadding: Appearance.padding.larger

		Component.onCompleted: {
			console.log(search.color);
			console.log(search.placeholderTextColor);
			forceActiveFocus();
		}
		Keys.onDownPressed: list.currentList?.decrementCurrentIndex()
		Keys.onEscapePressed: root.visibilities.launcher = false
		Keys.onPressed: event => {
			if (event.modifiers & Qt.ControlModifier) {
				if (event.key === Qt.Key_J) {
					list.currentList?.incrementCurrentIndex();
					event.accepted = true;
				} else if (event.key === Qt.Key_K) {
					list.currentList?.decrementCurrentIndex();
					event.accepted = true;
				}
			} else if (event.key === Qt.Key_Tab) {
				list.currentList?.incrementCurrentIndex();
				event.accepted = true;
			} else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
				list.currentList?.decrementCurrentIndex();
				event.accepted = true;
			}
		}
		Keys.onUpPressed: list.currentList?.incrementCurrentIndex()
		onAccepted: {
			const currentItem = list.currentList?.currentItem;
			if (currentItem) {
				if (list.showWallpapers) {
					if (DynamicColors.scheme === "dynamic" && currentItem.modelData.path !== Wallpapers.actualCurrent)
						Wallpapers.previewColourLock = true;
					Wallpapers.setWallpaper(currentItem.modelData.path);
					root.visibilities.launcher = false;
				} else if (text.startsWith(Config.launcher.actionPrefix)) {
					if (text.startsWith(`${Config.launcher.actionPrefix}calc `))
						currentItem.onClicked();
					else
						currentItem.modelData.onClicked(list.currentList);
				} else {
					Apps.launch(currentItem.modelData);
					root.visibilities.launcher = false;
				}
			}
		}

		Connections {
			function onLauncherChanged(): void {
				if (!root.visibilities.launcher)
					search.text = "";
			}

			target: root.visibilities
		}
	}
}
