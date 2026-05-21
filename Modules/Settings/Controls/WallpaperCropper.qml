pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
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

			Layout.fillHeight: true
			Layout.fillWidth: true

			Image {
				id: scaledImg

				property var displayData
				readonly property real imageRatio: scaledImg.sourceSize.width / scaledImg.sourceSize.height
				property real monitorScale: 1.0
				readonly property real scaleDownX: scaledImg.width / scaledImg.sourceSize.width
				readonly property real scaleDownY: scaledImg.height / scaledImg.sourceSize.height
				readonly property real scaleX: (scaledImg.sourceSize.width * monitorScale) / scaledImg.width
				readonly property real scaleY: (scaledImg.sourceSize.height * monitorScale) / scaledImg.height

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				height: width / imageRatio
				source: Wallpapers.current

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
						let fittedHeight = scaledImg.height;
						let fittedWidth = fittedHeight * aspectRatio;

						if (fittedWidth > scaledImg.width) {
							fittedWidth = scaledImg.width;
							fittedHeight = fittedWidth / aspectRatio;
						}

						return fittedWidth;
					}
					readonly property real imageX: (scaledImg.width - scaledImg.width) / 2
					readonly property real imageY: (scaledImg.height - scaledImg.height) / 2
					property real zoom: scaledImg.displayData.zoom

					function centerInImage() {
						x = imageX + (scaledImg.width - width) / 2;
						y = imageY + (scaledImg.height - height) / 2;
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
					width: baseWidth / zoom

					onHeightChanged: clampToBounds()
					onWidthChanged: clampToBounds()
				}

				MouseArea {
					id: mouse

					function updateCrop(mouseX, mouseY) {
						let nx = mouseX - cropRect.width * 0.5;
						let ny = mouseY - cropRect.height * 0.5;

						nx = Math.max(cropRect.imageX, Math.min(nx, cropRect.imageX + scaledImg.width - cropRect.width));

						ny = Math.max(cropRect.imageY, Math.min(ny, cropRect.imageY + scaledImg.height - cropRect.height));

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
						const croprect = cropRect.mapToItem(scaledImg, 0, 0, cropRect.width, cropRect.height);
						const upscaledRect = Qt.rect(croprect.x / scaledImg.width, croprect.y / scaledImg.height, croprect.width / scaledImg.width, croprect.height / scaledImg.height);
						Wallpapers.setCrop(delegate.modelData.name, upscaledRect, croprect, cropRect.zoom);
					}
					onWheel: wheel => {
						let oldCenterX = cropRect.x + cropRect.width * 0.5;
						let oldCenterY = cropRect.y + cropRect.height * 0.5;

						if (wheel.angleDelta.y > 0)
							cropRect.zoom *= 1.1;
						else
							cropRect.zoom /= 1.1;

						cropRect.zoom = Math.max(1.0, Math.min(cropRect.zoom, 5.0));
						console.log(cropRect.zoom);

						cropRect.x = oldCenterX - cropRect.width * 0.5;
						cropRect.y = oldCenterY - cropRect.height * 0.5;

						cropRect.clampToBounds();
					}
				}
			}
		}
	}
}
