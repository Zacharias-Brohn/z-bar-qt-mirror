import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Variants {
	model: Quickshell.screens

	PanelWindow {
		id: root

		required property var modelData
		readonly property list<ShellScreen> screens: Quickshell.screens

		implicitWidth: 300
		screen: modelData

		anchors {
			bottom: true
			left: false
			right: true
			top: true
		}

		ColumnLayout {
			id: layout

			anchors.fill: parent

			Repeater {
				model: Quickshell.screens

				Item {
					id: delegate

					required property ShellScreen modelData

					Layout.fillHeight: true
					Layout.fillWidth: true

					Image {
						id: scaledImg

						property var displayData
						readonly property real imageRatio: scaledImg.sourceSize.width / scaledImg.sourceSize.height
						property real monitorScale
						readonly property real scaleDownX: scaledImg.paintedWidth / scaledImg.sourceSize.width
						readonly property real scaleDownY: scaledImg.paintedHeight / scaledImg.sourceSize.height
						readonly property real scaleX: (scaledImg.sourceSize.width * monitorScale) / scaledImg.paintedWidth
						readonly property real scaleY: (scaledImg.sourceSize.height * monitorScale) / scaledImg.paintedHeight

						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						fillMode: Image.PreserveAspectFit
						height: width / imageRatio
						source: "/mnt/IronWolf/SDImages/SWWW_Wals/wallhaven-43dyq6.jpg"

						Component.onCompleted: {
							Hyprland.refreshMonitors();
							monitorScale = Hyprland.monitorFor(delegate.modelData).scale;
						}
						onScaleYChanged: console.log(scaleX, scaleY, "scale")
						onStatusChanged: {
							if (scaledImg.status == Image.Ready) {
								console.log(scaledImg.sourceSize.width, scaledImg.sourceSize.height, scaledImg.paintedWidth, scaledImg.paintedHeight, delegate.modelData.width, delegate.modelData.height);
							}
						}

						Connections {
							function onLoaded(): void {
								scaledImg.displayData = Wallpapers.getCrop(delegate.modelData.name);
								cropRect.restoreFromData();
							}

							target: Wallpapers.monitorCrops
						}

						Rectangle {
							id: cropRect

							property real aspectRatio: delegate.modelData.width / delegate.modelData.height
							readonly property real baseHeight: baseWidth / aspectRatio

							// PreserveAspectFit baseline at zoom = 1
							readonly property real baseWidth: {
								let fittedHeight = scaledImg.paintedHeight;
								let fittedWidth = fittedHeight * aspectRatio;

								if (fittedWidth > scaledImg.paintedWidth) {
									fittedWidth = scaledImg.paintedWidth;
									fittedHeight = fittedWidth / aspectRatio;
								}

								return fittedWidth;
							}

							// actual visible image origin inside Image item
							readonly property real imageX: (scaledImg.width - scaledImg.paintedWidth) / 2
							readonly property real imageY: (scaledImg.height - scaledImg.paintedHeight) / 2
							property real zoom: scaledImg.displayData.zoom

							function centerInImage() {
								x = imageX + (scaledImg.paintedWidth - width) / 2;
								y = imageY + (scaledImg.paintedHeight - height) / 2;
							}

							function clampToBounds() {
								x = Math.max(imageX, Math.min(x, imageX + scaledImg.paintedWidth - width));

								y = Math.max(imageY, Math.min(y, imageY + scaledImg.paintedHeight - height));
							}

							function restoreFromData() {
								let data = scaledImg.displayData;

								if (data && data.scaledX !== 0 || data.scaledY !== 0 || data.scaledWidth !== 0 || data.scaledHeight !== 0) {
									console.log("true");
									zoom = data.zoom ?? 1.0;

									// width/height are authoritative
									width = data.scaledWidth;
									height = data.scaledHeight;

									x = imageX + data.scaledX;
									y = imageY + data.scaledY;

									clampToBounds();
								} else {
									console.log("false");
									zoom = 1.0;
									centerInImage();
								}
							}

							border.color: "lime"
							border.width: 2
							color: "transparent"
							height: baseHeight / zoom
							width: baseWidth / zoom

							onHeightChanged: clampToBounds()
							onWidthChanged: clampToBounds()
						}

						MouseArea {
							id: mouse

							function updateCrop(mouseX, mouseY) {
								let nx = mouseX - cropRect.width * 0.5;
								let ny = mouseY - cropRect.height * 0.5;

								nx = Math.max(cropRect.imageX, Math.min(nx, cropRect.imageX + scaledImg.paintedWidth - cropRect.width));

								ny = Math.max(cropRect.imageY, Math.min(ny, cropRect.imageY + scaledImg.paintedHeight - cropRect.height));

								cropRect.x = nx;
								cropRect.y = ny;
							}

							anchors.fill: parent
							hoverEnabled: true
							preventStealing: true

							onPositionChanged: mouse => {
								if (pressed)
									updateCrop(mouse.x, mouse.y);
							}
							onPressed: mouse => {
								updateCrop(mouse.x, mouse.y);
							}
							onReleased: {
								console.log(cropRect.mapToItem(scaledImg, 0, 0, cropRect.width, cropRect.height), cropRect.width, cropRect.height);
								const croprect = cropRect.mapToItem(scaledImg, 0, 0, cropRect.width, cropRect.height);
								const upscaledRect = Qt.rect(croprect.x * scaledImg.scaleX, croprect.y * scaledImg.scaleY, croprect.width * scaledImg.scaleX, croprect.height * scaledImg.scaleY);
								Wallpapers.setCrop(delegate.modelData.name, upscaledRect, croprect, cropRect.zoom);
							}
							onWheel: wheel => {
								let oldCenterX = cropRect.x + cropRect.width * 0.5;
								let oldCenterY = cropRect.y + cropRect.height * 0.5;

								if (wheel.angleDelta.y > 0)
									cropRect.zoom *= 1.1;
								else
									cropRect.zoom /= 1.1;

								cropRect.zoom = Math.max(1.0, Math.min(cropRect.zoom, 10.0));

								cropRect.x = oldCenterX - cropRect.width * 0.5;
								cropRect.y = oldCenterY - cropRect.height * 0.5;

								cropRect.clampToBounds();
							}
						}
					}
				}
			}
		}
	}
}
