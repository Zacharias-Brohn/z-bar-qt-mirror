import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property int index
	required property var modelData
	property bool shouldBeActive: true

	signal addActiveActionRequested
	signal deleteRequested(int index)
	signal fieldEdited(string key, var value)

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: shouldBeActive ? row.implicitHeight + Appearance.padding.smaller * 2 : 0
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

	CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.topMargin: -(Appearance.spacing.smaller / 2)
		color: DynamicColors.tPalette.m3outlineVariant
		implicitHeight: 1
		visible: root.index !== 0
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.large

		Item {
			id: nameCell

			property string draftName: ""
			property bool editing: false

			function beginEdit() {
				draftName = root.modelData.name ?? "";
				editing = true;
				nameEditor.forceActiveFocus();
			}

			function cancelEdit() {
				draftName = root.modelData.name ?? "";
				editing = false;
			}

			function commitEdit() {
				editing = false;

				if (draftName !== (root.modelData.name ?? "")) {
					root.fieldEdited("name", draftName);
				}
			}

			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			Layout.fillHeight: true
			Layout.preferredWidth: root.width / 2

			HoverHandler {
				id: nameHover
			}

			HoverIconButton {
				id: editButton

				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				font.pointSize: Appearance.font.size.large
				icon: "edit"
				shouldBeVisible: nameHover.hovered && !nameCell.editing

				onClicked: nameCell.beginEdit()
			}

			CustomText {
				anchors.left: parent.left
				anchors.leftMargin: nameHover.hovered ? editButton.width + Appearance.spacing.smaller * 2 : 0
				anchors.right: deleteButton.left
				anchors.rightMargin: Appearance.spacing.small
				anchors.verticalCenter: parent.verticalCenter
				elide: Text.ElideRight    // enable if CustomText supports it
				font.pointSize: Appearance.font.size.larger
				text: root.modelData.name
				visible: !nameCell.editing

				Behavior on anchors.leftMargin {
					Anim {
					}
				}
			}

			HoverIconButton {
				id: deleteButton

				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				font.pointSize: Appearance.font.size.large
				icon: "delete"
				shouldBeVisible: nameHover.hovered && !nameCell.editing

				onClicked: root.deleteRequested(root.index)
			}

			CustomRect {
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				color: DynamicColors.tPalette.m3surface
				implicitHeight: nameEditor.implicitHeight + (Appearance.padding.normal * 2)
				implicitWidth: Math.min(nameEditor.contentWidth + (Appearance.padding.normal * 2), parent.width - Appearance.padding.normal)
				radius: Appearance.rounding.small
				visible: nameCell.editing

				CustomTextField {
					id: nameEditor

					anchors.centerIn: parent
					horizontalAlignment: Text.AlignHCenter
					implicitWidth: Math.min(contentWidth + Appearance.padding.normal * 2, nameCell.width - Appearance.padding.normal)
					text: nameCell.draftName

					Keys.onEscapePressed: {
						nameCell.cancelEdit();
					}
					onEditingFinished: {
						nameCell.commitEdit();
					}
					onTextEdited: {
						nameCell.draftName = nameEditor.text;
					}
				}
			}
		}

		VSeparator {
		}

		ColumnLayout {
			id: cLayout

			Layout.fillWidth: true

			RowLayout {
				Layout.fillWidth: true

				CustomText {
					Layout.fillWidth: true
					text: qsTr("Timeout")
				}

				CustomRect {
					Layout.preferredHeight: 33
					Layout.preferredWidth: Math.max(Math.min(timeField.contentWidth + Appearance.padding.normal * 3, 200), 50)
					color: DynamicColors.tPalette.m3surface
					radius: Appearance.rounding.small

					CustomTextField {
						id: timeField

						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: String(root.modelData.timeout ?? "")

						onEditingFinished: {
							root.fieldEdited("timeout", Number(text));
						}
					}
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
					text: qsTr("Idle Action")
				}

				CustomRect {
					Layout.preferredHeight: 33
					Layout.preferredWidth: Math.max(Math.min(idleField.contentWidth + Appearance.padding.normal * 3, 200), 50)
					color: DynamicColors.tPalette.m3surface
					radius: Appearance.rounding.small

					CustomTextField {
						id: idleField

						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: root.modelData.idleAction ?? ""

						onEditingFinished: {
							root.fieldEdited("idleAction", text);
						}
					}
				}
			}

			Separator {
				Layout.fillWidth: true
				anchors.left: undefined
				anchors.right: undefined
			}

			Item {
				Layout.fillWidth: true
				implicitHeight: activeActionRow.visible ? activeActionRow.implicitHeight : addButtonRow.implicitHeight

				RowLayout {
					id: activeActionRow

					anchors.left: parent.left
					anchors.right: parent.right
					visible: root.modelData.activeAction !== undefined

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Active Action")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: Math.max(Math.min(actionField.contentWidth + Appearance.padding.normal * 3, 200), 50)
						color: DynamicColors.tPalette.m3surface
						radius: Appearance.rounding.small

						CustomTextField {
							id: actionField

							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: root.modelData.activeAction ?? ""

							onEditingFinished: {
								root.fieldEdited("activeAction", text);
							}
						}
					}
				}

				RowLayout {
					id: addButtonRow

					anchors.left: parent.left
					anchors.right: parent.right
					visible: root.modelData.activeAction === undefined

					IconButton {
						id: button

						Layout.alignment: Qt.AlignLeft
						font.pointSize: Appearance.font.size.large
						icon: "add"

						onClicked: root.addActiveActionRequested()
					}

					CustomText {
						Layout.alignment: Qt.AlignLeft
						text: qsTr("Add active action")
					}
				}
			}
		}
	}
}
