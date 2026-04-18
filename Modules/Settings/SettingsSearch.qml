pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Components
import qs.Config
import "../../scripts/fuzzysort.js" as Fuzzy
import "./SettingsIndex.mjs" as SettingsIndex

Item {
	id: root

	property alias text: searchField.text

	signal settingSelected(string category, string section, string settingName)

	function close() {
		searchField.text = "";
		searchField.focus = false;
		popup.close();
	}

	function search(query) {
		resultsModel.clear();

		if (!query || query.trim() === "") {
			popup.close();
			return;
		}

		const results = SettingsIndex.searchSettings(query, Fuzzy);

		for (const result of results.slice(0, 10)) {
			resultsModel.append({
				name: result.name,
				category: result.category,
				categoryName: result.categoryName,
				section: result.section,
				matchType: result.matchType
			});
		}

		if (resultsModel.count > 0) {
			popup.open();
		} else {
			popup.close();
		}
	}

	implicitHeight: searchContainer.implicitHeight
	implicitWidth: 200

	Shortcut {
		sequence: "/"
		onActivated: searchField.forceActiveFocus()
	}

	Component.onCompleted: console.log(root.height)

	ListModel {
		id: resultsModel
	}

	CustomRect {
		id: searchContainer

		anchors.fill: parent
		color: DynamicColors.tPalette.m3surfaceContainerHigh
		implicitHeight: searchRow.implicitHeight + Appearance.padding.small * 2
		radius: Appearance.rounding.full

		RowLayout {
			id: searchRow

			anchors.fill: parent
			anchors.leftMargin: Appearance.padding.normal
			anchors.rightMargin: Appearance.padding.small
			spacing: Appearance.spacing.small

			MaterialIcon {
				Layout.alignment: Qt.AlignVCenter
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.larger
				text: "search"
			}

			CustomTextField {
				id: searchField

				Layout.alignment: Qt.AlignVCenter
				Layout.fillWidth: true
				font.pointSize: Appearance.font.size.small
				placeholderText: qsTr("Search settings...")

				Keys.onDownPressed: {
					if (popup.visible && resultsList.count > 0) {
						resultsList.currentIndex = Math.min(resultsList.currentIndex + 1, resultsList.count - 1);
					}
				}
				Keys.onEscapePressed: {
					root.close();
				}
				Keys.onReturnPressed: {
					if (popup.visible && resultsList.currentIndex >= 0) {
						const item = resultsModel.get(resultsList.currentIndex);
						root.settingSelected(item.category, item.section, item.name);
						root.close();
					}
				}
				Keys.onUpPressed: {
					if (popup.visible && resultsList.count > 0) {
						resultsList.currentIndex = Math.max(resultsList.currentIndex - 1, 0);
					}
				}
				onTextChanged: {
					searchTimer.restart();
				}
			}

			// Clear button
			IconButton {
				Layout.alignment: Qt.AlignVCenter
				font.pointSize: Appearance.font.size.larger
				icon: "close"
				opacity: searchField.text.length > 0 ? 1 : 0

				Behavior on opacity {
					Anim {
						duration: Appearance.anim.durations.small
					}
				}

				onClicked: {
					root.close();
				}
			}
		}
	}

	// Debounce timer for search
	Timer {
		id: searchTimer

		interval: 150

		onTriggered: root.search(searchField.text)
	}

	// Results dropdown
	Popup {
		id: popup

		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
		implicitHeight: Math.min(resultsList.contentHeight + Appearance.padding.small * 2 + 10, (55 + Appearance.spacing.smaller) * 5 - Appearance.spacing.smaller + 10 + Appearance.padding.small * 2)
		implicitWidth: root.width + Appearance.padding.small * 2
		modal: false
		padding: 0
		x: root.width / 2 - popup.width / 2
		y: searchContainer.height + Appearance.spacing.small - 5

		background: Item {
		}
		contentItem: Item {
			property alias view: resultsList

			Elevation {
				id: popupShadow

				anchors.centerIn: parent
				height: popup.implicitHeight - 10
				level: 2
				radius: Appearance.rounding.normal
				width: popup.implicitWidth - 10

				CustomRect {
					anchors.fill: parent
					color: DynamicColors.palette.m3surfaceContainer
					radius: Appearance.rounding.normal

					CustomListView {
						id: resultsList

						anchors.fill: parent
						anchors.margins: Appearance.padding.small
						clip: true
						currentIndex: 0
						highlightFollowsCurrentItem: false
						highlightRangeMode: ListView.ApplyRange
						model: resultsModel
						preferredHighlightBegin: 0
						preferredHighlightEnd: height
						spacing: Appearance.spacing.smaller

						delegate: SearchResultItem {
							required property string category
							required property string categoryName
							required property int index
							required property string matchType
							required property string name
							required property string section

							highlighted: index === resultsList.currentIndex
							width: resultsList.width

							onClicked: {
								root.settingSelected(category, section, name);
								root.close();
							}
						}
						highlight: CustomRect {
							color: DynamicColors.palette.m3primary
							implicitHeight: resultsList.currentItem?.implicitHeight ?? 0
							implicitWidth: resultsList.width
							radius: Appearance.rounding.normal - Appearance.padding.smaller
							y: resultsList.currentItem?.y ?? 0

							Behavior on y {
								Anim {
									duration: Appearance.anim.durations.small
									easing.bezierCurve: Appearance.anim.curves.expressiveEffects
								}
							}
						}
					}
				}
			}
		}
		enter: Transition {
			Anim {
				duration: Appearance.anim.durations.small
				from: 0
				property: "opacity"
				to: 1
			}

			Anim {
				duration: Appearance.anim.durations.small
				from: 0.95
				property: "scale"
				to: 1.0
			}
		}
		exit: Transition {
			Anim {
				duration: Appearance.anim.durations.smaller
				from: 1
				property: "opacity"
				to: 0
			}
		}
	}

	// Search result item component
	component SearchResultItem: CustomRect {
		id: resultItem

		property bool highlighted: false

		signal clicked

		implicitHeight: 45 + Appearance.padding.small * 2
		radius: Appearance.rounding.small

		ColumnLayout {
			id: resultLayout

			anchors.left: parent.left
			anchors.margins: Appearance.padding.small
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 2

			// Setting name
			CustomText {
				Layout.fillWidth: true
				color: highlighted ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				font.weight: Font.Medium
				text: resultItem.name
			}

			// Category and section path
			RowLayout {
				Layout.fillWidth: true
				spacing: Appearance.spacing.smaller

				CustomText {
					color: highlighted ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.smaller
					opacity: 0.8
					text: resultItem.categoryName
				}

				CustomText {
					color: highlighted ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.smaller
					opacity: 0.6
					text: "›"
				}

				CustomText {
					Layout.fillWidth: true
					color: highlighted ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurfaceVariant
					elide: Text.ElideRight
					font.pointSize: Appearance.font.size.smaller
					opacity: 0.8
					text: resultItem.section
				}
			}
		}

		StateLayer {
			onClicked: resultItem.clicked()
		}
	}
}
