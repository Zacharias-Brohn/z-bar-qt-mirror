pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Config
import qs.Drawers

MouseArea {
	id: root

	enum Side {
		Top,
		Bottom,
		Left,
		Right
	}

	property MenuItem active: items[0] ?? null
	property int attachSideX: Menu.Right
	property int attachSideY: Menu.Bottom
	required property Item attachTo
	property bool expanded
	property list<MenuItem> items
	property real marginX
	property real marginY
	property int thisSideX: Menu.Right
	property int thisSideY: Menu.Top

	signal itemSelected(item: MenuItem)

	anchors.fill: parent
	cursorShape: undefined
	enabled: expanded
	layer.enabled: opacity < 1
	opacity: expanded ? 1 : 0
	parent: {
		const win = QsWindow.window;
		const contentWin = win as Windows;
		return contentWin ? contentWin.interactionWrapper : (win as QsWindow).contentItem;
	}

	Behavior on opacity {
		Anim {
			type: Anim.DefaultEffects
		}
	}

	onClicked: expanded = false
	onExpandedChanged: {
		const win = QsWindow.window;
		const contentWin = win as Windows;
		if (expanded) {
			contentWin.menuRegion.x = menu.x;
			contentWin.menuRegion.y = menu.y;
			contentWin.menuRegion.width = menu.width;
			contentWin.menuRegion.height = menu.height;
		} else {
			contentWin.menuRegion.x = 0;
			contentWin.menuRegion.y = 0;
			contentWin.menuRegion.width = 0;
			contentWin.menuRegion.height = 0;
		}
	}

	TransformWatcher {
		id: watcher

		a: root.parent
		b: root.attachTo
	}

	Elevation {
		id: menu

		implicitHeight: column.implicitHeight + column.anchors.margins * 2
		implicitWidth: Math.max(200, column.implicitWidth + column.anchors.margins * 2)
		level: 2
		radius: Appearance.rounding.medium
		x: {
			watcher.transform;
			const item = root.attachTo;
			let off = root.attachSideX === Menu.Left ? 0 : item.width;
			if (root.thisSideX === Menu.Right)
				off -= width;
			return item.mapToItem(root.parent, off, 0).x + root.marginX;
		}
		y: {
			watcher.transform;
			const item = root.attachTo;
			let off = root.attachSideY === Menu.Top ? 0 : item.height;
			if (root.thisSideY === Menu.Bottom)
				off -= height;
			return item.mapToItem(root.parent, 0, off).y + root.marginY;
		}

		transform: Scale {
			origin.y: root.thisSideY === Menu.Bottom ? menu.height : 0
			yScale: root.expanded ? 1 : 0.1

			Behavior on yScale {
				Anim {
				}
			}
		}

		CustomRect {
			anchors.fill: parent
			color: DynamicColors.palette.m3surfaceContainerLow
			radius: parent.radius

			ColumnLayout {
				id: column

				anchors.fill: parent
				anchors.margins: Appearance.padding.extraSmall
				spacing: Appearance.spacing.extraSmall

				Repeater {
					id: repeater

					model: root.items

					CustomRect {
						id: item

						readonly property bool active: modelData === root.active
						required property int index
						required property MenuItem modelData

						Layout.fillWidth: true
						color: Qt.alpha(DynamicColors.palette.m3tertiaryContainer, active ? 1 : 0)
						implicitHeight: menuOptionRow.implicitHeight + Appearance.padding.larger * 2
						implicitWidth: menuOptionRow.implicitWidth + Appearance.padding.larger * 2
						radius: Appearance.rounding.small

						Behavior on radius {
							Anim {
							}
						}

						StateLayer {
							color: item.active ? DynamicColors.palette.m3onTertiaryContainer : DynamicColors.palette.m3onSurface
							enabled: root.expanded

							onClicked: {
								root.itemSelected(item.modelData);
								root.active = item.modelData;
								item.modelData.clicked();
								root.expanded = false;
							}
						}

						RowLayout {
							id: menuOptionRow

							anchors.fill: parent
							anchors.margins: Appearance.padding.larger
							spacing: Appearance.spacing.small

							MaterialIcon {
								Layout.alignment: Qt.AlignVCenter
								color: item.active ? DynamicColors.palette.m3onTertiaryContainer : DynamicColors.palette.m3onSurfaceVariant
								text: item.modelData.icon
							}

							CustomText {
								Layout.alignment: Qt.AlignVCenter
								Layout.fillWidth: true
								color: item.active ? DynamicColors.palette.m3onTertiaryContainer : DynamicColors.palette.m3onSurface
								text: item.modelData.text
							}

							Loader {
								Layout.alignment: Qt.AlignVCenter
								active: item.modelData.trailingIcon.length > 0
								asynchronous: true
								visible: active

								sourceComponent: MaterialIcon {
									color: item.active ? DynamicColors.palette.m3onTertiaryContainer : DynamicColors.palette.m3onSurfaceVariant
									text: item.modelData.trailingIcon
								}
							}
						}
					}
				}
			}
		}
	}
}
