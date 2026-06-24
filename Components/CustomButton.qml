import QtQuick
import QtQuick.Controls
import qs.Config

Button {
	id: control

	property color bgColor: DynamicColors.palette.m3primary
	property int radius: Appearance.rounding.smallest / 2
	property color textColor: DynamicColors.palette.m3onPrimary

	background: CustomRect {
		color: control.bgColor
		opacity: control.enabled ? 1.0 : 0.5
		radius: control.radius
	}
	contentItem: CustomText {
		color: control.textColor
		horizontalAlignment: Text.AlignHCenter
		opacity: control.enabled ? 1.0 : 0.5
		text: control.text
		verticalAlignment: Text.AlignVCenter
	}

	StateLayer {
		radius: control.radius

		onClicked: {
			control.clicked();
		}
	}
}
