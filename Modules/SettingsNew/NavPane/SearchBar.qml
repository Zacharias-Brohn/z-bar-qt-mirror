import QtQuick
import QtQuick.Layouts
import qs.Modules.SettingsNew
import qs.Components
import qs.Config

CustomRect {
	id: root

	required property SettingsState sState

	border.color: DynamicColors.palette.m3outlineVariant
	color: DynamicColors.tPalette.m3surfaceContainerLowest
	implicitHeight: searchLayout.implicitHeight + Appearance.padding.normal * 2
	radius: Appearance.rounding.full

	Behavior on border.color {
		CAnim {
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.IBeamCursor

		onClicked: searchField.focus = true
	}

	RowLayout {
		id: searchLayout

		anchors.left: parent.left
		anchors.margins: Appearance.padding.large
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.small

		MaterialIcon {
			color: DynamicColors.palette.m3onSurfaceVariant
			text: "search"
		}

		CustomTextField {
			id: searchField

			Layout.fillHeight: true
			Layout.fillWidth: true
			color: DynamicColors.palette.m3onSurfaceVariant
			placeholderText: qsTr("Search settings")
			placeholderTextColor: DynamicColors.palette.m3onSurfaceVariant

			Binding {
				property: "searchOpen"
				target: root.sState
				value: searchField.text.length > 0
			}
		}

		IconButton {
			icon: "close"
			isRound: true
			opacity: searchField.text.length > 0 ? 1 : 0
			padding: Appearance.padding.extraSmall
			type: IconButton.Text

			Behavior on opacity {
				Anim {
					type: Anim.DefaultEffects
				}
			}

			onClicked: searchField.clear()
		}
	}
}
