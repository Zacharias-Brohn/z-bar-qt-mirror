import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Config
import qs.Components
import qs.Helpers

Item {
	id: root

	Image {
		id: imageView

		property real displayH: paintedHeight
		property real displayW: paintedWidth
		property real displayX: (width - paintedWidth) * 0.5
		property real displayY: (height - paintedHeight) * 0.5
		property real scaleX: sourceW / displayW
		property real scaleY: sourceH / displayH
		property real sourceH: sourceSize.height
		property real sourceW: sourceSize.width

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

			property real aspectRatio: Quickshell.screens[0].width / Quickshell.screens[0].height
			readonly property rect sourceRect: Qt.rect(x * imageView.scaleX, y * imageView.scaleY, width * imageView.scaleX, height * imageView.scaleY)
			property real zoom: Config.background.zoom

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
			x: Config.background.sourceClipX / imageView.scaleX
			y: Config.background.sourceClipY / imageView.scaleY
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
				Config.background.sourceClipX = cropRect.sourceRect.x;
				Config.background.sourceClipY = cropRect.sourceRect.y;
				Config.background.sourceClipW = cropRect.sourceRect.width;
				Config.background.sourceClipH = cropRect.sourceRect.height;
				Config.save();
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
