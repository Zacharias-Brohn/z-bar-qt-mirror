pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ZShell.Components
import qs.Config
import qs.Components
import qs.Helpers

Item {
	id: wrapper

	property int buttonRowHeight: Appearance.padding.large * 3
	property bool changesMade: false
	readonly property var currentScreen: screens.length > selectedScreenIndex ? screens[selectedScreenIndex] : null
	property var screens: []
	property int selectedScreenIndex: 0
	property bool shouldBeActive: true

	function applyCrop(): void {
		if (!cropRectLoader.item || !currentScreen)
			return;

		const cropRect = cropRectLoader.item;

		const cropXPercent = (cropRect.x - cropRect.imageX) / scaledImg.paintedWidth;
		const cropYPercent = (cropRect.y - cropRect.imageY) / scaledImg.paintedHeight;
		const cropWidthPercent = cropRect.width / scaledImg.paintedWidth;
		const cropHeightPercent = cropRect.height / scaledImg.paintedHeight;

		Wallpapers.setCrop(currentScreen.name, Qt.rect(cropXPercent, cropYPercent, cropWidthPercent, cropHeightPercent), cropRect.zoom);
	}

	function refreshScreens(): void {
		screens = [...Quickshell.screens].sort((a, b) => a.x - b.x);
		selectedScreenIndex = 0;
	}

	function selectScreen(index: int): void {
		if (index < 0 || index >= screens.length || index === selectedScreenIndex)
			return;

		selectedScreenIndex = index;

		if (cropRectLoader.item)
			Qt.callLater(syncCropToScreen);
	}

	function syncCropToScreen(): void {
		if (cropRectLoader.item)
			cropRectLoader.item.restoreFromData();
	}

	function zoomClipRect(zoom: real): void {
		if (!cropRectLoader.item)
			return;

		const cropRect = cropRectLoader.item;

		const centerX = cropRect.x + cropRect.width * 0.5;
		const centerY = cropRect.y + cropRect.height * 0.5;

		cropRect.zoom = zoom;

		cropRect.x = centerX - cropRect.width * 0.5;
		cropRect.y = centerY - cropRect.height * 0.5;

		cropRect.clampToBounds();
	}

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? 430 : 0
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

	Component.onCompleted: {
		refreshScreens();
		Qt.callLater(syncCropToScreen);
	}
	onSelectedScreenIndexChanged: {
		Qt.callLater(syncCropToScreen);
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
			wrapper.applyCrop();
			wrapper.changesMade = false;
		}
	}

	ButtonRow {
		id: screenSelector

		anchors.bottom: scaledImg.top
		anchors.bottomMargin: Appearance.spacing.normal
		anchors.left: parent.left
		anchors.leftMargin: Appearance.padding.extraLarge * 2
		anchors.right: parent.right
		anchors.rightMargin: Appearance.padding.extraLarge * 2
		anchors.top: parent.top
		spacing: Appearance.spacing.small

		Repeater {
			model: wrapper.screens

			delegate: TextButton {
				required property int index
				readonly property bool isCurrent: wrapper.selectedScreenIndex === index
				required property var modelData

				fillWidth: true
				inactiveColor: isCurrent ? DynamicColors.palette.m3primary : Qt.alpha(DynamicColors.palette.m3surfaceContainer, 0.7)
				inactiveOnColor: isCurrent ? DynamicColors.palette.m3onPrimary : Qt.alpha(DynamicColors.palette.m3onSurface, 0.7)
				isRound: true
				shapeMorph: true
				text: modelData.name

				onClicked: wrapper.selectScreen(index)
			}
		}
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
				wrapper.zoomClipRect(1 + (value * 4));
				wrapper.changesMade = true;
			}
		}
	}

	Image {
		id: scaledImg

		property var displayData
		property real monitorScale: 1.0

		anchors.bottom: sliderLayout.top
		anchors.bottomMargin: Appearance.spacing.normal
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.topMargin: wrapper.buttonRowHeight + Appearance.spacing.normal
		// anchors.top: screenSelector.bottom
		asynchronous: true
		fillMode: Image.PreserveAspectFit
		retainWhileLoading: true
		source: Wallpapers.current
		sourceSize.height: parent.height
		sourceSize.width: parent.width

		onPaintedWidthChanged: {
			if (paintedWidth > 0 && cropRectLoader.item) {
				if (!wrapper.screens.length)
					wrapper.refreshScreens();

				wrapper.syncCropToScreen();
			}
		}
		onSourceChanged: {
			if (cropRectLoader.item) {
				if (!wrapper.screens.length)
					wrapper.refreshScreens();

				wrapper.syncCropToScreen();
			}
		}
		onStatusChanged: {
			if (scaledImg.status == Image.Ready && cropRectLoader.item) {
				if (!wrapper.screens.length)
					wrapper.refreshScreens();

				wrapper.syncCropToScreen();
			}
		}

		Loader {
			id: cropRectLoader

			active: scaledImg.status === Image.Ready

			sourceComponent: Component {
				CustomRect {
					id: cropRect

					property real aspectRatio: wrapper.currentScreen ? wrapper.currentScreen.width / wrapper.currentScreen.height : 1
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
						let data = Wallpapers.getCrop(wrapper.currentScreen.name);

						console.log(data.x, data.y);

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
