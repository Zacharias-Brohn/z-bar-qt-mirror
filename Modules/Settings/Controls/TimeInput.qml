import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Helpers

Item {
	id: root

	readonly property string endTime: {
		var d = new Date(0, 0, 0, 0, 0, 0, 0);
		d.setMinutes(object[settings[2]]);
		return Qt.formatTime(d, "hh:mm AP");
	}
	readonly property bool highlighted: SettingsHighlight.highlightedSetting === name
	required property string name
	required property var object
	required property list<string> settings
	property bool shouldBeActive: true
	readonly property string startTime: {
		var d = new Date(0, 0, 0, 0, 0, 0, 0);
		d.setMinutes(object[settings[1]]);
		return Qt.formatTime(d, "hh:mm AP");
	}

	function commitChoice(choice: int, setting: string): void {
		root.object[setting] = choice;
		Config.save();
	}

	function convertHour(timeValue: int): int {
		return Math.floor(timeValue / 60);
	}

	function convertMinute(timeValue: int): int {
		return timeValue % 60;
	}

	function convertToMinutes(hour: int, minute: int): int {
		return hour * 60 + minute;
	}

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

	Rectangle {
		anchors.fill: parent
		anchors.margins: -Appearance.padding.smaller
		color: DynamicColors.palette.m3primaryContainer
		opacity: root.highlighted ? 0.5 : 0
		radius: Appearance.rounding.small

		Behavior on opacity {
			Anim {
				duration: Appearance.anim.durations.normal
			}
		}
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		ColumnLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true

			CustomText {
				id: text

				Layout.alignment: Qt.AlignLeft
				Layout.fillWidth: true
				font.pointSize: Appearance.font.size.larger
				text: root.name
			}

			CustomText {
				Layout.alignment: Qt.AlignLeft
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.normal
				text: qsTr("Dark mode will turn on at %1, and turn off at %2.").arg(root.startTime).arg(root.endTime)
			}
		}

		ColumnLayout {
			id: optionLayout

			Layout.fillHeight: true
			Layout.preferredWidth: childrenRect.width

			RowLayout {
				CustomText {
					Layout.preferredWidth: spacer.x + spacer.width
					text: qsTr("Start")
				}

				CustomText {
					Layout.preferredWidth: endMinuteRect.width + endHourRect.width
					text: qsTr("End")
				}

				CustomText {
					Layout.alignment: Qt.AlignLeft | Qt.AlignHCenter
					text: qsTr("Enabled: ")
				}

				CustomSwitch {
					id: enabledSwitch

					Layout.alignment: Qt.AlignRight | Qt.AlignHCenter
					checked: Config.general.color.scheduleDark

					onToggled: {
						root.object[root.settings[0]] = checked;
						Config.save();
						ModeScheduler.checkStartup();
					}
				}
			}

			RowLayout {
				Layout.fillHeight: true

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

					CustomTextField {
						id: startHourField

						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						clip: true
						color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
						cursorHeight: height - Appearance.padding.normal * 2
						font.family: "Roboto"
						font.letterSpacing: -0.25
						font.pixelSize: 56
						font.weight: 400
						horizontalAlignment: TextInput.AlignHCenter
						text: {
							var val = root.convertHour(root.object[root.settings[1]]);
							if (val === 0) {
								return "00";
							}
							return String(val);
						}
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
								startHourField.text = String(root.convertHour(root.object[root.settings[1]]));
								startHourField.focus = false;
							} else if (event.key === Qt.Key_Return) {
								startHourField.focus = false;
								return;
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
						onEditingFinished: {
							root.commitChoice(root.convertToMinutes(parseInt(startHourField.text), parseInt(startMinuteField.text)), root.settings[1]);
							ModeScheduler.checkStartup();
						}
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

					CustomTextField {
						id: startMinuteField

						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						clip: true
						color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
						cursorHeight: height - Appearance.padding.normal * 2
						font.family: "Roboto"
						font.letterSpacing: -0.25
						font.pixelSize: 56
						font.weight: 400
						horizontalAlignment: TextInput.AlignHCenter
						text: {
							var val = root.convertMinute(root.object[root.settings[1]]);
							if (val === 0) {
								return "00";
							}
							return String(val);
						}
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
								startMinuteField.text = String(root.convertMinute(root.object[root.settings[1]]));
								startMinuteField.focus = false;
							} else if (event.key === Qt.Key_Return) {
								startMinuteField.focus = false;
								return;
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
						onEditingFinished: {
							root.commitChoice(root.convertToMinutes(parseInt(startHourField.text), parseInt(startMinuteField.text)), root.settings[1]);
							ModeScheduler.checkStartup();
						}
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

					CustomTextField {
						id: endHourField

						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						clip: true
						color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
						cursorHeight: height - Appearance.padding.normal * 2
						font.family: "Roboto"
						font.letterSpacing: -0.25
						font.pixelSize: 56
						font.weight: 400
						horizontalAlignment: TextInput.AlignHCenter
						text: {
							var val = root.convertHour(root.object[root.settings[2]]);
							if (val === 0) {
								return "00";
							}
							return String(val);
						}
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
								endHourField.text = String(root.convertHour(root.object[root.settings[2]]));
								endHourField.focus = false;
							} else if (event.key === Qt.Key_Return) {
								endHourField.focus = false;
								return;
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
						onEditingFinished: {
							root.commitChoice(root.convertToMinutes(parseInt(endHourField.text), parseInt(endMinuteField.text)), root.settings[2]);
							ModeScheduler.checkStartup();
						}
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

					CustomTextField {
						id: endMinuteField

						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						clip: true
						color: focus ? DynamicColors.palette.m3primaryContainer : DynamicColors.palette.m3onSurface
						cursorHeight: height - Appearance.padding.normal * 2
						font.family: "Roboto"
						font.letterSpacing: -0.25
						font.pixelSize: 56
						font.weight: 400
						horizontalAlignment: TextInput.AlignHCenter
						text: {
							var val = root.convertMinute(root.object[root.settings[2]]);
							if (val === 0) {
								return "00";
							}
							return String(val);
						}
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
								endMinuteField.text = String(root.convertMinute(root.object[root.settings[2]]));
								endMinuteField.focus = false;
							} else if (event.key === Qt.Key_Return) {
								endMinuteField.focus = false;
								return;
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
						onEditingFinished: {
							root.commitChoice(root.convertToMinutes(parseInt(endHourField.text), parseInt(endMinuteField.text)), root.settings[2]);
							ModeScheduler.checkStartup();
						}
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
				Layout.fillWidth: true

				CustomText {
					id: startHour

					Layout.preferredWidth: startSeparator.x + startSeparator.width
					text: qsTr("Hour")
				}

				CustomText {
					id: startMinute

					Layout.preferredWidth: spacer.x + spacer.width - x
					text: qsTr("Minute")
				}

				CustomText {
					Layout.preferredWidth: endSeparator.x + endSeparator.width - x
					text: qsTr("Hour")
				}

				CustomText {
					text: qsTr("Minute")
				}
			}
		}
	}
}
