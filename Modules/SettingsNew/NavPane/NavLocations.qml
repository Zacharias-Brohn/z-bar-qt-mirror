pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules.SettingsNew

VerticalFadeFlickable {
	id: root

	required property SettingsState sState

	bottomMargin: Appearance.padding.large
	contentHeight: content.implicitHeight
	fadeAmount: 0.1
	topMargin: Appearance.padding.large

	ColumnLayout {
		id: content

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: Appearance.spacing.extraSmall

		Repeater {
			id: list

			model: PageRegistry.pages

			CustomRect {
				id: item

				required property int index
				readonly property bool isCategoryEnd: index === list.model.length - 1 || PageRegistry.pages[index + 1].category !== modelData.category
				readonly property bool isCategoryStart: index === 0 || PageRegistry.pages[index - 1].category !== modelData.category
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
	}

	component RadiusBehavior: Behavior {
		Anim {
			type: Anim.DefaultEffects
		}
	}
}
