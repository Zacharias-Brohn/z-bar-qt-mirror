pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components

Item {
	id: root

	required property string name
	required property var object
	property alias row: row
	required property string setting
	property bool shouldBeActive: true
	required property list<var> stringList

	signal optionSet(option: string)

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? row.height : 0
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	visible: opacity > 0

	Behavior on opacity {
		Anim {
		}
	}
	Behavior on scale {
		Anim {
		}
	}
	Behavior on y {
		Anim {
		}
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		CustomText {
			id: text

			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomClippingRect {
			Layout.preferredHeight: 42 * 6 + Appearance.padding.normal * 2 + Appearance.spacing.small * 5
			Layout.preferredWidth: 500
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: (21 + Appearance.padding.normal) * Appearance.rounding.scale

			CustomRect {
				id: searchBox

				anchors.left: parent.left
				anchors.margins: Appearance.padding.normal
				anchors.right: parent.right
				anchors.top: parent.top
				color: DynamicColors.tPalette.m3surfaceContainer
				implicitHeight: 42
				radius: Appearance.rounding.full

				MaterialIcon {
					id: searchIcon

					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.leftMargin: Appearance.padding.large
					anchors.top: parent.top
					font.pointSize: Appearance.font.size.large
					text: "search"
					verticalAlignment: Text.AlignVCenter
				}

				CustomTextField {
					id: textSearch

					anchors.left: searchIcon.right
					anchors.leftMargin: Appearance.spacing.small
					anchors.right: parent.right
					anchors.rightMargin: Appearance.spacing.normal
					anchors.verticalCenter: parent.verticalCenter
					placeholderText: "Search..."
				}
			}

			CustomClippingRect {
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.margins: Appearance.padding.normal
				anchors.right: parent.right
				anchors.top: searchBox.bottom
				bottomLeftRadius: 21
				bottomRightRadius: 21

				CustomListView {
					anchors.fill: parent
					clip: true
					spacing: Appearance.spacing.small

					delegate: CustomRect {
						id: delegate

						required property string modelData

						anchors.left: parent.left
						anchors.right: parent.right
						implicitHeight: 42
						radius: Appearance.rounding.smallest

						CustomText {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							text: modelData
							verticalAlignment: Text.AlignVCenter
						}

						MaterialIcon {
							anchors.fill: parent
							anchors.rightMargin: Appearance.padding.normal
							color: DynamicColors.palette.m3primary
							font.pointSize: Appearance.font.size.large
							horizontalAlignment: Text.AlignRight
							text: "check_circle"
							verticalAlignment: Text.AlignVCenter
							visible: root.object[root.setting] === delegate.modelData
						}

						StateLayer {
							onClicked: {
								root.object[root.setting] = delegate.modelData;
								root.optionSet(delegate.modelData);
								Config.save();
							}
						}
					}
					model: ScriptModel {
						values: {
							const values = root.stringList;
							const search = textSearch.text;
							var regex = new RegExp(search, "i");

							return values.filter(n => regex.test(n));
						}
					}
				}
			}
		}
	}
}
