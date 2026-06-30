pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Config
import qs.Modules.Settings

VerticalFadeFlickable {
	id: root

	readonly property var groups: {
		const out = [];
		const byPage = ({});
		for (const e of results) {
			const key = e.pageIdx;
			if (byPage[key] === undefined) {
				byPage[key] = {
					"pageIdx": e.pageIdx,
					"page": e.crumbLabels[0],
					"icon": e.crumbIcons[0],
					"entries": []
				};
				out.push(byPage[key]);
			}
			byPage[key].entries.push(e);
		}
		return out;
	}
	readonly property var results: {
		if (!searching)
			return [];
		const all = SettingsSearcher.query(search);
		return all;
	}
	required property SettingsState sState
	readonly property string search: sState.searchText
	readonly property bool searching: search.length > 0

	bottomMargin: Appearance.padding.large
	contentHeight: content.implicitHeight
	fadeAmount: 0.1
	topMargin: Appearance.padding.large

	TapHandler {
		onTapped: root.focus = true
	}

	ColumnLayout {
		id: content

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: Appearance.spacing.extraSmall

		Repeater {
			id: list

			model: root.searching ? [] : PageRegistry.pages

			CustomRect {
				id: item

				required property int index
				readonly property bool isCategoryEnd: index === list.model.length - 1 || PageRegistry.pages[index + 1]?.category !== modelData.category
				readonly property bool isCategoryStart: index === 0 || PageRegistry.pages[index - 1]?.category !== modelData.category
				readonly property bool isCurrentPage: index === root.sState.currentPageIdx
				required property var modelData

				Layout.fillWidth: true
				Layout.topMargin: index !== 0 && isCategoryStart ? Appearance.spacing.small : 0
				bottomLeftRadius: stateLayer.pressed ? Appearance.rounding.medium : isCurrentPage ? Appearance.rounding.large : isCategoryEnd ? Appearance.rounding.normal : Appearance.rounding.extraSmall
				bottomRightRadius: stateLayer.pressed ? Appearance.rounding.medium : isCurrentPage ? Appearance.rounding.large : isCategoryEnd ? Appearance.rounding.normal : Appearance.rounding.extraSmall
				color: isCurrentPage ? DynamicColors.palette.m3secondaryContainer : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
				implicitHeight: {
					const h = layout.implicitHeight + layout.anchors.margins * 2;
					return h % 2 === 0 ? h : h + 1;
				}
				topLeftRadius: stateLayer.pressed ? Appearance.rounding.medium : isCurrentPage ? Appearance.rounding.large : isCategoryStart ? Appearance.rounding.normal : Appearance.rounding.extraSmall
				topRightRadius: stateLayer.pressed ? Appearance.rounding.medium : isCurrentPage ? Appearance.rounding.large : isCategoryStart ? Appearance.rounding.normal : Appearance.rounding.extraSmall

				RadiusBehavior on bottomLeftRadius {
				}
				RadiusBehavior on bottomRightRadius {
				}
				RadiusBehavior on topLeftRadius {
				}
				RadiusBehavior on topRightRadius {
				}

				StateLayer {
					id: stateLayer

					anchors.fill: parent
					bottomLeftRadius: parent.bottomLeftRadius
					bottomRightRadius: parent.bottomRightRadius
					topLeftRadius: parent.topLeftRadius
					topRightRadius: parent.topRightRadius

					onClicked: root.sState.currentPageIdx = item.index
				}

				RowLayout {
					id: layout

					anchors.fill: parent
					anchors.margins: Appearance.padding.large
					spacing: Appearance.spacing.small

					CustomRect {
						Layout.bottomMargin: -1
						Layout.fillHeight: true
						Layout.topMargin: -1
						color: item.isCurrentPage ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondaryContainer
						implicitWidth: height
						radius: Appearance.rounding.full

						MaterialIcon {
							anchors.centerIn: parent
							anchors.verticalCenterOffset: 1
							color: item.isCurrentPage ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
							fill: item.modelData.noFill ? 0 : 1
							font.pointSize: Appearance.font.size.large
							grade: 25
							text: item.modelData.icon
						}
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 0

						CustomText {
							Layout.fillWidth: true
							elide: Text.ElideRight
							text: item.modelData.name
						}

						CustomText {
							Layout.fillWidth: true
							color: DynamicColors.palette.m3onSurfaceVariant
							elide: Text.ElideRight
							text: item.modelData.description
						}
					}
				}
			}
		}

		ListView {
			id: resultList

			Layout.fillWidth: true
			cacheBuffer: 10000
			implicitHeight: contentHeight
			interactive: false
			spacing: Appearance.padding.large

			delegate: ColumnLayout {
				id: group

				required property int index
				required property var modelData

				spacing: Appearance.spacing.small
				width: resultList.width

				RowLayout {
					Layout.fillWidth: true
					Layout.leftMargin: Appearance.padding.small
					spacing: Appearance.spacing.small

					MaterialIcon {
						color: DynamicColors.palette.m3primary
						font.pointSize: Appearance.font.size.small
						text: group.modelData.icon
					}

					CustomText {
						Layout.fillWidth: true
						color: DynamicColors.palette.m3primary
						elide: Text.ElideRight
						font.pointSize: Appearance.font.size.large
						text: group.modelData.page
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 0

					Repeater {
						model: group.modelData.entries

						CustomRect {
							id: result

							required property int index
							readonly property bool isFirst: index === 0
							readonly property bool isLast: index === group.modelData.entries.length - 1
							required property var modelData

							Layout.fillWidth: true
							bottomLeftRadius: isLast ? Appearance.rounding.large : 0
							bottomRightRadius: isLast ? Appearance.rounding.large : 0
							color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
							implicitHeight: {
								const h = resultLayout.implicitHeight + resultLayout.anchors.margins * 2;
								return h % 2 === 0 ? h : h + 1;
							}
							topLeftRadius: isFirst ? Appearance.rounding.large : 0
							topRightRadius: isFirst ? Appearance.rounding.large : 0

							CustomRect {
								anchors.bottom: parent.bottom
								anchors.left: parent.left
								anchors.leftMargin: Appearance.padding.large
								anchors.right: parent.right
								anchors.rightMargin: Appearance.padding.large
								color: Qt.alpha(DynamicColors.palette.m3outlineVariant, 0.5)
								implicitHeight: 1
								visible: !result.isLast
							}

							ColumnLayout {
								id: resultLayout

								anchors.fill: parent
								anchors.margins: Appearance.padding.large
								anchors.rightMargin: result.modelData.togglePath ? toggle.width + Appearance.padding.large * 2 : Appearance.padding.large
								spacing: Appearance.spacing.small / 2

								CustomText {
									Layout.fillWidth: true
									color: DynamicColors.palette.m3onSurfaceVariant
									elide: Text.ElideRight
									font.pointSize: Appearance.font.size.small
									text: {
										const labels = result.modelData.crumbLabels.slice(1);
										const section = result.modelData.section;
										const parts = section && section !== labels[labels.length - 1] ? labels.concat(section) : labels;
										return parts.join("  \u203a  ");
									}
									visible: text.length > 0
								}

								CustomText {
									Layout.fillWidth: true
									color: DynamicColors.palette.m3onSurface
									elide: Text.ElideRight
									font.pointSize: Appearance.font.size.medium
									text: SettingsSearcher.highlight(result.modelData.title, root.search, DynamicColors.palette.m3primary)
									textFormat: Text.StyledText
								}

								CustomText {
									Layout.fillWidth: true
									color: DynamicColors.palette.m3outline
									elide: Text.ElideRight
									font.pointSize: Appearance.font.size.small
									text: SettingsSearcher.highlight(result.modelData.subtext, root.search, DynamicColors.palette.m3primary)
									textFormat: Text.StyledText
									visible: result.modelData.subtext.length > 0
								}
							}

							StateLayer {
								anchors.fill: parent
								radius: 0
								z: 1

								onClicked: {
									root.sState.jumpToSetting(result.modelData.pageIdx, result.modelData.subPath, result.modelData.anchor);
								}
							}

							CustomSwitch {
								id: toggle

								anchors.right: parent.right
								anchors.rightMargin: Appearance.padding.large
								anchors.verticalCenter: parent.verticalCenter
								cLayer: 3
								checked: result.modelData.toggleValue
								scale: 0.85
								transformOrigin: Item.Right
								visible: result.modelData.togglePath
								z: 2

								onToggled: result.modelData.setToggle(checked)
							}
						}
					}
				}
			}
			model: ScriptModel {
				objectProp: "pageIdx"
				values: root.groups
			}
		}

		CustomText {
			Layout.fillWidth: true
			Layout.topMargin: Appearance.padding.large
			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.medium
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("No matching settings")
			visible: root.searching && root.results.length === 0
		}
	}

	component RadiusBehavior: Behavior {
		Anim {
			type: Anim.DefaultEffects
		}
	}
}
