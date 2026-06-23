import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Config
import qs.Helpers
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	readonly property DesktopEntry app: sState.selectedApp
	readonly property bool favoriteByRegex: app && matchedByRegex(Config.launcher.favoriteApps, app.id)
	readonly property bool hiddenByRegex: app && matchedByRegex(Config.launcher.hiddenApps, app.id)

	function isRegexEntry(s: string): bool {
		return /^\^.*\$$/.test(s);
	}

	function matchedByRegex(filterList: list<string>, id: string): bool {
		return filterList.some(f => isRegexEntry(f) && new RegExp(f).test(id));
	}

	isSubPage: true
	title: qsTr("App info")

	onAppChanged: {
		// Auto close when app lost
		if (!app)
			sState.closeSubPage();
	}

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Header
		RowLayout {
			Layout.bottomMargin: Appearance.spacing.large
			Layout.fillWidth: true
			Layout.leftMargin: Appearance.padding.small
			spacing: Appearance.spacing.large

			IconImage {
				asynchronous: true
				implicitSize: Math.round(Appearance.font.size.large * 3)
				source: Quickshell.iconPath(root.app?.icon, "image-missing")
			}

			ColumnLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.extraSmall / 2

				CustomText {
					Layout.fillWidth: true
					font.pointSize: Appearance.font.size.medium
					text: root.app?.name ?? ""
					wrapMode: Text.WordWrap
				}

				CustomText {
					Layout.fillWidth: true
					color: DynamicColors.palette.m3outline
					font.pointSize: Appearance.font.size.small
					text: (root.app?.comment || root.app?.genericName) ?? ""
					visible: text
					wrapMode: Text.WordWrap
				}
			}
		}

		// Launcher
		SectionHeader {
			first: true
			text: qsTr("Launcher")
		}

		ToggleRow {
			checked: root.app && Strings.testRegexList(Config.launcher.favoriteApps, root.app.id)
			enabled: !root.favoriteByRegex
			first: true
			subtext: root.favoriteByRegex ? qsTr("Matched by a regex in favoriteApps — edit the config file to change") : qsTr("Pin to the top of the launcher")
			text: qsTr("Favorite")

			onToggled: {
				const apps = Config.launcher.favoriteApps;
				Config.launcher.favoriteApps = checked ? [...apps, root.app.id] : apps.filter(a => a !== root.app.id);
			}
		}

		ToggleRow {
			checked: root.app && Strings.testRegexList(Config.launcher.hiddenApps, root.app.id)
			enabled: !root.hiddenByRegex
			last: true
			subtext: root.hiddenByRegex ? qsTr("Matched by a regex in hiddenApps — edit the config file to change") : qsTr("Hide from the launcher")
			text: qsTr("Hidden")

			onToggled: {
				const apps = Config.launcher.hiddenApps;
				Config.launcher.hiddenApps = checked ? [...apps, root.app.id] : apps.filter(a => a !== root.app.id);
			}
		}

		// Details
		SectionHeader {
			text: qsTr("Details")
		}

		WrapInfoRow {
			id: appId

			first: true
			label: qsTr("App ID")
			labelComp.Layout.preferredWidth: Math.max(labelComp.implicitWidth, command.labelComp.implicitWidth)
			value: root.app?.id ?? ""
		}

		WrapInfoRow {
			id: command

			label: qsTr("Command")
			labelComp.Layout.preferredWidth: Math.max(labelComp.implicitWidth, appId.labelComp.implicitWidth)
			last: true
			value: (root.app?.command ?? []).join(" ")
		}
	}

	component WrapInfoRow: ConnectedRect {
		id: row

		property alias label: label.text
		readonly property alias labelComp: label
		property alias value: value.text

		Layout.fillWidth: true
		implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins * 2

		RowLayout {
			id: rowLayout

			anchors.fill: parent
			anchors.leftMargin: Appearance.padding.largeIncreased
			anchors.margins: Appearance.padding.normal
			anchors.rightMargin: Appearance.padding.largeIncreased
			spacing: Appearance.spacing.small

			CustomText {
				id: label

				Layout.alignment: Qt.AlignTop
				font.pointSize: Appearance.font.size.small
			}

			Item {
				Layout.fillWidth: true
			}

			CustomText {
				id: value

				Layout.fillWidth: true
				Layout.maximumWidth: implicitWidth + 1 // Whyyyyyyyyy
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.small
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
		}
	}
}
