pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

ColumnLayout {
	id: root

	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	required property string setting
	property bool shouldBeActive: true

	function addAction() {
		const list = [...root.object[root.setting]];
		list.push({
			name: "New Action",
			icon: "bolt",
			description: "",
			command: [],
			enabled: true,
			dangerous: false
		});
		root.object[root.setting] = list;
		Config.save();
	}

	function removeAction(index) {
		const list = [...root.object[root.setting]];
		list.splice(index, 1);
		root.object[root.setting] = list;
		Config.save();
	}

	function updateAction(index, key, value) {
		const list = [...root.object[root.setting]];
		const entry = list[index];
		entry[key] = value;
		list[index] = entry;
		root.object[root.setting] = list;
		Config.save();
	}

	anchors.left: parent.left
	anchors.right: parent.right
	height: shouldBeActive ? implicitHeight : 0
	opacity: shouldBeActive ? 1 : 0
	scale: shouldBeActive ? 1 : 0.8
	spacing: Appearance.spacing.smaller
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

	CustomText {
		Layout.fillWidth: true
		font.pointSize: Appearance.font.size.larger
		text: root.name
	}

	Repeater {
		model: [...root.object[root.setting]]

		CustomRect {
			required property int index
			required property var modelData

			Layout.fillWidth: true
			Layout.preferredHeight: layout.implicitHeight + Appearance.padding.normal * 2
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.normal

			ColumnLayout {
				id: layout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.normal
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: Appearance.spacing.small

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: modelData.name ?? qsTr("Action")
					}

					IconButton {
						font.pointSize: Appearance.font.size.large
						icon: "delete"
						type: IconButton.Tonal

						onClicked: root.removeAction(index)
					}
				}

				Separator {
					Layout.fillWidth: true
					anchors.left: undefined
					anchors.right: undefined
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Name")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: 350
						color: DynamicColors.tPalette.m3surfaceContainerHigh
						radius: Appearance.rounding.full

						CustomTextField {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							anchors.rightMargin: Appearance.padding.normal
							text: modelData.name ?? ""

							onEditingFinished: root.updateAction(index, "name", text)
						}
					}
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Icon")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: 350
						color: DynamicColors.tPalette.m3surfaceContainerHigh
						radius: Appearance.rounding.full

						CustomTextField {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							anchors.rightMargin: Appearance.padding.normal
							text: modelData.icon ?? ""

							onEditingFinished: root.updateAction(index, "icon", text)
						}
					}
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Description")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: 350
						color: DynamicColors.tPalette.m3surfaceContainerHigh
						radius: Appearance.rounding.full

						CustomTextField {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							anchors.rightMargin: Appearance.padding.normal
							text: modelData.description ?? ""

							onEditingFinished: root.updateAction(index, "description", text)
						}
					}
				}

				StringListEditor {
					Layout.fillWidth: true
					addLabel: qsTr("Add command argument")
					anchors.left: undefined
					anchors.right: undefined
					values: [...(modelData.command ?? [])]

					onListEdited: function (values) {
						root.updateAction(index, "command", values);
					}
				}

				Separator {
					Layout.fillWidth: true
					anchors.left: undefined
					anchors.right: undefined
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Enabled")
					}

					CustomSwitch {
						checked: modelData.enabled ?? true

						onToggled: root.updateAction(index, "enabled", checked)
					}
				}

				Separator {
					Layout.fillWidth: true
					anchors.left: undefined
					anchors.right: undefined
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Dangerous")
					}

					CustomSwitch {
						checked: modelData.dangerous ?? false

						onToggled: root.updateAction(index, "dangerous", checked)
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

			onClicked: root.addAction()
		}

		CustomText {
			Layout.fillWidth: true
			text: qsTr("Add action")
		}
	}
}
