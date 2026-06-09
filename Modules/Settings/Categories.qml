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
			const item = appearanceCats.get(i);
			if (item.key === categoryKey) {
				appearanceView.currentIndex = i;
				root.content.setCategory(item.key, item._index);
				return;
			}
		}
		for (let i = 0; i < systemCats.count; i++) {
			const item = systemCats.get(i);
			if (item.key === categoryKey) {
				sysView.currentIndex = i;
				root.content.setCategory(item.key, item._index);
				return;
			}
		}
		for (let i = 0; i < panelCats.count; i++) {
			const item = panelCats.get(i);
			if (item.key === categoryKey) {
				panelsView.currentIndex = i;
				root.content.setCategory(item.key, item._index);
				return;
			}
		}
	}

	implicitHeight: searchBar.implicitHeight + Appearance.spacing.smaller + clayout.contentHeight + clayout.anchors.margins * 2
	implicitWidth: clayout.contentWidth + clayout.anchors.margins * 2

	ListModel {
		id: systemCats

		ListElement {
			_index: 0
			icon: "settings"
			key: "general"
			name: "General"
		}

		ListElement {
			_index: 1
			icon: "build_circle"
			key: "services"
			name: "Services"
		}

		ListElement {
			_index: 2
			icon: "notifications"
			key: "notifications"
			name: "Notifications"
		}

		ListElement {
			_index: 3
			icon: "handyman"
			key: "utilities"
			name: "Utilities"
		}

		ListElement {
			_index: 4
			icon: "cached"
			key: "updates"
			name: "Updates"
		}
	}

	ListModel {
		id: panelCats

		ListElement {
			_index: 5
			icon: "settop_component"
			key: "bar"
			name: "Bar"
		}

		ListElement {
			_index: 6
			icon: "lock"
			key: "lockscreen"
			name: "Lockscreen"
		}

		ListElement {
			_index: 7
			icon: "view_sidebar"
			key: "sidebar"
			name: "Sidebar"
		}

		ListElement {
			_index: 8
			icon: "dashboard"
			key: "dashboard"
			name: "Dashboard"
		}

		ListElement {
			_index: 9
			icon: "display_settings"
			key: "osd"
			name: "On screen display"
		}

		ListElement {
			_index: 10
			icon: "rocket_launch"
			key: "launcher"
			name: "Launcher"
		}
	}

	ListModel {
		id: appearanceCats

		ListElement {
			_index: 11
			icon: "wallpaper"
			key: "wallpaper"
			name: "Wallpaper"
		}

		ListElement {
			_index: 12
			icon: "screenshot_region"
			key: "screenshot"
			name: "Screenshot"
		}

		ListElement {
			_index: 13
			icon: "colors"
			key: "appearance"
			name: "Appearance"
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

		required property int _index
		readonly property bool first: index === 0
		required property string icon
		required property int index
		required property string key
		readonly property bool last: index === view.model.count - 1
		required property string name
		readonly property bool selected: key === root.content.currentCategory
		required property ListView view

		bottomLeftRadius: layer.pressed ? Appearance.rounding.smallest : selected || last ? Appearance.rounding.normal - clayout.anchors.margins : Appearance.rounding.extraSmall
		bottomRightRadius: layer.pressed ? Appearance.rounding.smallest : selected || last ? Appearance.rounding.normal - clayout.anchors.margins : Appearance.rounding.extraSmall
		color: selected ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 50
		implicitWidth: 256
		topLeftRadius: layer.pressed ? Appearance.rounding.smallest : selected || first ? Appearance.rounding.normal - clayout.anchors.margins : Appearance.rounding.extraSmall
		topRightRadius: layer.pressed ? Appearance.rounding.smallest : selected || first ? Appearance.rounding.normal - clayout.anchors.margins : Appearance.rounding.extraSmall

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
				Layout.leftMargin: Appearance.padding.small
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
				root.content.setCategory(categoryItem.key, categoryItem._index);
				categoryItem.view.currentIndex = categoryItem.index;
			}
		}
	}
}
