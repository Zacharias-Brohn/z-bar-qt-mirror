import QtQuick
import qs.Config

NumberAnimation {
	duration: Appearance.anim.durations.normal
	easing.bezierCurve: Appearance.anim.curves.standard
	easing.type: Easing.BezierSpline
}
