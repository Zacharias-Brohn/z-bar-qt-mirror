import QtQuick
import QtQuick.Layouts
import qs.Modules.SettingsNew.NavPane
import qs.Config

ColumnLayout {
	id: root

	required property SettingsState sState

	spacing: Appearance.spacing.large

	SearchBar {
		Layout.fillWidth: true
		sState: root.sState
	}

	NavLocations {
		Layout.bottomMargin: -bottomMargin
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.topMargin: -topMargin
		sState: root.sState
	}
}
