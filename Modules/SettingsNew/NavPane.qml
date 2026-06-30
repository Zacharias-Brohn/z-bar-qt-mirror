import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules.SettingsNew.NavPane
import qs.Config

ColumnLayout {
	id: root

	required property SettingsState sState

	spacing: Appearance.spacing.large

	SearchBar {
		id: searchField

		Layout.fillWidth: true
		bg.border.color: DynamicColors.palette.m3outlineVariant
		bg.color: DynamicColors.tPalette.m3surfaceContainerLowest
		clearIcon.font.pointSize: Appearance.font.size.large
		clearIcon.padding: Appearance.padding.extraSmall
		font.pointSize: Appearance.font.size.normal
		placeholderText: qsTr("Search settings")
		searchIcon.anchors.leftMargin: Appearance.padding.largeIncreased
		searchIcon.font.pointSize: Appearance.font.size.large

		Behavior on bg.border.color {
			CAnim {
			}
		}

		Binding {
			property: "searchOpen"
			target: root.sState
			value: searchField.text.length > 0
		}
	}

	NavLocations {
		Layout.bottomMargin: -bottomMargin
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.topMargin: -topMargin
		sState: root.sState
	}
}
