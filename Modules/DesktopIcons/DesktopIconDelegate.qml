import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Config
import qs.Components
import qs.Helpers

Item {
	id: root

	property var appEntry: fileName.endsWith(".desktop") ? DesktopEntries.byId(DesktopUtils.getAppId(fileName)) : null
	required property var contextMenu
	property bool fileIsDir: modelData.isDir
	property string fileName: modelData.fileName
	property string filePath: modelData.filePath
	property int gridX: modelData.gridX
	property int gridY: modelData.gridY
	required property Item iconsRoot
	property bool isSnapping: snapAnimX.running || snapAnimY.running
	property bool lassoActive
	required property var modelData
	property string resolvedIcon: {
		if (fileName.endsWith(".desktop")) {
			if (appEntry && appEntry.icon && appEntry.icon !== "")
				return appEntry.icon;
			return AppSearch.guessIcon(DesktopUtils.getAppId(fileName));
		} else if (DesktopUtils.getFileType(fileName, fileIsDir) === "image") {
			return "file://" + filePath;
		} else {
			return DesktopUtils.getIconName(fileName, fileIsDir);
		}
	}

	function compensateAndSnap(absVisX, absVisY) {
		dragContainer.x = absVisX - root.x;
		dragContainer.y = absVisY - root.y;
		snapAnimX.start();
		snapAnimY.start();
	}

	function getDragX() {
		return dragContainer.x;
	}

	function getDragY() {
		return dragContainer.y;
	}

	height: root.iconsRoot.cellHeight
	width: root.iconsRoot.cellWidth
	x: gridX * root.iconsRoot.cellWidth
	y: gridY * root.iconsRoot.cellHeight

	Behavior on x {
		enabled: !mouseArea.drag.active && !root.isSnapping && !root.iconsRoot.selectedIcons.includes(root.filePath)

		Anim {
		}
	}
	Behavior on y {
		enabled: !mouseArea.drag.active && !root.isSnapping && !root.iconsRoot.selectedIcons.includes(root.filePath)

		Anim {
		}
	}

	Item {
		id: dragContainer

		height: parent.height
		width: parent.width

		states: State {
			when: mouseArea.drag.active

			PropertyChanges {
				opacity: 0.8
				scale: 1.1
				target: dragContainer
				z: 100
			}
		}
		transform: Translate {
			x: (root.iconsRoot.selectedIcons.includes(root.filePath) && root.iconsRoot.dragLeader !== "" && root.iconsRoot.dragLeader !== root.filePath) ? root.iconsRoot.groupDragX : 0
			y: (root.iconsRoot.selectedIcons.includes(root.filePath) && root.iconsRoot.dragLeader !== "" && root.iconsRoot.dragLeader !== root.filePath) ? root.iconsRoot.groupDragY : 0
		}
		transitions: Transition {
			Anim {
			}
		}

		onXChanged: {
			if (mouseArea.drag.active) {
				root.iconsRoot.dragLeader = root.filePath;
				root.iconsRoot.groupDragX = x;
			}
		}
		onYChanged: {
			if (mouseArea.drag.active) {
				root.iconsRoot.dragLeader = root.filePath;
				root.iconsRoot.groupDragY = y;
			}
		}

		PropertyAnimation {
			id: snapAnimX

			duration: 250
			easing.type: Easing.OutCubic
			property: "x"
			target: dragContainer
			to: 0
		}

		PropertyAnimation {
			id: snapAnimY

			duration: 250
			easing.type: Easing.OutCubic
			property: "y"
			target: dragContainer
			to: 0
		}

		Column {
			anchors.centerIn: parent
			spacing: 6

			IconImage {
				anchors.horizontalCenter: parent.horizontalCenter
				implicitSize: 48
				source: {
					if (root.resolvedIcon.startsWith("file://") || root.resolvedIcon.startsWith("/")) {
						return root.resolvedIcon;
					} else {
						return Quickshell.iconPath(root.resolvedIcon, root.fileIsDir ? "folder" : "text-x-generic");
					}
				}
			}

			Item {
				height: 40
				width: 88

				CustomText {
					anchors.fill: parent
					color: "white"
					elide: Text.ElideRight
					horizontalAlignment: Text.AlignHCenter
					maximumLineCount: 2
					style: Text.Outline
					styleColor: "black"
					text: (root.appEntry && root.appEntry.name !== "") ? root.appEntry.name : root.fileName
					visible: !renameLoader.active
					wrapMode: Text.Wrap
				}

				Loader {
					id: renameLoader

					active: root.iconsRoot.editingFilePath === root.filePath
					anchors.centerIn: parent
					height: 24
					width: 110

					sourceComponent: CustomTextInput {
						anchors.fill: parent
						anchors.margins: 2
						color: "white"
						horizontalAlignment: Text.AlignHCenter
						text: root.fileName
						wrapMode: Text.Wrap

						Component.onCompleted: {
							forceActiveFocus();
							selectAll();
						}
						Keys.onPressed: function (event) {
							if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
								if (text.trim() !== "" && text !== root.fileName) {
									let newName = text.trim();
									let newPath = root.filePath.substring(0, root.filePath.lastIndexOf('/') + 1) + newName;

									Quickshell.execDetached(["mv", root.filePath, newPath]);
								}
								root.iconsRoot.editingFilePath = "";
								event.accepted = true;
							} else if (event.key === Qt.Key_Escape) {
								root.iconsRoot.editingFilePath = "";
								event.accepted = true;
							}
						}
						onActiveFocusChanged: {
							if (!activeFocus && root.iconsRoot.editingFilePath === root.filePath) {
								root.iconsRoot.editingFilePath = "";
							}
						}
					}
				}
			}
		}

		CustomRect {
			anchors.fill: parent
			anchors.margins: 4
			color: "white"
			opacity: root.iconsRoot.selectedIcons.includes(root.filePath) ? 0.2 : 0.0
			radius: Appearance.rounding.smallest

			Behavior on opacity {
				Anim {
				}
			}
		}

		MouseArea {
			id: mouseArea

			acceptedButtons: Qt.LeftButton | Qt.RightButton
			anchors.fill: parent
			cursorShape: root.iconsRoot.lassoActive ? undefined : Qt.PointingHandCursor
			drag.target: dragContainer
			hoverEnabled: true

			onClicked: mouse => {
				root.iconsRoot.forceActiveFocus();

				if (mouse.button === Qt.RightButton) {
					if (!root.iconsRoot.selectedIcons.includes(root.filePath)) {
						root.iconsRoot.selectedIcons = [root.filePath];
					}
					let pos = mapToItem(root.iconsRoot, mouse.x, mouse.y);
					root.contextMenu.openAt(pos.x, pos.y, root.filePath, root.fileIsDir, root.appEntry, root.iconsRoot.width, root.iconsRoot.height, root.iconsRoot.selectedIcons);
				} else {
					root.iconsRoot.selectedIcons = [root.filePath];
					root.contextMenu.close();
				}
			}
			onDoubleClicked: mouse => {
				if (mouse.button === Qt.LeftButton) {
					if (root.filePath.endsWith(".desktop") && root.appEntry)
						root.appEntry.execute();
					else
						root.iconsRoot.exec(root.filePath, root.fileIsDir);
				}
			}
			onPressed: mouse => {
				if (mouse.button === Qt.LeftButton && !root.iconsRoot.selectedIcons.includes(root.filePath)) {
					root.iconsRoot.selectedIcons = [root.filePath];
				}
			}
			onReleased: {
				if (drag.active) {
					let absoluteX = root.x + dragContainer.x;
					let absoluteY = root.y + dragContainer.y;
					let snapX = Math.max(0, Math.round(absoluteX / root.iconsRoot.cellWidth));
					let snapY = Math.max(0, Math.round(absoluteY / root.iconsRoot.cellHeight));

					root.iconsRoot.performMassDrop(root.filePath, snapX, snapY);
				}
			}

			CustomRect {
				anchors.fill: parent
				anchors.margins: 4
				color: "white"
				opacity: parent.containsMouse ? 0.1 : 0.0
				radius: Appearance.rounding.smallest

				Behavior on opacity {
					Anim {
					}
				}
			}
		}
	}
}
