import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	id: root

	default property alias contentData: layout.data
	property real contentPadding: Appearance.padding.large
	property string sectionId: ""

	anchors.left: parent.left
	anchors.right: parent.right
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.height + contentPadding * 2
	radius: Appearance.rounding.normal - Appearance.padding.extraSmall

	Behavior on implicitHeight {
		Anim {
		}
	}
	Behavior on y {
		Anim {
		}
	}

	Column {
		id: layout

		anchors.left: parent.left
		anchors.margins: root.contentPadding
		anchors.right: parent.right
		anchors.top: parent.top
		// anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.normal

		Behavior on height {
			Anim {
			}
		}
		move: Transition {
			Anim {
				properties: "y"
			}
		}
	}
}
