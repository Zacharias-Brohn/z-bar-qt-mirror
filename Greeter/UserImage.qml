import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
	id: root

	ClippingRectangle {
		anchors.fill: parent
		radius: Appearance.rounding.full

		Image {
			id: userImage

			anchors.fill: parent
			asynchronous: true
			fillMode: Image.PreserveAspectCrop
			source: "/etc/zshell-greeter/images/face"
			sourceSize.height: parent.height
			sourceSize.width: parent.width
		}
	}
}
