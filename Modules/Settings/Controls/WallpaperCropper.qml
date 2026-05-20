pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Config
import qs.Components
import qs.Helpers

RowLayout {
	id: root

	required property ShellScreen screen

	spacing: Appearance.spacing.normal

	Repeater {
		model: Quickshell.screens

		delegate: ImgCrop {
		}
	}

	component ImgCrop: Item {
		id: cropper

		readonly property var displayData: Wallpapers.getCrop(modelData.name)
		required property ShellScreen modelData

		Layout.fillHeight: true
		Layout.fillWidth: true

		Image {
			id: imageView

			property real displayH: paintedHeight
			property real displayW: paintedWidth
			property real displayX: (width - paintedWidth) * 0.5
			property real displayY: (height - paintedHeight) * 0.5
			property real scaleX: sourceW / displayW
			property real scaleY: sourceH / displayH
			property real sourceH: cropper.modelData.height
			property real sourceW: cropper.modelData.width

			anchors.fill: parent
			fillMode: Image.PreserveAspectFit
			smooth: true
			source: Wallpapers.current
		}

		Item {
			id: overlay

			clip: true
			height: imageView.displayH
			width: imageView.displayW
			x: imageView.displayX
			y: imageView.displayY

			CustomRect {
				id: cropRect

				property real aspectRatio: cropper.modelData.width / cropper.modelData.height
				readonly property rect sourceRect: Qt.rect(x * imageView.scaleX, y * imageView.scaleY, width * imageView.scaleX, height * imageView.scaleY)
				property real zoom: cropper.displayData.zoom

				function clampToBounds() {
					x = Math.max(0, Math.min(x, overlay.width - width));

					y = Math.max(0, Math.min(y, overlay.height - height));
				}

				border.color: DynamicColors.palette.m3primary
				border.width: 2
				color: DynamicColors.tPalette.m3primary
				height: width / aspectRatio
				radius: Appearance.rounding.small
				visible: imageView.status === Image.Ready
				width: Math.min(overlay.width / zoom, overlay.height * aspectRatio / zoom)
				x: cropper.displayData.x / imageView.scaleX
				y: cropper.displayData.y / imageView.scaleY
			}

			MouseArea {
				function updateCrop(mouseX, mouseY) {
					let nx = mouseX - cropRect.width * 0.5;
					let ny = mouseY - cropRect.height * 0.5;

					nx = Math.max(0, Math.min(nx, overlay.width - cropRect.width));

					ny = Math.max(0, Math.min(ny, overlay.height - cropRect.height));

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
					Wallpapers.recentlyChanged = false;
					Wallpapers.setCrop(cropper.modelData.name, cropRect.sourceRect, cropRect.zoom);
					// Config.background.sourceClipX = cropRect.sourceRect.x;
					// Config.background.sourceClipY = cropRect.sourceRect.y;
					// Config.background.sourceClipW = cropRect.sourceRect.width;
					// Config.background.sourceClipH = cropRect.sourceRect.height;
					// Config.save();
				}
				onWheel: wheel => {
					let oldCenterX = cropRect.x + cropRect.width * 0.5;
					let oldCenterY = cropRect.y + cropRect.height * 0.5;

					if (wheel.angleDelta.y > 0)
						cropRect.zoom *= 1.1;
					else
						cropRect.zoom /= 1.1;

					cropRect.zoom = Math.max(1.0, Math.min(cropRect.zoom, 10.0));
					Config.background.zoom = cropRect.zoom;

					cropRect.x = oldCenterX - cropRect.width * 0.5;
					cropRect.y = oldCenterY - cropRect.height * 0.5;

					cropRect.clampToBounds();
				}
			}
		}
	}
}
