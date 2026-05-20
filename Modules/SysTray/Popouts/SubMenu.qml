pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Components
import qs.Modules
import qs.Config

Column {
	id: menu

	property int biggestWidth: 0
	required property QsMenuHandle handle
	required property int level
	required property PopoutState popouts
	required property ShellScreen screen
	property bool shown: true

	height: childrenRect.height
	opacity: shown ? 1 : 0
	padding: 0
	scale: shown ? 1 : 0.8
	spacing: 4
	width: biggestWidth

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}

	QsMenuOpener {
		id: menuOpener

		menu: menu.handle
	}

	Repeater {
		model: menuOpener.children

		CustomRect {
			id: item

			required property int index
			required property QsMenuEntry modelData

			color: modelData.isSeparator ? DynamicColors.palette.m3outlineVariant : "transparent"
			implicitHeight: modelData.isSeparator ? 1 : children.implicitHeight
			implicitWidth: menu.biggestWidth
			radius: Appearance.rounding.full
			visible: index !== (menuOpener.children.values.length - 1) ? true : (modelData.isSeparator ? false : true)

			Loader {
				id: children

				active: !item.modelData.isSeparator
				anchors.left: parent.left
				anchors.right: parent.right
				asynchronous: true

				sourceComponent: Item {
					implicitHeight: 30

					StateLayer {
						function onClicked(): void {
							const entry = item.modelData;
							if (entry.hasChildren) {
								menu.popouts.pushSubmenu(menu.level, entry, item, menu.biggestWidth);
							} else {
								entry.triggered();
								menu.popouts.hasCurrent = false;
							}
						}

						disabled: !item.modelData.enabled
						radius: item.radius
					}

					Loader {
						id: icon

						active: item.modelData.icon !== ""
						anchors.right: parent.right
						anchors.rightMargin: 10
						anchors.verticalCenter: parent.verticalCenter
						asynchronous: true

						sourceComponent: Item {
							implicitHeight: label.implicitHeight
							implicitWidth: label.implicitHeight

							IconImage {
								id: iconImage

								implicitSize: parent.implicitHeight
								source: item.modelData.icon
								visible: false
							}

							MultiEffect {
								anchors.fill: iconImage
								colorization: 1.0
								colorizationColor: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
								source: iconImage
							}
						}
					}

					CustomText {
						id: label

						anchors.left: parent.left
						anchors.leftMargin: 10
						anchors.verticalCenter: parent.verticalCenter
						color: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
						text: labelMetrics.elidedText
					}

					TextMetrics {
						id: labelMetrics

						font.family: label.font.family
						font.pointSize: label.font.pointSize
						text: item.modelData.text

						Component.onCompleted: {
							var biggestWidth = menu.biggestWidth;
							var currentWidth = labelMetrics.width + (item.modelData.icon ?? "" ? 30 : 0) + (item.modelData.hasChildren ? 30 : 0) + 20;
							if (currentWidth > biggestWidth) {
								menu.biggestWidth = currentWidth;
							}
						}
					}

					Loader {
						id: expand

						active: item.modelData.hasChildren
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						asynchronous: true

						sourceComponent: MaterialIcon {
							color: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
							text: "chevron_right"
						}
					}
				}
			}
		}
	}
}
