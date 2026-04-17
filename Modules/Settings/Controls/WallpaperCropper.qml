import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Config
import qs.Components
import qs.Helpers

ColumnLayout {
	id: root

	spacing: 15
	width: Math.min(parent ? parent.width : 600, 600)

	Rectangle {
		id: previewContainer

		Layout.fillHeight: true
		Layout.preferredWidth: height * (Quickshell.screens.length > 0 ? (Quickshell.screens[0].height / Math.max(1, Quickshell.screens[0].width)) : 16 / 9)
		clip: true
		color: DynamicColors.palette.m3surfaceContainer
		radius: Config.appearance.rounding.scale * 10

		Image {
			id: img

			anchors.fill: parent
			asynchronous: true
			fillMode: Image.PreserveAspectFit
			source: Wallpapers.current

			Rectangle {
				id: cropRect

				property real cropHeight: (imageAspect > screenAspect ? paintedHeight : paintedWidth / screenAspect) / Config.background.zoom
				property real cropWidth: (imageAspect > screenAspect ? paintedHeight * screenAspect : paintedWidth) / Config.background.zoom
				property real imageAspect: Math.max(1, paintedWidth) / Math.max(1, paintedHeight)
				property real paintedHeight: img.paintedHeight > 0 ? img.paintedHeight : img.height
				property real paintedWidth: img.paintedWidth > 0 ? img.paintedWidth : img.width
				property real paintedX: (img.width - paintedWidth) / 2
				property real paintedY: (img.height - paintedHeight) / 2
				property real screenAspect: Quickshell.screens.length > 0 ? (Quickshell.screens[0].width / Math.max(1, Quickshell.screens[0].height)) : 16 / 9

				border.color: DynamicColors.palette.m3primary
				border.width: 2
				color: Qt.alpha(DynamicColors.palette.m3primaryContainer, 0.3)
				height: cropHeight
				width: cropWidth
				x: paintedX + (paintedWidth - width) * Config.background.alignX
				y: paintedY + (paintedHeight - height) * Config.background.alignY

				DragHandler {
					target: null

					onActiveTranslationChanged: {
						if (active) {
							let newX = cropRect.x - cropRect.paintedX + translation.x;
							let newY = cropRect.y - cropRect.paintedY + translation.y;

							let rangeX = cropRect.paintedWidth - cropRect.width;
							let rangeY = cropRect.paintedHeight - cropRect.height;

							if (rangeX > 0) {
								let valX = newX / rangeX;
								Config.background.alignX = Math.max(0.0, Math.min(1.0, valX));
								Config.save();
							}

							if (rangeY > 0) {
								let valY = newY / rangeY;
								Config.background.alignY = Math.max(0.0, Math.min(1.0, valY));
								Config.save();
							}
						}
					}
				}

				PinchHandler {
					maximumScale: 5.0
					minimumScale: 1.0
					target: null

					onActiveScaleChanged: {
						if (active) {
							let newZoom = Config.background.zoom * (1 / (1 + (activeScale - 1) * 0.1));
							Config.background.zoom = Math.max(1.0, Math.min(newZoom, 5.0));
						}
					}
				}
			}
		}
	}

	SettingSpinBox {
		max: 5.0
		min: 1.0
		name: "Zoom"
		object: Config.background
		setting: "zoom"
		step: 0.1
	}
}
