import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	id: root

	required property string name
	property bool shouldBeActive: true

	implicitHeight: 60
	implicitWidth: 200
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0

	CustomText {
		anchors.fill: parent
		font.bold: true
		font.pointSize: Appearance.font.size.large * 2
		text: root.name
		verticalAlignment: Text.AlignVCenter
	}
}
