pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Effects
import qs.Config
import qs.Components

Item {
	id: root

	required property Item bar
	required property PersistentProperties visibilities

	anchors.fill: parent

	CustomRect {
		anchors.fill: parent
		anchors.margins: -1
		color: DynamicColors.palette.m3surface
		layer.enabled: true

		layer.effect: MultiEffect {
			maskEnabled: true
			maskInverted: true
			maskSource: mask
			maskSpreadAtMin: 1
			maskThresholdMin: 0.5
		}
	}

	Item {
		id: mask

		anchors.fill: parent
		layer.enabled: true
		visible: false

		Rectangle {
			anchors.fill: parent
			anchors.margins: Config.bar.border + 1
			anchors.topMargin: root.bar.implicitHeight + 1
			radius: Config.bar.border > 0 ? Config.bar.rounding : 0
			topLeftRadius: Config.bar.rounding
			topRightRadius: Config.bar.rounding
		}
	}
}
