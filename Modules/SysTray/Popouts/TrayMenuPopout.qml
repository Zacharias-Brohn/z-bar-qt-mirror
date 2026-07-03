pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import qs.Components
import qs.Modules
import qs.Config

StackView {
	id: root

	readonly property int itemHeight: 30
	readonly property int panelRadius: ((itemHeight / 2) + Appearance.padding.small) * Appearance.rounding.scale
	required property PopoutState popouts
	property int rootWidth: 0
	required property QsMenuHandle trayItem

	implicitHeight: currentItem.isSubMenu ? currentItem.implicitHeight : currentItem.implicitHeight - currentItem.spacing
	implicitWidth: currentItem.implicitWidth

	initialItem: SubMenu {
		handle: root.trayItem
	}
	popEnter: NoAnim {
	}
	popExit: NoAnim {
	}
	pushEnter: NoAnim {
	}
	pushExit: NoAnim {
	}

	Component {
		id: subMenuComp

		SubMenu {
		}
	}

	component NoAnim: Transition {
		NumberAnimation {
			duration: 0
		}
	}
	component SubMenu: ColumnLayout {
		id: menu

		required property QsMenuHandle handle
		property bool isSubMenu
		property bool shown

		opacity: shown ? 1 : 0
		scale: shown ? 1 : 0.8
		spacing: Appearance.spacing.extraSmall

		Behavior on opacity {
			Anim {
			}
		}
		Behavior on scale {
			Anim {
			}
		}

		Component.onCompleted: shown = true
		StackView.onActivating: shown = true
		StackView.onDeactivating: shown = false
		StackView.onRemoved: destroy()

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

				Layout.fillWidth: true
				Layout.leftMargin: modelData.isSeparator ? Appearance.padding.normal : 0
				Layout.rightMargin: modelData.isSeparator ? Appearance.padding.normal : 0
				color: modelData.isSeparator ? DynamicColors.palette.m3outlineVariant : "transparent"
				implicitHeight: modelData.isSeparator ? (visible ? 1 : 0) : childrenLoader.item.implicitHeight
				implicitWidth: childrenLoader.item?.implicitWidth ?? 0
				radius: Appearance.rounding.full
				visible: index !== (menuOpener.children.values.length - 1) ? true : (modelData.isSeparator ? false : true)

				Loader {
					id: childrenLoader

					active: !item.modelData.isSeparator
					anchors.fill: parent
					asynchronous: true

					sourceComponent: Item {
						property int iconWidth: icon.active ? icon.width + Appearance.spacing.normal + icon.anchors.rightMargin : 0

						implicitHeight: root.itemHeight
						implicitWidth: label.width + label.anchors.leftMargin * 2 + iconWidth

						StateLayer {
							enabled: item.modelData.enabled
							radius: item.radius

							onClicked: {
								const entry = item.modelData;
								if (entry.hasChildren) {
									root.push(subMenuComp.createObject(null, {
										handle: entry,
										isSubMenu: true
									}));
								} else {
									item.modelData.triggered();
									root.popouts.hasCurrent = false;
								}
							}
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
							text: item.modelData.text
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

		Loader {
			id: loader

			Layout.fillWidth: true
			Layout.maximumHeight: active ? implicitHeight : 0
			active: menu.isSubMenu
			asynchronous: true

			sourceComponent: Item {
				implicitHeight: 30

				Item {
					anchors.fill: parent
					implicitHeight: 30

					CustomRect {
						anchors.fill: parent
						color: DynamicColors.palette.m3secondaryContainer
						radius: Appearance.rounding.full

						StateLayer {
							color: DynamicColors.palette.m3onSecondaryContainer
							radius: parent.radius

							onClicked: {
								root.pop();
							}
						}
					}

					Row {
						id: back

						anchors.verticalCenter: parent.verticalCenter

						MaterialIcon {
							anchors.verticalCenter: parent.verticalCenter
							color: DynamicColors.palette.m3onSecondaryContainer
							text: "chevron_left"
						}

						CustomText {
							anchors.verticalCenter: parent.verticalCenter
							color: DynamicColors.palette.m3onSecondaryContainer
							text: qsTr("Back")
						}
					}
				}
			}
		}
	}
}
