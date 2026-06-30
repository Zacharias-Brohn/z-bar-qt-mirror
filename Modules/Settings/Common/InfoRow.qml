pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ConnectedRect {
	id: root

	property string icon
	property color iconColor: DynamicColors.palette.m3onSurfaceVariant
	property alias label: label.text
	property Component leadingComponent: icon ? iconComp : null
	property string subtext
	property alias value: value.text

	Layout.fillWidth: true
	implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins * 2

	Component {
		id: iconComp

		MaterialIcon {
			color: root.iconColor
			font.pointSize: Appearance.font.size.small
			text: root.icon
		}
	}

	RowLayout {
		id: rowLayout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.largeIncreased
		anchors.margins: Appearance.padding.larger
		anchors.rightMargin: Appearance.padding.largeIncreased
		spacing: Appearance.spacing.small

		Loader {
			active: root.leadingComponent
			sourceComponent: root.leadingComponent
			visible: root.leadingComponent
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			CustomText {
				id: label

				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
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

		CustomText {
			id: value

			Layout.maximumWidth: root.width / 2
			color: DynamicColors.palette.m3onSurfaceVariant
			elide: Text.ElideRight
			font.pointSize: Appearance.font.size.small
			horizontalAlignment: Text.AlignRight
		}
	}
}
