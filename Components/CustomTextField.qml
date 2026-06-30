pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.Config

TextFieldBase {
	id: root

	enum TextFieldType {
		Outlined,
		Filled
	}

	readonly property int clampedRadius: Math.min(horizontalPadding, Math.min(width, height) / 2, radius)
	readonly property string effectiveSupportingText: isError && errorText ? errorText : supportingText
	property bool emptyIsValid: true
	property string errorText
	readonly property int filledOffset: type === CustomTextField.Filled ? Appearance.spacing.small : 0
	readonly property int horizontalPadding: Appearance.padding.large
	property bool isError
	property string leadingIcon
	readonly property int leadingOffset: leadingIcon ? leadingIconLoader.width + leadingIconLoader.anchors.leftMargin : 0
	readonly property real outlineGap: placeholder.width * root.smallFontScale + Appearance.spacing.extraSmall * 2
	property real outlineGapScale: activeFocus || text ? 1 : 0
	property int radius: Appearance.rounding.small
	readonly property real smallFontScale: smallFontSize / font.pointSize
	property int smallFontSize: Appearance.font.size.small
	property string supportingText
	readonly property int supportingTextOffset: effectiveSupportingText ? supportingTextLoader.height + Appearance.spacing.extraSmall : 0
	property string trailingIcon
	readonly property int trailingOffset: trailingIcon ? trailingIconLoader.width + trailingIconLoader.anchors.rightMargin : 0
	property int type: CustomTextField.Outlined
	readonly property bool valid: !validate || (!text && emptyIsValid) || (validate instanceof RegExp ? validate.test(text) : !!validate(text))
	property var validate // Regex or function

	bottomPadding: Appearance.padding.large + supportingTextOffset - filledOffset
	leftPadding: horizontalPadding + leadingOffset
	rightPadding: horizontalPadding + trailingOffset
	topPadding: Appearance.padding.large + filledOffset

	background: Loader {
		anchors.bottomMargin: root.supportingTextOffset
		anchors.fill: parent
		sourceComponent: root.type === CustomTextField.Filled ? filledComp : outlineComp

		StateLayer {
			id: stateLayer

			cursorShape: Qt.IBeamCursor
			enabled: !root.activeFocus
			manualPressOverride: tapHandler.pressed
			radius: root.type === CustomTextField.Outlined ? root.clampedRadius : 0
			topLeftRadius: root.clampedRadius
			topRightRadius: root.clampedRadius

			onClicked: root.focus = true
		}
	}
	Behavior on outlineGapScale {
		Anim {
			type: Anim.DefaultEffects
		}
	}

	onEditingFinished: {
		if (!valid)
			isError = true;
	}
	onPressed: {
		if (stateLayer.enabled)
			stateLayer.press(stateLayer.mouseX, stateLayer.mouseY);
	}
	onTextEdited: {
		if (isError)
			isError = false;
	}

	Item {
		id: contentWrapper

		anchors.bottomMargin: root.supportingTextOffset
		anchors.fill: parent

		CustomText {
			id: placeholder

			anchors.left: parent.left
			anchors.leftMargin: root.leftPadding
			anchors.topMargin: Appearance.padding.extraSmall
			anchors.verticalCenter: parent.verticalCenter
			color: root.isError ? DynamicColors.palette.m3error : (root.activeFocus ? DynamicColors.palette.m3primary : root.text ? DynamicColors.palette.m3outline : root.placeholderTextColor)
			font.family: root.font.family
			font.pointSize: root.font.pointSize
			font.variableAxes: root.font.variableAxes
			font.weight: root.font.weight
			renderType: Text.QtRendering
			text: root.placeholderText

			states: [
				State {
					name: "smallOutlined"
					when: root.type === CustomTextField.Outlined && (root.activeFocus || root.text)

					PropertyChanges {
						placeholder.anchors.leftMargin: -(1 - root.smallFontScale) * placeholder.width / 2 + root.horizontalPadding + -Appearance.spacing.extraSmall
						placeholder.scale: root.smallFontScale
					}

					AnchorChanges {
						anchors.verticalCenter: contentWrapper.top
						target: placeholder
					}
				},
				State {
					name: "smallFilled"
					when: root.type === CustomTextField.Filled && (root.activeFocus || root.text)

					PropertyChanges {
						placeholder.anchors.leftMargin: -(1 - root.smallFontScale) * placeholder.width / 2 + root.horizontalPadding + root.leadingOffset
						placeholder.scale: root.smallFontScale
					}

					AnchorChanges {
						anchors.top: contentWrapper.top
						anchors.verticalCenter: undefined
						target: placeholder
					}
				}
			]
			transitions: Transition {
				Anim {
					properties: "scale,leftMargin"
					type: Anim.DefaultEffects
				}

				AnchorAnim {
					duration: Appearance.anim.durations.expressiveEffects
					easing: Appearance.anim.curves.expressiveDefaultEffects
				}
			}
		}

		Loader {
			id: leadingIconLoader

			active: root.leadingIcon
			anchors.left: parent.left
			anchors.leftMargin: Appearance.padding.larger
			anchors.verticalCenter: parent.verticalCenter

			sourceComponent: MaterialIcon {
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.large
				text: root.leadingIcon
			}
		}

		Loader {
			id: trailingIconLoader

			active: root.trailingIcon
			anchors.right: parent.right
			anchors.rightMargin: Appearance.padding.larger
			anchors.verticalCenter: parent.verticalCenter

			sourceComponent: MaterialIcon {
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.large
				text: root.trailingIcon
			}
		}
	}

	Loader {
		id: supportingTextLoader

		active: root.effectiveSupportingText
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.leftMargin: root.horizontalPadding

		sourceComponent: CustomText {
			color: root.isError ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.small
			text: root.effectiveSupportingText
		}
	}

	TapHandler {
		id: tapHandler
	}

	Component {
		id: outlineComp

		Shape {
			id: bg

			asynchronous: true
			preferredRendererType: Shape.CurveRenderer

			ShapePath {
				capStyle: ShapePath.RoundCap
				fillColor: "transparent"
				startX: root.horizontalPadding - root.clampedRadius + root.outlineGap * (1 - root.outlineGapScale) / 2 + root.outlineGap * root.outlineGapScale
				strokeColor: root.isError ? DynamicColors.palette.m3error : (root.activeFocus ? DynamicColors.palette.m3primary : DynamicColors.palette.m3outline)
				strokeWidth: root.activeFocus ? 2 : 1

				Behavior on strokeColor {
					CAnim {
					}
				}
				Behavior on strokeWidth {
					Anim {
					}
				}

				PathLine {
					x: bg.width - root.clampedRadius
				}

				PathArc {
					radiusX: root.clampedRadius
					radiusY: root.clampedRadius
					x: bg.width
					y: root.clampedRadius
				}

				PathLine {
					x: bg.width
					y: bg.height - root.clampedRadius
				}

				PathArc {
					radiusX: root.clampedRadius
					radiusY: root.clampedRadius
					x: bg.width - root.clampedRadius
					y: bg.height
				}

				PathLine {
					x: root.clampedRadius
					y: bg.height
				}

				PathArc {
					radiusX: root.clampedRadius
					radiusY: root.clampedRadius
					x: 0
					y: bg.height - root.clampedRadius
				}

				PathLine {
					x: 0
					y: root.clampedRadius
				}

				PathArc {
					radiusX: root.clampedRadius
					radiusY: root.clampedRadius
					x: root.clampedRadius
					y: 0
				}

				PathLine {
					x: root.horizontalPadding - root.clampedRadius + root.outlineGap * (1 - root.outlineGapScale) / 2
				}
			}
		}
	}

	Component {
		id: filledComp

		CustomRect {
			color: root.activeFocus ? DynamicColors.tPalette.m3surfaceContainerHighest : DynamicColors.tPalette.m3surfaceContainerHigh
			topLeftRadius: root.clampedRadius
			topRightRadius: root.clampedRadius

			CustomRect {
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				color: root.isError ? DynamicColors.palette.m3error : (root.activeFocus ? DynamicColors.palette.m3primary : DynamicColors.palette.m3outline)
				implicitHeight: root.activeFocus ? 2 : 1

				Behavior on implicitHeight {
					Anim {
					}
				}
			}
		}
	}
}
