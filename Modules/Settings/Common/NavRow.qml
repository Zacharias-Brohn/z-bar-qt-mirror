pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ConnectedRect {
	id: root

	property alias icon: icon.text
	property alias status: status.text
	property alias text: label.text

	signal clicked

	Layout.fillWidth: true
	implicitHeight: navLayout.implicitHeight + navLayout.anchors.margins * 2

	StateLayer {
		onClicked: root.clicked()
	}

	RowLayout {
		id: navLayout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.largeIncreased
		anchors.margins: Appearance.padding.normal
		anchors.rightMargin: Appearance.padding.largeIncreased
		spacing: Appearance.spacing.normal

		MaterialIcon {
			id: icon

			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.large
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
				id: status

				Layout.fillWidth: true
				animate: true
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				visible: text
			}
		}

		MaterialIcon {
			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.medium
			text: "chevron_right"
		}
	}
}
