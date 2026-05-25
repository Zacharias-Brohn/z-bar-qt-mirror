pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

CustomRect {
	id: root

	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	required property string setting
	property bool shouldBeActive: true

	function addAlias() {
		const list = [...root.object[root.setting]];
		list.push({
			from: "",
			to: ""
		});
		root.object[root.setting] = list;
		Config.save();
	}

	function removeAlias(index) {
		const list = [...root.object[root.setting]];
		list.splice(index, 1);
		root.object[root.setting] = list;
		Config.save();
	}

	function updateAlias(index, key, value) {
		const list = [...root.object[root.setting]];
		const entry = [...list[index]];
		entry[key] = value;
		list[index] = entry;
		root.object[root.setting] = list;
		Config.save();
	}

	anchors.left: parent.left
	anchors.right: parent.right
	height: shouldBeActive ? layout.implicitHeight : 0
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

	Rectangle {
		anchors.fill: parent
		anchors.margins: -Appearance.padding.smaller
		color: DynamicColors.palette.m3primaryContainer
		opacity: root.highlighted ? 0.5 : 0
		radius: Appearance.rounding.small
		z: -1

		Behavior on opacity {
			Anim {
				duration: Appearance.anim.durations.normal
			}
		}
	}

	ColumnLayout {
		id: layout

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.smaller

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		Repeater {
			model: [...root.object[root.setting]]

			Item {
				required property int index
				required property var modelData

				Layout.fillWidth: true
				Layout.preferredHeight: layout.implicitHeight + Appearance.padding.smaller * 2

				CustomRect {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.topMargin: -(Appearance.spacing.smaller / 2)
					color: DynamicColors.tPalette.m3outlineVariant
					implicitHeight: 1
					visible: index !== 0
				}

				ColumnLayout {
					id: layout

					anchors.left: parent.left
					anchors.margins: Appearance.padding.small
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					spacing: Appearance.spacing.small

					RowLayout {
						Layout.fillWidth: true

						CustomText {
							Layout.fillWidth: true
							text: qsTr("From")
						}

						CustomRect {
							Layout.preferredHeight: 33
							Layout.preferredWidth: Math.max(Math.min(fromTextField.contentWidth + Appearance.padding.large * 2, 550), 50)
							color: DynamicColors.tPalette.m3surfaceContainerHigh
							radius: Appearance.rounding.full

							CustomTextField {
								id: fromTextField

								anchors.centerIn: parent
								horizontalAlignment: Text.AlignHCenter
								implicitWidth: Math.min(contentWidth + Appearance.padding.normal * 2, 550)
								text: modelData.from ?? ""

								onEditingFinished: root.updateAlias(index, "from", text)
							}
						}

						IconButton {
							font.pointSize: Appearance.font.size.large
							icon: "delete"
							type: IconButton.Tonal

							onClicked: root.removeAlias(index)
						}
					}

					RowLayout {
						Layout.fillWidth: true

						CustomText {
							Layout.fillWidth: true
							text: qsTr("To")
						}

						CustomRect {
							Layout.preferredHeight: 33
							Layout.preferredWidth: Math.max(Math.min(toTextField.contentWidth + Appearance.padding.large * 2, 550), 50)
							color: DynamicColors.tPalette.m3surfaceContainerHigh
							radius: Appearance.rounding.full

							CustomTextField {
								id: toTextField

								anchors.centerIn: parent
								horizontalAlignment: Text.AlignHCenter
								implicitWidth: Math.min(contentWidth + Appearance.padding.normal * 2, 550)
								text: modelData.to ?? ""

								onEditingFinished: root.updateAlias(index, "to", text)
							}
						}
					}
				}
			}
		}

		RowLayout {
			Layout.fillWidth: true

			IconButton {
				font.pointSize: Appearance.font.size.large
				icon: "add"

				onClicked: root.addAlias()
			}

			CustomText {
				Layout.fillWidth: true
				text: qsTr("Add alias")
			}
		}
	}
}
