import QtQuick
import QtQuick.Layouts
import ZShell.Components
import qs.Config
import qs.Components
import qs.Helpers

CustomClippingRect {
	id: root

	required property var object
	required property list<string> settings
	property bool shouldBeActive: true

	signal applySettings(startTime: int, endTime: int)
	signal close

	function convertHour(timeValue: int): int {
		return Math.floor(timeValue / 60);
	}

	function convertMinute(timeValue: int): int {
		return timeValue % 60;
	}

	function convertToMinutes(hour: int, minute: int): int {
		return hour * 60 + minute;
	}

	color: DynamicColors.palette.m3surfaceContainer
	implicitHeight: column.implicitHeight + column.anchors.margins * 2 + buttonRow.implicitHeight + buttonRow.anchors.topMargin
	implicitWidth: column.implicitWidth + column.anchors.margins * 2
	radius: Appearance.rounding.large

	ColumnLayout {
		id: column

		anchors.left: parent.left
		anchors.margins: Appearance.padding.largeIncreased
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: Appearance.spacing.normal

		CustomText {
			text: qsTr("Select time")
		}

		RowLayout {
			CustomRect {
				id: startHourRect

				Layout.preferredHeight: 72
				Layout.preferredWidth: 96
				color: startHourField.focus ? DynamicColors.palette.m3onPrimaryContainer : DynamicColors.palette.m3surfaceContainerHighest
				implicitHeight: 72
				implicitWidth: 96
				radius: Appearance.rounding.small

				CustomRect {
					anchors.fill: parent
					border.color: startHourField.focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3surfaceContainerHighest
					border.width: startHourField.focus ? 2 : 0
					radius: parent.radius - border.width

					Behavior on border.width {
						Anim {
						}
					}
				}

				TextFieldBase {
					id: startHourField

					function setConfigText(setting: string): string {
						var val = root.convertHour(root.object[setting]);
						if (val === 0) {
							return "00";
						}
						return String(val);
					}

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					clip: true
					color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
					font.family: "Roboto"
					font.letterSpacing: -0.25
					font.pixelSize: 56
					font.weight: 400
					horizontalAlignment: TextInput.AlignHCenter
					text: setConfigText(root.settings[1])
					verticalAlignment: TextInput.AlignVCenter

					Keys.onPressed: event => {
						if (event.key === Qt.Key_Backspace) {
							event.accepted = true;
							if (startHourField.text.length >= 2) {
								startHourField.text = "0" + startHourField.text[0];
							} else if (startHourField.text.length === 1) {
								startHourField.text = "0";
							}
							return;
						} else if (event.key === Qt.Key_Escape) {
							event.accepted = true;
							startHourField.text = setConfigText(root.settings[1]);
							startHourField.focus = false;
						} else if (event.key === Qt.Key_Return) {
							startHourField.focus = false;
							return;
						} else if (event.key === Qt.Key_Tab) {
							startMinuteField.focus = true;
						} else if (event.key === Qt.Key_Backtab) {
							endMinuteField.focus = true;
						}

						if (event.text.length === 1 && event.text >= "0" && event.text <= "9") {
							event.accepted = true;
							var digit = event.text;
							var textLen = startHourField.text.length;

							if (textLen >= 2 && startHourField.text[0] !== '0') {
								return;
							}

							var val = 0;
							if (textLen === 0) {
								val = parseInt(digit);
							} else if (textLen === 1) {
								val = parseInt(startHourField.text + digit);
							} else {
								val = parseInt(startHourField.text[1] + digit);
							}

							val = Math.max(0, Math.min(23, val));

							if (textLen >= 2 && val < 10) {
								startHourField.text = "0" + val;
							} else {
								startHourField.text = val.toString();
							}
						}

						event.accepted = true;
					}
					onCursorPositionChanged: cursorPosition = 2
					onTextEdited: {
						if (startHourField.text === "")
							return;
						var val = parseInt(startHourField.text);
						if (isNaN(val))
							return;
						val = Math.max(0, Math.min(23, val));
						var newText = val.toString();
						if (newText !== startHourField.text)
							startHourField.text = newText;
					}
				}
			}

			CustomText {
				id: startSeparator

				font.pointSize: Appearance.font.size.extraLarge
				text: ":"
			}

			CustomRect {
				id: startMinuteRect

				Layout.preferredHeight: 72
				Layout.preferredWidth: 96
				color: startMinuteField.focus ? DynamicColors.palette.m3onPrimaryContainer : DynamicColors.palette.m3surfaceContainerHighest
				implicitHeight: 72
				implicitWidth: 96
				radius: Appearance.rounding.small

				CustomRect {
					anchors.fill: parent
					border.color: startMinuteField.focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3surfaceContainerHighest
					border.width: startMinuteField.focus ? 2 : 0
					radius: parent.radius - border.width

					Behavior on border.width {
						Anim {
						}
					}
				}

				TextFieldBase {
					id: startMinuteField

					function setConfigText(setting: string): string {
						var val = root.convertMinute(root.object[setting]);
						if (val === 0) {
							return "00";
						}
						return String(val);
					}

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					clip: true
					color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
					font.family: "Roboto"
					font.letterSpacing: -0.25
					font.pixelSize: 56
					font.weight: 400
					horizontalAlignment: TextInput.AlignHCenter
					text: setConfigText(root.settings[1])
					verticalAlignment: TextInput.AlignVCenter

					Keys.onPressed: event => {
						if (event.key === Qt.Key_Backspace) {
							event.accepted = true;
							if (startMinuteField.text.length >= 2) {
								startMinuteField.text = "0" + startMinuteField.text[0];
							} else if (startMinuteField.text.length === 1) {
								startMinuteField.text = "0";
							}
							return;
						} else if (event.key === Qt.Key_Escape) {
							event.accepted = true;
							startMinuteField.text = setConfigText(root.settings[1]);
							startMinuteField.focus = false;
						} else if (event.key === Qt.Key_Return) {
							startMinuteField.focus = false;
							return;
						} else if (event.key === Qt.Key_Tab) {
							endHourField.focus = true;
						} else if (event.key === Qt.Key_Backtab) {
							startHourField.focus = true;
						}

						if (event.text.length === 1 && event.text >= "0" && event.text <= "9") {
							event.accepted = true;
							var digit = event.text;
							var textLen = startMinuteField.text.length;

							if (textLen >= 2 && startMinuteField.text[0] !== '0') {
								return;
							}

							var val = 0;
							if (textLen === 0) {
								val = parseInt(digit);
							} else if (textLen === 1) {
								val = parseInt(startMinuteField.text + digit);
							} else {
								val = parseInt(startMinuteField.text[1] + digit);
							}

							val = Math.max(0, Math.min(59, val));

							if (textLen >= 2 && val < 10) {
								startMinuteField.text = "0" + val;
							} else {
								startMinuteField.text = val.toString();
							}
						}

						event.accepted = true;
					}
					onCursorPositionChanged: cursorPosition = 2
					onTextEdited: {
						if (startMinuteField.text === "")
							return;
						var val = parseInt(startMinuteField.text);
						if (isNaN(val))
							return;
						val = Math.max(0, Math.min(23, val));
						var newText = val.toString();
						if (newText !== startMinuteField.text)
							startMinuteField.text = newText;
					}
				}
			}

			Item {
				id: spacer

				Layout.preferredWidth: Appearance.spacing.large
			}

			CustomRect {
				id: endHourRect

				Layout.preferredHeight: 72
				Layout.preferredWidth: 96
				color: endHourField.focus ? DynamicColors.palette.m3onPrimaryContainer : DynamicColors.palette.m3surfaceContainerHighest
				implicitHeight: 72
				implicitWidth: 96
				radius: Appearance.rounding.small

				CustomRect {
					anchors.fill: parent
					border.color: endHourField.focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3surfaceContainerHighest
					border.width: endHourField.focus ? 2 : 0
					radius: parent.radius - border.width

					Behavior on border.width {
						Anim {
						}
					}
				}

				TextFieldBase {
					id: endHourField

					function setConfigText(setting: string): string {
						var val = root.convertHour(root.object[setting]);
						if (val === 0) {
							return "00";
						}
						return String(val);
					}

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					clip: true
					color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
					font.family: "Roboto"
					font.letterSpacing: -0.25
					font.pixelSize: 56
					font.weight: 400
					horizontalAlignment: TextInput.AlignHCenter
					text: setConfigText(root.settings[2])
					verticalAlignment: TextInput.AlignVCenter

					Keys.onPressed: event => {
						if (event.key === Qt.Key_Backspace) {
							event.accepted = true;
							if (endHourField.text.length >= 2) {
								endHourField.text = "0" + endHourField.text[0];
							} else if (endHourField.text.length === 1) {
								endHourField.text = "0";
							}
							return;
						} else if (event.key === Qt.Key_Escape) {
							event.accepted = true;
							endHourField.text = setConfigText(root.settings[2]);
							endHourField.focus = false;
						} else if (event.key === Qt.Key_Return) {
							endHourField.focus = false;
							return;
						} else if (event.key === Qt.Key_Tab) {
							endMinuteField.focus = true;
						} else if (event.key === Qt.Key_Backtab) {
							startMinuteField.focus = true;
						}

						if (event.text.length === 1 && event.text >= "0" && event.text <= "9") {
							event.accepted = true;
							var digit = event.text;
							var textLen = endHourField.text.length;

							if (textLen >= 2 && endHourField.text[0] !== '0') {
								return;
							}

							var val = 0;
							if (textLen === 0) {
								val = parseInt(digit);
							} else if (textLen === 1) {
								val = parseInt(endHourField.text + digit);
							} else {
								val = parseInt(endHourField.text[1] + digit);
							}

							val = Math.max(0, Math.min(23, val));

							if (textLen >= 2 && val < 10) {
								endHourField.text = "0" + val;
							} else {
								endHourField.text = val.toString();
							}
						}

						event.accepted = true;
					}
					onCursorPositionChanged: cursorPosition = 2
					onTextEdited: {
						if (endHourField.text === "")
							return;
						var val = parseInt(endHourField.text);
						if (isNaN(val))
							return;
						val = Math.max(0, Math.min(23, val));
						var newText = val.toString();
						if (newText !== endHourField.text)
							endHourField.text = newText;
					}
				}
			}

			CustomText {
				id: endSeparator

				font.pointSize: Appearance.font.size.extraLarge
				text: ":"
			}

			CustomRect {
				id: endMinuteRect

				Layout.preferredHeight: 72
				Layout.preferredWidth: 96
				color: endMinuteField.focus ? DynamicColors.palette.m3onPrimaryContainer : DynamicColors.palette.m3surfaceContainerHighest
				implicitHeight: 72
				implicitWidth: 96
				radius: Appearance.rounding.small

				CustomRect {
					anchors.fill: parent
					border.color: endMinuteField.focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3surfaceContainerHighest
					border.width: endMinuteField.focus ? 2 : 0
					radius: parent.radius - border.width

					Behavior on border.width {
						Anim {
						}
					}
				}

				TextFieldBase {
					id: endMinuteField

					function setConfigText(setting: string): string {
						var val = root.convertMinute(root.object[setting]);
						if (val === 0) {
							return "00";
						}
						return String(val);
					}

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					clip: true
					color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
					font.family: "Roboto"
					font.letterSpacing: -0.25
					font.pixelSize: 56
					font.weight: 400
					horizontalAlignment: TextInput.AlignHCenter
					text: setConfigText(root.settings[2])
					verticalAlignment: TextInput.AlignVCenter

					Keys.onPressed: event => {
						if (event.key === Qt.Key_Backspace) {
							event.accepted = true;
							if (endMinuteField.text.length >= 2) {
								endMinuteField.text = "0" + endMinuteField.text[0];
							} else if (endMinuteField.text.length === 1) {
								endMinuteField.text = "0";
							}
							return;
						} else if (event.key === Qt.Key_Escape) {
							event.accepted = true;
							endMinuteField.text = setConfigText(root.settings[2]);
							endMinuteField.focus = false;
						} else if (event.key === Qt.Key_Return) {
							endMinuteField.focus = false;
							return;
						} else if (event.key === Qt.Key_Tab) {
							startHourField.focus = true;
						} else if (event.key === Qt.Key_Backtab) {
							endHourField.focus = true;
						}

						if (event.text.length === 1 && event.text >= "0" && event.text <= "9") {
							event.accepted = true;
							var digit = event.text;
							var textLen = endMinuteField.text.length;

							if (textLen >= 2 && endMinuteField.text[0] !== '0') {
								return;
							}

							var val = 0;
							if (textLen === 0) {
								val = parseInt(digit);
							} else if (textLen === 1) {
								val = parseInt(endMinuteField.text + digit);
							} else {
								val = parseInt(endMinuteField.text[1] + digit);
							}

							val = Math.max(0, Math.min(59, val));

							if (textLen >= 2 && val < 10) {
								endMinuteField.text = "0" + val;
							} else {
								endMinuteField.text = val.toString();
							}
						}

						event.accepted = true;
					}
					onCursorPositionChanged: cursorPosition = 2
					onTextEdited: {
						if (endMinuteField.text === "")
							return;
						var val = parseInt(endMinuteField.text);
						if (isNaN(val))
							return;
						val = Math.max(0, Math.min(23, val));
						var newText = val.toString();
						if (newText !== endMinuteField.text)
							endMinuteField.text = newText;
					}
				}
			}
		}

		RowLayout {
			CustomText {
				Layout.preferredWidth: spacer.x + spacer.width
				text: qsTr("Start")
			}

			CustomText {
				Layout.preferredWidth: endMinuteRect.width + endHourRect.width
				text: qsTr("End")
			}
		}
	}

	RowLayout {
		id: buttonRow

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: Appearance.padding.largeIncreased
		anchors.right: parent.right
		anchors.top: column.bottom
		anchors.topMargin: Appearance.spacing.normal

		Item {
			id: buttonSpacer

			Layout.fillWidth: true
		}

		ButtonRow {
			spacing: Appearance.spacing.normal

			IconTextButton {
				font.pointSize: Appearance.font.size.normal
				icon: "close"
				inactiveColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
				inactiveOnColor: DynamicColors.palette.m3onSurfaceVariant
				isRound: true
				isToggle: false
				shapeMorph: true
				shapeMorphExpansion: pressed ? 12 : 0
				text: "Cancel"

				onClicked: root.close()
			}

			IconTextButton {
				font.pointSize: Appearance.font.size.normal
				icon: "check"
				isRound: true
				isToggle: false
				shapeMorph: true
				shapeMorphExpansion: pressed ? 12 : 0
				text: "Apply"

				onClicked: {
					const start = root.convertToMinutes(parseInt(startHourField.text)) + parseInt(startMinuteField.text);
					const end = root.convertToMinutes(parseInt(endHourField.text)) + parseInt(endMinuteField.text);
					root.applySettings(start, end);
				}
			}
		}
	}
}
