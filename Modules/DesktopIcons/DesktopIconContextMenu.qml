import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Config

Item {
	id: contextMenu

	property real menuX: 0
	property real menuY: 0
	property var targetAppEntry: null
	property string targetFilePath: ""
	property bool targetIsDir: false
	property var targetPaths: []

	signal openFileRequested(string path, bool isDir)
	signal renameRequested(string path)

	function close() {
		visible = false;
	}

	function openAt(mouseX, mouseY, path, isDir, appEnt, parentW, parentH, selectionArray) {
		targetFilePath = path;
		targetIsDir = isDir;
		targetAppEntry = appEnt;

		targetPaths = (selectionArray && selectionArray.length > 0) ? selectionArray : [path];

		menuX = Math.floor(Math.min(mouseX, parentW - popupBackground.implicitWidth));
		menuY = Math.floor(Math.min(mouseY, parentH - popupBackground.implicitHeight));

		visible = true;
	}

	anchors.fill: parent
	visible: false
	z: 999

	CustomClippingRect {
		id: popupBackground

		readonly property real padding: Appearance.padding.small

		color: DynamicColors.tPalette.m3surface
		implicitHeight: menuLayout.implicitHeight + padding * 2
		implicitWidth: menuLayout.implicitWidth + padding * 2
		opacity: contextMenu.visible ? 1 : 0
		radius: Appearance.rounding.normal
		x: contextMenu.menuX
		y: contextMenu.menuY

		Behavior on opacity {
			Anim {
			}
		}

		ColumnLayout {
			id: menuLayout

			anchors.centerIn: parent
			spacing: 0

			CustomRect {
				Layout.preferredWidth: 160
				implicitHeight: openRow.implicitHeight + Appearance.padding.small * 2
				radius: popupBackground.radius - popupBackground.padding

				RowLayout {
					id: openRow

					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.smaller
					spacing: 8

					MaterialIcon {
						font.pointSize: 20
						text: "open_in_new"
					}

					CustomText {
						Layout.fillWidth: true
						text: "Open"
					}
				}

				StateLayer {
					anchors.fill: parent

					onClicked: {
						for (let i = 0; i < contextMenu.targetPaths.length; i++) {
							let p = contextMenu.targetPaths[i];
							if (p === contextMenu.targetFilePath) {
								if (p.endsWith(".desktop") && contextMenu.targetAppEntry)
									contextMenu.targetAppEntry.execute();
								else
									contextMenu.openFileRequested(p, contextMenu.targetIsDir);
							} else {
								Quickshell.execDetached(["xdg-open", p]);
							}
						}
						contextMenu.close();
					}
				}
			}

			CustomRect {
				Layout.fillWidth: true
				implicitHeight: openWithRow.implicitHeight + Appearance.padding.small * 2
				radius: popupBackground.radius - popupBackground.padding

				RowLayout {
					id: openWithRow

					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.smaller
					spacing: 8

					MaterialIcon {
						font.pointSize: 20
						text: contextMenu.targetIsDir ? "terminal" : "apps"
					}

					CustomText {
						Layout.fillWidth: true
						text: contextMenu.targetIsDir ? "Open in terminal" : "Open with..."
					}
				}

				StateLayer {
					anchors.fill: parent

					onClicked: {
						if (contextMenu.targetIsDir) {
							Quickshell.execDetached([Config.general.apps.terminal, "--working-directory", contextMenu.targetFilePath]);
						} else {
							Quickshell.execDetached(["xdg-open", contextMenu.targetFilePath]);
						}
						contextMenu.close();
					}
				}
			}

			CustomRect {
				Layout.bottomMargin: 4
				Layout.fillWidth: true
				Layout.topMargin: 4
				color: DynamicColors.palette.m3outlineVariant
				implicitHeight: 1
			}

			CustomRect {
				Layout.fillWidth: true
				implicitHeight: copyPathRow.implicitHeight + Appearance.padding.small * 2
				radius: popupBackground.radius - popupBackground.padding

				RowLayout {
					id: copyPathRow

					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.smaller
					spacing: 8

					MaterialIcon {
						font.pointSize: 20
						text: "content_copy"
					}

					CustomText {
						Layout.fillWidth: true
						text: "Copy path"
					}
				}

				StateLayer {
					anchors.fill: parent

					onClicked: {
						Quickshell.execDetached(["wl-copy", contextMenu.targetPaths.join("\n")]);
						contextMenu.close();
					}
				}
			}

			CustomRect {
				Layout.fillWidth: true
				implicitHeight: renameRow.implicitHeight + Appearance.padding.small * 2
				radius: popupBackground.radius - popupBackground.padding
				visible: contextMenu.targetPaths.length === 1

				RowLayout {
					id: renameRow

					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.smaller
					spacing: 8

					MaterialIcon {
						font.pointSize: 20
						text: "edit"
					}

					CustomText {
						Layout.fillWidth: true
						text: "Rename"
					}
				}

				StateLayer {
					anchors.fill: parent

					onClicked: {
						contextMenu.renameRequested(contextMenu.targetFilePath);
						contextMenu.close();
					}
				}
			}

			Rectangle {
				Layout.bottomMargin: 4
				Layout.fillWidth: true
				Layout.topMargin: 4
				color: DynamicColors.palette.m3outlineVariant
				implicitHeight: 1
			}

			CustomRect {
				Layout.fillWidth: true
				implicitHeight: deleteRow.implicitHeight + Appearance.padding.small * 2
				radius: popupBackground.radius - popupBackground.padding

				RowLayout {
					id: deleteRow

					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.smaller
					spacing: 8

					MaterialIcon {
						color: deleteButton.hovered ? DynamicColors.palette.m3onError : DynamicColors.palette.m3error
						font.pointSize: 20
						text: "delete"
					}

					CustomText {
						Layout.fillWidth: true
						color: deleteButton.hovered ? DynamicColors.palette.m3onError : DynamicColors.palette.m3error
						text: "Move to trash"
					}
				}

				StateLayer {
					id: deleteButton

					anchors.fill: parent
					color: DynamicColors.tPalette.m3error

					onClicked: {
						let cmd = ["gio", "trash"].concat(contextMenu.targetPaths);
						Quickshell.execDetached(cmd);
						contextMenu.close();
					}
				}
			}
		}
	}
}
