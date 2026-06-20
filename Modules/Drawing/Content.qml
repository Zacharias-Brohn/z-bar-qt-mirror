pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ZShell.Components
import qs.Config
import qs.Components

Item {
	id: root

	readonly property var colors1: ["#ef4444", "#f97316", "#eab308", "#22c55e", "#06b6d4"]
	readonly property var colors2: ["#3b82f6", "#a855f7", "#ec4899", "#ffffff", "#000000"]
	required property var drawing
	required property var visibilities

	function syncFromPenColor() {
		if (!drawing)
			return;

		if (!saturationSlider.pressed)
			saturationSlider.value = drawing.penColor.hsvSaturation;

		if (!brightnessSlider.pressed)
			brightnessSlider.value = drawing.penColor.hsvValue;
	}

	function updatePenColorFromHsv() {
		if (!drawing)
			return;

		drawing.penColor = Qt.hsva(huePicker.currentHue, saturationSlider.value, brightnessSlider.value, drawing.penColor.a);
	}

	implicitHeight: column.height + Appearance.padding.larger * 2
	implicitWidth: huePicker.implicitWidth + Appearance.padding.normal * 2

	Component.onCompleted: syncFromPenColor()

	Connections {
		function onPenColorChanged() {
			root.syncFromPenColor();
		}

		target: root.drawing
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
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: Appearance.spacing.normal

			Repeater {
				model: root.colors1

				delegate: ColorButton {
				}
			}
		}

		ButtonRow {
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: Appearance.spacing.normal

			Repeater {
				model: root.colors2

				delegate: ColorButton {
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
			value: root.drawing.penWidth

			onMoved: root.drawing.penWidth = value
		}
	}

	component ColorButton: IconButton {
		id: colorButton

		required property color modelData

		fillWidth: false
		icon: ""
		inactiveColor: modelData
		inactiveOnColor: DynamicColors.on(modelData)
		isRound: true
		padding: Appearance.padding.extraSmall
		shapeMorph: true
		shapeMorphExpansion: pressed ? 12 : 0

		onClicked: root.drawing.penColor = modelData
	}
}
