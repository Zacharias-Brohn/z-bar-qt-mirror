pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Config
import qs.Helpers

Item {
	id: root

	required property Item content

	signal settingSelected(string category, string section, string settingName)

	// Function to select category by key
	function selectCategory(categoryKey: string) {
		for (let i = 0; i < appearanceCats.count; i++) {
			if (appearanceCats.get(i).key === categoryKey) {
				clayout.currentIndex = i;
				root.content.currentCategory = categoryKey;
				return;
			}
		}
		for (let i = 0; i < systemCats.count; i++) {
			if (systemCats.get(i).key === categoryKey) {
				clayout.currentIndex = i;
				root.content.currentCategory = categoryKey;
				return;
			}
		}
		for (let i = 0; i < panelCats.count; i++) {
			if (panelCats.get(i).key === categoryKey) {
				clayout.currentIndex = i;
				root.content.currentCategory = categoryKey;
				return;
			}
		}
	}

	implicitHeight: searchBar.implicitHeight + Appearance.spacing.smaller + clayout.contentHeight + clayout.anchors.margins * 2
	implicitWidth: clayout.contentWidth + clayout.anchors.margins * 2

	ListModel {
		id: appearanceCats

		ListElement {
			icon: "wallpaper"
			key: "wallpaper"
			name: "Wallpaper"
		}

		ListElement {
			icon: "screenshot_region"
			key: "screenshot"
			name: "Screenshot"
		}

		ListElement {
			icon: "colors"
			key: "appearance"
			name: "Appearance"
		}
	}

	ListModel {
		id: systemCats

		ListElement {
			icon: "settings"
			key: "general"
			name: "General"
		}

		ListElement {
			icon: "build_circle"
			key: "services"
			name: "Services"
		}

		ListElement {
			icon: "notifications"
			key: "notifications"
			name: "Notifications"
		}

		ListElement {
			icon: "handyman"
			key: "utilities"
			name: "Utilities"
		}

		ListElement {
			icon: "cached"
			key: "updates"
			name: "Updates"
		}
	}

	ListModel {
		id: panelCats

		ListElement {
			icon: "settop_component"
			key: "bar"
			name: "Bar"
		}

		ListElement {
			icon: "lock"
			key: "lockscreen"
			name: "Lockscreen"
		}

		ListElement {
			icon: "view_sidebar"
			key: "sidebar"
			name: "Sidebar"
		}

		ListElement {
			icon: "dashboard"
			key: "dashboard"
			name: "Dashboard"
		}

		ListElement {
			icon: "display_settings"
			key: "osd"
			name: "On screen display"
		}

		ListElement {
			icon: "rocket_launch"
			key: "launcher"
			name: "Launcher"
		}
	}

	CustomClippingRect {
		anchors.fill: parent
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.normal

		Flickable {
			id: clayout

			anchors.fill: parent
			anchors.margins: Appearance.padding.extraSmall
			contentWidth: contentItem.childrenRect.width
			flickableDirection: Flickable.VerticalFlick

			ColumnLayout {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				spacing: Appearance.spacing.normal

				CustomListView {
					id: sysView

					Layout.fillWidth: true
					Layout.preferredHeight: contentItem.childrenRect.height
					Layout.preferredWidth: contentItem.childrenRect.width
					boundsBehavior: Flickable.StopAtBounds
					highlightFollowsCurrentItem: false
					interactive: false
					model: systemCats
					spacing: 2

					delegate: Category {
						view: sysView
					}
					// highlight: CustomRect {
					// 	color: DynamicColors.palette.m3primary
					// 	implicitHeight: sysView.currentItem?.implicitHeight ?? 0
					// 	implicitWidth: sysView.width
					// 	radius: Appearance.rounding.normal - Appearance.padding.smaller
					// 	y: sysView.currentItem?.y ?? 0
					//
					// 	Behavior on y {
					// 		Anim {
					// 			duration: Appearance.anim.durations.small
					// 			easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					// 		}
					// 	}
					// }
				}

				CustomListView {
					id: panelsView

					Layout.fillWidth: true
					Layout.preferredHeight: contentItem.childrenRect.height
					Layout.preferredWidth: contentItem.childrenRect.width
					boundsBehavior: Flickable.StopAtBounds
					contentWidth: contentItem.childrenRect.width
					highlightFollowsCurrentItem: false
					interactive: false
					model: panelCats
					spacing: 2

					delegate: Category {
						view: panelsView
					}
					// highlight: CustomRect {
					// 	color: DynamicColors.palette.m3primary
					// 	implicitHeight: panelsView.currentItem?.implicitHeight ?? 0
					// 	implicitWidth: panelsView.width
					// 	radius: Appearance.rounding.normal - Appearance.padding.smaller
					// 	y: panelsView.currentItem?.y ?? 0
					//
					// 	Behavior on y {
					// 		Anim {
					// 			duration: Appearance.anim.durations.small
					// 			easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					// 		}
					// 	}
					// }
				}

				CustomListView {
					id: appearanceView

					Layout.fillWidth: true
					Layout.preferredHeight: contentItem.childrenRect.height
					Layout.preferredWidth: contentItem.childrenRect.width
					boundsBehavior: Flickable.StopAtBounds
					contentWidth: contentItem.childrenRect.width
					highlightFollowsCurrentItem: false
					interactive: false
					model: appearanceCats
					spacing: 2

					delegate: Category {
						view: appearanceView
					}
					// highlight: CustomRect {
					// 	color: DynamicColors.palette.m3primary
					// 	implicitHeight: appearanceView.currentItem?.implicitHeight ?? 0
					// 	implicitWidth: appearanceView.width
					// 	radius: Appearance.rounding.normal - Appearance.padding.smaller
					// 	y: appearanceView.currentItem?.y ?? 0
					//
					// 	Behavior on y {
					// 		Anim {
					// 			duration: Appearance.anim.durations.small
					// 			easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					// 		}
					// 	}
					// }
				}
			}
		}
	}

	component Category: CustomRect {
		id: categoryItem

		required property string icon
		required property int index
		required property string key
		required property string name
		required property ListView view

		bottomLeftRadius: key === root.content.currentCategory || index === view.model.count - 1 ? (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.normal - clayout.anchors.margins) : (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.extraSmall)
		bottomRightRadius: key === root.content.currentCategory || index === view.model.count - 1 ? (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.normal - clayout.anchors.margins) : (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.extraSmall)
		color: key === root.content.currentCategory ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 42
		implicitWidth: 256
		topLeftRadius: key === root.content.currentCategory || index === 0 ? (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.normal - clayout.anchors.margins) : (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.extraSmall)
		topRightRadius: key === root.content.currentCategory || index === 0 ? (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.normal - clayout.anchors.margins) : (layer.pressed ? (Appearance.rounding.extraSmall / 2) : Appearance.rounding.extraSmall)

		Behavior on bottomLeftRadius {
			Anim {
				type: Anim.FastEffects
			}
		}
		Behavior on bottomRightRadius {
			Anim {
				type: Anim.FastEffects
			}
		}
		Behavior on topLeftRadius {
			Anim {
				type: Anim.FastEffects
			}
		}
		Behavior on topRightRadius {
			Anim {
				type: Anim.FastEffects
			}
		}

		RowLayout {
			id: layout

			anchors.left: parent.left
			anchors.margins: Appearance.padding.smaller
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter

			MaterialIcon {
				id: icon

				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillHeight: true
				Layout.preferredWidth: icon.contentWidth
				color: categoryItem.key === root.content.currentCategory ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				fill: categoryItem.key === root.content.currentCategory ? 1 : 0
				font.pointSize: Appearance.font.size.small * 2
				text: categoryItem.icon
				verticalAlignment: Text.AlignVCenter

				Behavior on fill {
					Anim {
					}
				}
			}

			CustomText {
				id: text

				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.leftMargin: Appearance.spacing.normal
				color: categoryItem.key === root.content.currentCategory ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				text: categoryItem.name
				verticalAlignment: Text.AlignVCenter
			}
		}

		StateLayer {
			id: layer

			color: categoryItem.key === root.content.currentCategory ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

			onClicked: {
				root.content.currentCategory = categoryItem.key;
				categoryItem.view.currentIndex = categoryItem.index;
			}
		}
	}
}
