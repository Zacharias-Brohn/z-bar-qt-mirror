pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ConnectedRect {
	id: root

	property alias icon: slider.insetIcon
	property alias label: label.text
	property real value
	property alias valueLabel: valueLabel.text

	signal moved(value: real)

	Layout.fillWidth: true
	implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins + rowLayout.anchors.topMargin

	RowLayout {
		id: rowLayout

		anchors.fill: parent
		anchors.margins: Appearance.padding.largeIncreased
		anchors.topMargin: Appearance.padding.large
		spacing: Appearance.spacing.small

		ColumnLayout {
			Layout.fillWidth: true
			spacing: Appearance.spacing.small

			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.small

				CustomText {
					id: label

					Layout.fillWidth: true
					elide: Text.ElideRight
					font.pointSize: Appearance.font.size.small
				}

				CustomText {
					id: valueLabel

					color: DynamicColors.palette.m3outline
					font.pointSize: Appearance.font.size.small
				}
			}

			CustomMouseArea {
				function onWheel(event: WheelEvent): void {
					const step = Config.services.audioIncrement;
					if (event.angleDelta.y > 0)
						root.moved(Math.min(1, root.value + step));
					else if (event.angleDelta.y < 0)
						root.moved(Math.max(0, root.value - step));
				}

				Layout.fillWidth: true
				implicitHeight: Appearance.padding.larger * 3

				CustomSlider {
					id: slider

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					enabled: root.enabled
					implicitHeight: parent.implicitHeight
					radius: Appearance.rounding.small
					value: root.value

					onInteraction: v => root.moved(v)
				}
			}
		}
	}
}
