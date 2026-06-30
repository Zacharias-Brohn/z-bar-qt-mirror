import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.Modules.Launcher.Services
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules

Item {
	id: root

	required property DesktopEntry modelData
	required property PersistentProperties visibilities

	anchors.left: parent?.left
	anchors.right: parent?.right
	implicitHeight: Config.launcher.sizes.itemHeight

	StateLayer {
		radius: Appearance.rounding.smallest

		onClicked: {
			Apps.launch(root.modelData);
			root.visibilities.launcher = false;
		}
	}

	Item {
		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.larger
		anchors.margins: Appearance.padding.smaller
		anchors.rightMargin: Appearance.padding.larger

		IconImage {
			id: icon

			anchors.verticalCenter: parent.verticalCenter
			implicitSize: parent.height
			source: Quickshell.iconPath(root.modelData?.icon, "image-missing")
		}

		Item {
			anchors.left: icon.right
			anchors.leftMargin: Appearance.spacing.normal
			anchors.verticalCenter: icon.verticalCenter
			implicitHeight: name.implicitHeight + comment.implicitHeight
			implicitWidth: parent.width - icon.width

			CustomText {
				id: name

				font.pointSize: Appearance.font.size.normal
				text: root.modelData?.name ?? ""
			}

			CustomText {
				id: comment

				anchors.top: name.bottom
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				text: (root.modelData?.comment || root.modelData?.genericName || root.modelData?.name) ?? ""
				width: root.width - icon.width - Appearance.rounding.normal * 2
			}
		}

		Loader {
			id: favoriteIcon

			active: root.modelData && Strings.testRegexList(Config.launcher.favoriteApps, root.modelData.id)
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			asynchronous: true

			sourceComponent: MaterialIcon {
				color: DynamicColors.palette.m3primary
				fill: 1
				text: "favorite"
			}
		}
	}
}
