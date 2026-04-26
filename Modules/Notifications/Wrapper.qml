import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	required property Item panels
	required property Item sidebarPanel
	required property var visibilities

	implicitHeight: content.implicitHeight
	implicitWidth: Math.max(sidebarPanel.width, content.implicitWidth)
	visible: height > 0

	Content {
		id: content

		panels: root.panels
		visibilities: root.visibilities
	}
}
