pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ZShell.Internal
import qs.Config
import qs.Components
import qs.Helpers

RowLayout {
	id: root

	required property ShellScreen screen

	Layout.fillWidth: true
	Layout.preferredHeight: 400
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

			function zoomClipRect(zoom: real): void {
				let oldCenterX = cropRect.x + cropRect.width * 0.5;
				let oldCenterY = cropRect.y + cropRect.height * 0.5;

				cropRect.zoom = zoom;

				cropRect.x = oldCenterX - cropRect.width * 0.5;
				cropRect.y = oldCenterY - cropRect.height * 0.5;

				cropRect.clampToBounds();
			}

			Layout.fillHeight: true
			Layout.fillWidth: true

			RowLayout {
				id: sliderLayout

				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				implicitHeight: 30
				spacing: Appearance.spacing.large

				CustomText {
					text: qsTr("Crop scale")
				}

				CustomSlider {
					id: zoomSlider

					Layout.fillWidth: true
					Layout.preferredHeight: 10
					from: 1.0
					to: 5.0
					value: cropRect.zoom

					onMoved: delegate.zoomClipRect(value)
				}
			}

			CachingImage {
				id: scaledImg

				property var displayData
				property real monitorScale: 1.0

				anchors.bottom: sliderLayout.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				asynchronous: true
				fillMode: Image.PreserveAspectFit
				// retainWhileLoading: true
				source: Wallpapers.current
				sourceSize.height: parent.height
				sourceSize.width: parent.width

				onPaintedWidthChanged: {
					if (paintedWidth > 0) {
						scaledImg.displayData = Wallpapers.getCrop(delegate.modelData.name);
						cropRect.zoom = Wallpapers.getCrop(delegate.modelData.name).zoom;
						cropRect.restoreFromData();
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
							x = data.scaledX;
							y = data.scaledY;

							clampToBounds();
						} else {
							zoom = 1.0;
							centerInImage();
						}
					}

					border.color: "lime"
					border.width: 2
					height: baseHeight / zoom
					opacity: zoom > 1.0 ? 1 : Math.abs(aspectRatio - imgAspectRatio) > 0.1 ? 1 : 0
					width: baseWidth / zoom

					Behavior on opacity {
						Anim {
						}
					}

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
						if (cropRect.opacity > 0) {
							const croprect = cropRect.mapToItem(scaledImg, 0, 0, cropRect.width, cropRect.height);
							const upscaledRect = Qt.rect((croprect.x - cropRect.imageX) / scaledImg.paintedWidth, (croprect.y - cropRect.imageY) / scaledImg.paintedHeight, croprect.width / scaledImg.paintedWidth, croprect.height / scaledImg.paintedHeight);
							Wallpapers.setCrop(delegate.modelData.name, upscaledRect, croprect, cropRect.zoom);
						}
					}
					onWheel: wheel => {
						let oldCenterX = cropRect.x + cropRect.width * 0.5;
						let oldCenterY = cropRect.y + cropRect.height * 0.5;

						if (wheel.angleDelta.y > 0)
							cropRect.zoom *= 1.1;
						else
							cropRect.zoom /= 1.1;

						cropRect.zoom = Math.max(1.0, Math.min(cropRect.zoom, 5.0));

						cropRect.x = oldCenterX - cropRect.width * 0.5;
						cropRect.y = oldCenterY - cropRect.height * 0.5;

						cropRect.clampToBounds();
					}
				}
			}
		}
	}
}
