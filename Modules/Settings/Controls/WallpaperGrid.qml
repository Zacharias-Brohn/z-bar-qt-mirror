pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ZShell.Models
import qs.Components
import qs.Helpers
import qs.Config

GridView {
	id: root

	readonly property int columnsCount: Math.max(1, Math.floor(width / minCellWidth))
	readonly property int minCellWidth: 200 + Appearance.spacing.normal
	property bool shouldBeActive: true

	anchors.left: parent.left
	anchors.right: parent.right
	cellHeight: 140 + Appearance.spacing.normal
	cellWidth: width / columnsCount
	clip: true
	implicitHeight: shouldBeActive ? contentHeight : 0
	interactive: false
	model: Wallpapers.list
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0

	delegate: Item {
		required property int index
		readonly property bool isCurrent: modelData && modelData.path === Wallpapers.actualCurrent
		readonly property real itemMargin: Appearance.spacing.normal
		readonly property real itemRadius: Appearance.rounding.small
		required property var modelData

		height: root.cellHeight
		width: root.cellWidth

		CustomClippingRect {
			id: image

			anchors.bottomMargin: itemMargin
			anchors.fill: parent
			anchors.leftMargin: itemMargin
			anchors.rightMargin: itemMargin
			anchors.topMargin: itemMargin
			antialiasing: true
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: itemRadius

			CachingImage {
				id: cachingImage

				anchors.fill: parent
				antialiasing: true
				cache: true
				fillMode: Image.PreserveAspectCrop
				opacity: status === Image.Ready ? 1 : 0
				path: modelData.path
				smooth: true
				sourceSize: Qt.size(width, height)
				visible: opacity > 0

				Behavior on opacity {
					NumberAnimation {
						duration: 1000
						easing.type: Easing.OutQuad
					}
				}
			}

			Image {
				id: fallbackImage

				anchors.fill: parent
				antialiasing: true
				asynchronous: true
				cache: true
				fillMode: Image.PreserveAspectCrop
				opacity: status === Image.Ready && cachingImage.status !== Image.Ready ? 1 : 0
				smooth: true
				source: fallbackTimer.triggered && cachingImage.status !== Image.Ready ? modelData.path : ""
				sourceSize: Qt.size(width, height)
				visible: opacity > 0

				Behavior on opacity {
					NumberAnimation {
						duration: 1000
						easing.type: Easing.OutQuad
					}
				}
			}

			Rectangle {
				anchors.fill: parent
				antialiasing: true
				border.color: DynamicColors.palette.m3primary
				border.width: isCurrent ? 2 : 0
				color: "transparent"
				radius: itemRadius + 2
				smooth: true

				Behavior on border.width {
					NumberAnimation {
						duration: 150
						easing.type: Easing.OutQuad
					}
				}

				MaterialIcon {
					anchors.margins: Appearance.padding.small
					anchors.right: parent.right
					anchors.top: parent.top
					color: DynamicColors.palette.m3primary
					font.pointSize: Appearance.font.size.large
					text: "check_circle"
					visible: isCurrent
				}
			}

			Timer {
				id: fallbackTimer

				property bool triggered: false

				interval: 800
				running: cachingImage.status === Image.Loading || cachingImage.status === Image.Null

				onTriggered: triggered = true
			}
		}

		StateLayer {
			function onClicked(): void {
				Wallpapers.setWallpaper(modelData.path);
			}

			anchors.bottomMargin: itemMargin
			anchors.fill: parent
			anchors.leftMargin: itemMargin
			anchors.rightMargin: itemMargin
			anchors.topMargin: itemMargin
			radius: itemRadius
		}
	}
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
}
