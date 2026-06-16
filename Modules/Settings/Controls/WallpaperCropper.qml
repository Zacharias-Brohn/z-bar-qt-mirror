pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ZShell.Internal
import qs.Config
import qs.Components
import qs.Helpers

Item {
	id: wrapper

	property bool changesMade: false
	property bool shouldBeActive: true

	signal requestCrop

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? 400 : 0
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

	IconButton {
		anchors.margins: Appearance.padding.normal
		anchors.right: parent.right
		anchors.top: parent.top
		icon: "check"
		opacity: wrapper.changesMade ? 1 : 0
		scale: wrapper.changesMade ? 1 : 0
		z: 2

		Behavior on opacity {
			Anim {
			}
		}
		Behavior on scale {
			Anim {
			}
		}

		onClicked: {
			wrapper.requestCrop();
			wrapper.changesMade = false;
		}
	}

	RowLayout {
		id: root

		anchors.fill: parent
		spacing: Appearance.spacing.normal

		Repeater {
			model: ScriptModel {
				values: [...Quickshell.screens].sort((a, b) => {
					return a.x - b.x;
				})
			}

			Item {
				id: delegate

				required property ShellScreen modelData

				function applyCrop(): void {
					if (!cropRectLoader.item)
						return;
					const cropRect = cropRectLoader.item;

					// We need to calculate the exact percentage coordinates that map perfectly
					// to our C++ backend, regardless of current display scaling
					const cropXPercent = (cropRect.x - cropRect.imageX) / scaledImg.paintedWidth;
					const cropYPercent = (cropRect.y - cropRect.imageY) / scaledImg.paintedHeight;
					const cropWidthPercent = cropRect.width / scaledImg.paintedWidth;
					const cropHeightPercent = cropRect.height / scaledImg.paintedHeight;

					const finalRect = Qt.rect(cropXPercent, cropYPercent, cropWidthPercent, cropHeightPercent);

					// We just pass the percentages directly to the backend
					Wallpapers.setCrop(delegate.modelData.name, finalRect, cropRect.zoom);
				}

				function zoomClipRect(zoom: real): void {
					if (!cropRectLoader.item)
						return;
					const cropRect = cropRectLoader.item;

					let oldCenterX = cropRect.x + cropRect.width * 0.5;
					let oldCenterY = cropRect.y + cropRect.height * 0.5;

					cropRect.zoom = zoom;

					cropRect.x = oldCenterX - cropRect.width * 0.5;
					cropRect.y = oldCenterY - cropRect.height * 0.5;

					cropRect.clampToBounds();
				}

				Layout.fillHeight: true
				Layout.fillWidth: true

				Connections {
					function onRequestCrop(): void {
						delegate.applyCrop();
					}

					target: wrapper
				}

				RowLayout {
					id: sliderLayout

					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.right: parent.right
					implicitHeight: 30

					CustomSlider {
						id: zoomSlider

						Layout.fillWidth: true
						Layout.leftMargin: Appearance.padding.normal
						Layout.preferredHeight: Appearance.padding.larger * 3
						Layout.rightMargin: Appearance.padding.normal
						from: 1.0
						implicitHeight: Appearance.padding.larger * 3
						insetIcon: "crop"
						to: 5.0
						value: cropRectLoader.item ? cropRectLoader.item.zoom : 1.0

						onInteraction: value => {
							delegate.zoomClipRect(1 + (value * 4));
							wrapper.changesMade = true;
						}
					}
				}

				CachingImage {
					id: scaledImg

					property var displayData
					property real monitorScale: 1.0

					anchors.bottom: sliderLayout.top
					anchors.bottomMargin: Appearance.spacing.normal
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					asynchronous: true
					fillMode: Image.PreserveAspectFit
					retainWhileLoading: true
					source: Wallpapers.current
					sourceSize.height: parent.height
					sourceSize.width: parent.width

					onPaintedWidthChanged: {
						if (paintedWidth > 0 && cropRectLoader.item) {
							cropRectLoader.item.restoreFromData();
						}
					}
					onSourceChanged: {
						if (cropRectLoader.item) {
							cropRectLoader.item.restoreFromData();
						}
					}
					onStatusChanged: {
						if (scaledImg.status == Image.Ready && cropRectLoader.item) {
							cropRectLoader.item.restoreFromData();
						}
					}

					CustomText {
						id: monitorId

						anchors.centerIn: parent
						color: Qt.alpha(DynamicColors.palette.m3surface, 0.85)
						font.pointSize: Appearance.font.size.large * 4
						style: Text.Outline
						styleColor: DynamicColors.palette.m3onSurface
						text: delegate.modelData.name
					}

					Loader {
						id: cropRectLoader

						active: scaledImg.paintedWidth > 0

						sourceComponent: Component {
							CustomRect {
								id: cropRect

								property real aspectRatio: delegate.modelData.width / delegate.modelData.height
								readonly property real baseHeight: baseWidth / aspectRatio
								readonly property real baseWidth: {
									let fittedHeight = scaledImg.paintedHeight;
									let fittedWidth = fittedHeight * aspectRatio;

									if (fittedWidth > scaledImg.paintedWidth) {
										fittedWidth = scaledImg.paintedWidth;
										fittedHeight = fittedWidth / aspectRatio;
									}

									return fittedWidth;
								}
								readonly property real imageX: (scaledImg.width - scaledImg.paintedWidth) / 2
								readonly property real imageY: (scaledImg.height - scaledImg.paintedHeight) / 2
								property real imgAspectRatio: scaledImg.paintedWidth / scaledImg.paintedHeight
								property real zoom: 1.0

								function centerInImage() {
									x = imageX + (scaledImg.paintedWidth - width) / 2;
									y = imageY + (scaledImg.paintedHeight - height) / 2;
								}

								function clampToBounds() {
									x = Math.max(imageX, Math.min(x, imageX + scaledImg.paintedWidth - width));

									y = Math.max(imageY, Math.min(y, imageY + scaledImg.paintedHeight - height));
								}

								function restoreFromData() {
									let data = Wallpapers.getCrop(delegate.modelData.name);

									if (data && (Math.abs(data.x) > 0.001 || Math.abs(data.y) > 0.001 || Math.abs(data.width - 1.0) > 0.001 || Math.abs(data.height - 1.0) > 0.001)) {
										zoom = data.zoom > 0 ? data.zoom : 1.0;
										x = imageX + (data.x * scaledImg.paintedWidth);
										y = imageY + (data.y * scaledImg.paintedHeight);

										clampToBounds();
									} else {
										zoom = 1.0;
										centerInImage();
									}
								}

								border.color: DynamicColors.palette.m3primary
								border.width: 2
								height: baseHeight / zoom
								opacity: 1
								width: baseWidth / zoom

								Behavior on opacity {
									Anim {
									}
								}

								Component.onCompleted: {
									restoreFromData();
								}
								onHeightChanged: clampToBounds()
								onWidthChanged: clampToBounds()
							}
						}
					}

					MouseArea {
						id: mouse

						function updateCrop(mouseX, mouseY) {
							if (!cropRectLoader.item)
								return;
							const cropRect = cropRectLoader.item;

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
							if (pressed) {
								updateCrop(mouse.x, mouse.y);
								wrapper.changesMade = true;
							}
						}
						onPressed: mouse => {
							updateCrop(mouse.x, mouse.y);
							wrapper.changesMade = true;
						}
						onReleased: {
							wrapper.changesMade = true;
						}
					}
				}
			}
		}
	}
}
