pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Components
import qs.Config

ItemList {
	id: root

	property int currentId: -1
	property string iconName: "speaker"
	property var nodes: []

	signal selected(node: PwNode)

	last: true
	showList: true

	delegate: Item {
		id: device

		readonly property bool active: device.modelData?.id === root.currentId
		required property int index
		required property PwNode modelData

		anchors.left: root.list.contentItem.left
		anchors.right: root.list.contentItem.right
		implicitHeight: deviceLayout.implicitHeight + deviceLayout.anchors.margins * 2

		StateLayer {
			bottomLeftRadius: device.index === root?.list.count - 1 ? Appearance.rounding.large : radius
			bottomRightRadius: device.index === root?.list.count - 1 ? Appearance.rounding.large : radius
			radius: Appearance.rounding.extraSmall

			onClicked: root.selected(device.modelData)
		}

		RowLayout {
			id: deviceLayout

			anchors.fill: parent
			anchors.leftMargin: Appearance.padding.largeIncreased
			anchors.margins: Appearance.padding.large
			anchors.rightMargin: Appearance.padding.largeIncreased
			spacing: Appearance.spacing.normal

			CustomRect {
				color: device.active ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondaryContainer
				implicitHeight: devIcon.implicitHeight + Appearance.padding.normal * 2
				implicitWidth: implicitHeight
				radius: Appearance.rounding.full

				MaterialIcon {
					id: devIcon

					anchors.centerIn: parent
					color: device.active ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
					fill: device.active ? 1 : 0
					font.pointSize: Appearance.font.size.large
					text: root.iconName

					Behavior on fill {
						Anim {
						}
					}
				}
			}

			CustomText {
				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.smaller
				text: device.modelData?.description || device.modelData?.name || qsTr("Unknown")
			}

			MaterialIcon {
				color: DynamicColors.palette.m3primary
				font.pointSize: Appearance.font.size.large
				opacity: device.active ? 1 : 0
				text: "check"

				Behavior on opacity {
					Anim {
						type: Anim.DefaultEffects
					}
				}
			}
		}
	}
	model: ScriptModel {
		values: [...root.nodes].sort((a, b) => (a.description || a.name || "").localeCompare(b.description || b.name || ""))
	}
}
