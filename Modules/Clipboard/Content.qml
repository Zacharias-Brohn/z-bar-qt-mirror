pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property ShellScreen screen
	required property PersistentProperties visibilities

	implicitHeight: screen.height / 2
	implicitWidth: 500

	Component.onCompleted: {
		if (!ClipHistory.entries.length > 0)
			ClipHistory.refresh();
		searchField.forceActiveFocus();
	}

	CustomClippingRect {
		id: search

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 50
		radius: Appearance.rounding.full

		MaterialIcon {
			id: searchIcon

			anchors.left: parent.left
			anchors.margins: Appearance.padding.large
			anchors.verticalCenter: parent.verticalCenter
			text: "search"
		}

		CustomTextField {
			id: searchField

			anchors.bottom: parent.bottom
			anchors.left: searchIcon.right
			anchors.leftMargin: Appearance.spacing.small
			anchors.right: parent.right
			anchors.top: parent.top
			color: DynamicColors.palette.m3onSurface
			placeholderText: "Search clipboard history..."
		}
	}

	CustomClippingRect {
		id: entries

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: search.bottom
		anchors.topMargin: Appearance.spacing.normal
		radius: Appearance.rounding.normal

		ListView {
			id: view

			anchors.fill: parent
			spacing: Appearance.spacing.normal

			delegate: RowLayout {
				id: clipItem

				required property string modelData

				height: 50
				width: view.width

				CustomClippingRect {
					id: textRect

					Layout.fillHeight: true
					Layout.fillWidth: true
					// Layout.preferredWidth: implicitWidth + (textLayer.pressed ? 18 : 0)
					// implicitWidth: 250
					radius: textLayer.pressed ? (Appearance.rounding.small / 2) : Appearance.rounding.small

					Behavior on Layout.preferredWidth {
						Anim {
							type: Anim.FastEffects
						}
					}
					Behavior on radius {
						Anim {
							type: Anim.FastEffects
						}
					}

					CustomText {
						id: text

						anchors.left: parent.left
						anchors.margins: Appearance.padding.normal
						anchors.verticalCenter: parent.verticalCenter
						elide: Text.ElideRight
						text: clipItem.modelData
					}

					StateLayer {
						id: textLayer

						onClicked: ClipHistory.copy(clipItem.modelData)
					}
				}

				IconButton {
					Layout.fillHeight: true
					Layout.margins: Appearance.padding.smallest
					Layout.preferredWidth: height
					icon: "content_copy"
					isToggle: false
					// implicitWidth: 30
				}

				IconButton {
					Layout.fillHeight: true
					Layout.margins: Appearance.padding.smallest
					Layout.preferredWidth: height
					icon: "delete"
					inactiveColor: Qt.alpha(DynamicColors.palette.m3error, 0.8)
					inactiveOnColor: DynamicColors.palette.m3onError
					isToggle: false
				}
			}
			model: ScriptModel {
				values: {
					const entries = ClipHistory.entries;
					const search = searchField.text;
					var regex = new RegExp(search, "i");

					return entries.filter(n => regex.test(n));
				}
			}
		}
	}
}
