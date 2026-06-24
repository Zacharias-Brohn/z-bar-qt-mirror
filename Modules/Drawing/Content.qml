pragma ComponentBehavior: Bound

import QtQuick
import ZShell.Components
import qs.Config
import qs.Components

Item {
	id: root

	readonly property var colors1: ["#ef4444", "#f97316", "#eab308", "#22c55e", "#06b6d4"]
	readonly property var colors2: ["#3b82f6", "#a855f7", "#ec4899", "#ffffff", "#000000"]
	required property var drawing
	required property var visibilities
	required property Wrapper wrapper

	function syncFromPenColor() {
		if (!drawing)
			return;

		if (!saturationSlider.pressed)
			saturationSlider.value = drawing.drawingState.penColor.hsvSaturation;

		if (!brightnessSlider.pressed)
			brightnessSlider.value = drawing.drawingState.penColor.hsvValue;
	}

	function updatePenColorFromHsv() {
		if (!drawing)
			return;

		drawing.drawingState.penColor = Qt.hsva(huePicker.currentHue, saturationSlider.value, brightnessSlider.value, drawing.drawingState.penColor.a);
	}

	implicitHeight: column.height + Appearance.padding.larger * 2
	implicitWidth: huePicker.implicitWidth + Appearance.padding.normal * 2

	Component.onCompleted: syncFromPenColor()

	Connections {
		function onPenColorChanged() {
			root.syncFromPenColor();
		}

		target: root.drawing.drawingState
	}

	Column {
		id: column

		anchors.centerIn: parent
		spacing: 12

		ColorArcPicker {
			id: huePicker

			drawing: root.drawing
		}

		GradientSlider {
			id: saturationSlider

			anchors.left: parent.left
			anchors.right: parent.right
			brightness: brightnessSlider.value
			channel: "saturation"
			from: 0
			hue: huePicker.currentHue
			icon: "\ue40a"
			implicitHeight: 30
			orientation: Qt.Horizontal
			to: 1

			onMoved: root.updatePenColorFromHsv()
		}

		GradientSlider {
			id: brightnessSlider

			anchors.left: parent.left
			anchors.right: parent.right
			channel: "brightness"
			from: 0
			hue: huePicker.currentHue
			icon: "\ue1ac"
			implicitHeight: 30
			orientation: Qt.Horizontal
			saturation: saturationSlider.value
			to: 1

			onMoved: root.updatePenColorFromHsv()
		}

		ButtonRow {
			id: row1

			anchors.left: parent.left
			anchors.right: parent.right
			spacing: Appearance.spacing.normal

			Repeater {
				model: root.colors1

				delegate: ColorButton {
					row: row1
				}
			}
		}

		ButtonRow {
			id: row2

			anchors.left: parent.left
			anchors.right: parent.right
			spacing: Appearance.spacing.normal

			Repeater {
				model: root.colors2

				delegate: ColorButton {
					row: row2
				}
			}
		}

		FilledSlider {
			anchors.left: parent.left
			anchors.right: parent.right
			from: 1
			icon: "border_color"
			implicitHeight: 30
			multiplier: 1
			orientation: Qt.Horizontal
			to: 45
			value: root.drawing.drawingState.penWidth

			onMoved: root.drawing.drawingState.penWidth = value
		}

		ButtonRow {
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: Appearance.spacing.small

			IconTextButton {
				fillWidth: true
				font.pointSize: Appearance.font.size.normal
				icon: "close"
				inactiveColor: DynamicColors.palette.m3error
				inactiveOnColor: DynamicColors.palette.m3onError
				isRound: true
				shapeMorph: true
				text: "Exit"

				onClicked: root.visibilities.isDrawing = false
			}

			IconTextButton {
				fillWidth: true
				font.pointSize: Appearance.font.size.normal
				icon: "ink_eraser"
				inactiveColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
				inactiveOnColor: DynamicColors.palette.m3onSurfaceVariant
				isRound: true
				shapeMorph: true
				text: "Clear"

				onClicked: root.drawing.content.clear()
			}
		}
	}

	IconButton {
		anchors.margins: Appearance.padding.normal
		anchors.right: parent.right
		anchors.top: parent.top
		checked: root.wrapper.pinned
		icon: "keep"
		isToggle: true
		shapeMorph: true

		onClicked: {
			root.wrapper.togglePinned();
		}
	}

	component ColorButton: IconButton {
		id: colorButton

		readonly property real buttonSize: (row.width - row.spacing * 4) / 5
		required property color modelData
		required property ButtonRow row

		fillWidth: false
		font.pointSize: Appearance.font.size.normal
		icon: ""
		implicitHeight: buttonSize
		implicitWidth: buttonSize
		inactiveColor: modelData
		inactiveOnColor: DynamicColors.on(modelData)
		isRound: true
		shapeMorph: true
		shapeMorphExpansion: pressed ? 12 : 0

		onClicked: root.drawing.drawingState.penColor = modelData
	}
}
