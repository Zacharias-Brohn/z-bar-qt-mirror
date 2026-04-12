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

	Layout.preferredHeight: contentHeight
	cellHeight: 140 + Appearance.spacing.normal
	cellWidth: width / columnsCount
	clip: true
	interactive: false
	model: Wallpapers.list

	delegate: Item {
		required property int index
		readonly property bool isCurrent: modelData && modelData.path === Wallpapers.actualCurrent
		readonly property real itemMargin: Appearance.spacing.normal / 2
		readonly property real itemRadius: Appearance.rounding.normal
		required property var modelData

		height: root.cellHeight
		width: root.cellWidth

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

		CustomClippingRect {
			id: image

			anchors.bottomMargin: itemMargin
			anchors.fill: parent
			anchors.leftMargin: itemMargin
			anchors.rightMargin: itemMargin
			anchors.topMargin: itemMargin
			antialiasing: true
			color: DynamicColors.tPalette.m3surfaceContainer
			layer.enabled: true
			layer.smooth: true
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

			Timer {
				id: fallbackTimer

				property bool triggered: false

				interval: 800
				running: cachingImage.status === Image.Loading || cachingImage.status === Image.Null

				onTriggered: triggered = true
			}
		}

		Rectangle {
			anchors.bottomMargin: itemMargin
			anchors.fill: parent
			anchors.leftMargin: itemMargin
			anchors.rightMargin: itemMargin
			anchors.topMargin: itemMargin
			antialiasing: true
			border.color: DynamicColors.palette.m3primary
			border.width: isCurrent ? 2 : 0
			color: "transparent"
			radius: itemRadius - border.width
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
	}
}
