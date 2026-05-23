import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	id: root

	property bool shouldBeActive: true

	anchors.left: parent.left
	anchors.right: parent.right
	color: DynamicColors.tPalette.m3outlineVariant
	implicitHeight: shouldBeActive ? 1 : 0
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}
	Behavior on y {
		Anim {
		}
	}
}
