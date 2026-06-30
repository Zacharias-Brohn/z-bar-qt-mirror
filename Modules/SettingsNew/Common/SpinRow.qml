pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ConnectedRect {
	id: root

	property real from: 0
	property real stepSize: 1
	property string subtext
	property alias text: label.text
	property real to: 99
	property real value

	signal moved(value: real)

	Layout.fillWidth: true
	implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins * 2

	RowLayout {
		id: rowLayout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.largeIncreased
		anchors.margins: Appearance.padding.normal
		anchors.rightMargin: Appearance.padding.largeIncreased
		spacing: Appearance.spacing.small

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			CustomText {
				id: label

				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.smaller
			}

			CustomText {
				Layout.fillWidth: true
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				text: root.subtext
				visible: root.subtext
			}
		}

		CustomSpinBox {
			from: root.from
			stepSize: root.stepSize
			to: root.to
			value: root.value

			onValueModified: root.moved(value)
		}
	}
}
