pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Modules.SettingsNew
import qs.Components
import qs.Config

ColumnLayout {
	id: root

	readonly property int cappedWidth: Math.min(800, width)
	default property Item contentChild
	readonly property alias flickable: flickable
	property bool isSubPage
	required property SettingsState sState
	required property string title

	spacing: Appearance.spacing.large

	MouseArea { // Prevent clicks from reaching flickable
		Layout.bottomMargin: -flickable.topMargin // Extra height to block clicks on flickable top margin

		implicitHeight: header.implicitHeight - Layout.bottomMargin
		implicitWidth: header.implicitWidth
		z: 1

		RowLayout {
			id: header

			spacing: Appearance.spacing.large

			Loader {
				active: root.isSubPage
				asynchronous: true
				visible: active

				sourceComponent: IconButton {
					icon: "arrow_back"
					inactiveColor: DynamicColors.tPalette.m3surfaceContainerHigh
					inactiveOnColor: DynamicColors.palette.m3onSurfaceVariant
					isRound: true
					type: IconButton.Tonal

					onClicked: root.sState.closeSubPage()
				}
			}

			CustomText {
				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.large
				text: root.title
			}
		}
	}

	VerticalFadeFlickable {
		id: flickable

		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.topMargin: -topMargin
		bottomMargin: Appearance.padding.extraLarge
		contentHeight: root.contentChild?.implicitHeight ?? 0
		contentItem.children: [root.contentChild]
		topMargin: Appearance.padding.large
	}
}
