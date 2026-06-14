pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Text {
	id: root

	property bool animate: false
	property int animateDuration: 400
	property real animateFrom: 0
	property string animateProp: "scale"
	property real animateTo: 1

	color: DynamicColors.palette.m3onSurface
	font.family: Appearance.font.family.sans
	font.pointSize: Appearance.font.size.normal
	linkColor: DynamicColors.palette.m3onPrimaryFixedVariant
	renderType: Text.NativeRendering
	textFormat: Text.PlainText

	Behavior on color {
		CAnim {
		}
	}
	Behavior on text {
		enabled: root.animate

		SequentialAnimation {
			Anim {
				property: root.animateProp
				target: root
				to: root.animateFrom
				type: Anim.FastEffects
			}

			PropertyAction {
			}

			Anim {
				property: root.animateProp
				target: root
				to: root.animateTo
				type: Anim.DefaultEffects
			}
		}
	}
}
