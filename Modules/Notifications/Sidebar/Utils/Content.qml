import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules.Notifications.Sidebar.Utils.Cards
import qs.Config

Item {
	id: root

	required property Item popouts
	required property PersistentProperties props
	required property var visibilities

	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth

	ColumnLayout {
		id: layout

		anchors.fill: parent
		spacing: 8

		IdleInhibit {
		}

		Record {
			props: root.props
			visibilities: root.visibilities
			z: 1
		}

		Toggles {
			popouts: root.popouts
			visibilities: root.visibilities
		}
	}
}
