import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Config
import qs.Drawers

ConnectedRect {
	id: root

	default required property Item content
	property alias icon: icon.text
	property bool keepPopupAsChild
	readonly property alias popup: popup
	property alias status: status.text
	property alias text: label.text

	Layout.fillWidth: true
	implicitHeight: navLayout.implicitHeight + navLayout.anchors.margins * 2

	StateLayer {
		id: stateLayer

		manualHoverOverride: popup.hovered && !popup.open

		onClicked: popup.open = true
	}

	RowLayout {
		id: navLayout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.largeIncreased
		anchors.margins: Appearance.padding.normal
		anchors.rightMargin: Appearance.padding.largeIncreased
		spacing: Appearance.spacing.normal

		MaterialIcon {
			id: icon

			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.larger
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			CustomText {
				id: label

				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
			}

			CustomText {
				id: status

				Layout.fillWidth: true
				animate: true
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				visible: text
			}
		}

		Item {
			id: triggerArea

			implicitHeight: popup.implicitHeight
			implicitWidth: popup.implicitWidth

			TransformWatcher {
				id: tWatcher

				a: area.parent
				b: triggerArea
			}

			MouseArea {
				id: area

				anchors.fill: parent
				cursorShape: undefined
				enabled: popup.open
				hoverEnabled: true
				parent: {
					if (root.keepPopupAsChild)
						return triggerArea;

					const win = QsWindow.window;
					const contentWin = win as Windows; // If inside the drawer content window, put it inside the interaction wrapper so hover works
					return contentWin ? contentWin.interactionWrapper : (win as QsWindow).contentItem;
				}
				z: popup.animDriver > 0 ? 1 : 0

				onClicked: popup.open = false

				BlobPopup {
					id: popup

					color: open || hovered || stateLayer.containsMouse ? DynamicColors.palette.m3secondaryContainer : DynamicColors.palette.m3surfaceContainerHighest
					content: root.content
					hoverOverride: stateLayer.containsMouse
					padding: Appearance.padding.small
					pressOverride: stateLayer.pressed
					x: {
						tWatcher.transform;
						return triggerArea.mapToItem(area.parent, 0, 0).x;
					}
					y: {
						tWatcher.transform;
						return triggerArea.mapToItem(area.parent, 0, 0).y;
					}
				}
			}
		}
	}
}
