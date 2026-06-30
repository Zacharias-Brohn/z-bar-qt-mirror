import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomSwitch {
	id: root

	readonly property alias bg: bg
	property alias first: bg.first
	property alias last: bg.last
	property string subtext

	Layout.fillWidth: true
	cLayer: 2
	horizontalPadding: Appearance.padding.largeIncreased
	implicitHeight: Math.max(implicitContentHeight, implicitIndicatorHeight) + verticalPadding * 2
	implicitWidth: implicitContentWidth + implicitIndicatorWidth + horizontalPadding * 2
	indicator.anchors.right: right
	indicator.anchors.rightMargin: root.horizontalPadding
	indicator.anchors.verticalCenter: verticalCenter
	verticalPadding: Appearance.padding.normal

	background: ConnectedRect {
		id: bg

		StateLayer {
			id: stateLayer

			manualPressOverride: root.pressed
		}
	}
	contentItem: Item {
		anchors.left: parent.left
		anchors.leftMargin: root.horizontalPadding
		anchors.right: root.indicator.left
		anchors.rightMargin: Appearance.spacing.normal
		implicitHeight: column.implicitHeight
		implicitWidth: column.implicitWidth

		Column {
			id: column

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0

			CustomText {
				id: label

				anchors.left: parent.left
				anchors.right: parent.right
				elide: Text.ElideRight
				font: {
					const f = Qt.font(label.font);
					f.pointSize = Appearance.font.size.smaller;
					return f;
				}
				text: root.text
			}

			CustomText {
				id: subtext

				anchors.left: parent.left
				anchors.right: parent.right
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font: {
					const f = Qt.font(subtext.font);
					f.pointSize = Appearance.font.size.small;
					return f;
				}
				text: root.subtext
				visible: root.subtext
			}
		}
	}

	onPressed: stateLayer.press(stateLayer.mouseX, stateLayer.mouseY)
}
