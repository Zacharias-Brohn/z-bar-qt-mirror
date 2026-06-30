pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Item {
	id: root

	enum Variant {
		Outlined,
		Filled
	}

	readonly property color accent: !root.enabled ? DynamicColors.palette.m3onSurface : (isError ? DynamicColors.palette.m3error : (focused ? DynamicColors.palette.m3primary : DynamicColors.palette.m3outline))
	readonly property real disabledOpacity: 0.38
	readonly property string effectiveTrailingIcon: root.trailingIcon.length > 0 ? root.trailingIcon : (root.password ? (field.echoMode === TextInput.Password ? "visibility" : "visibility_off") : (root.isError ? "error" : ""))
	property string errorText: ""
	readonly property alias field: field
	readonly property bool floating: focused || hasContent || prefixText.length > 0
	readonly property bool focused: field.activeFocus
	readonly property bool hasContent: field.text.length > 0
	readonly property color iconColor: !root.enabled ? DynamicColors.palette.m3onSurface : (isError ? DynamicColors.palette.m3error : (focused ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant))
	property int inputMethodHints: Qt.ImhNone
	property bool isError: false
	property string label: ""
	readonly property color labelColor: !root.enabled ? DynamicColors.palette.m3onSurface : (isError ? DynamicColors.palette.m3error : (focused ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant))
	property string leadingIcon: ""
	property int maxLength: 0
	property color notchColor: DynamicColors.palette.m3surface
	readonly property bool outlined: variant === M3TextField.Variant.Outlined
	property bool password: false
	property string placeholder: ""
	property string prefixText: ""
	property string suffixText: ""
	readonly property color supportColor: !root.enabled ? DynamicColors.palette.m3onSurface : (isError ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurfaceVariant)
	property string supportingText: ""
	property alias text: field.text
	property string trailingIcon: ""
	readonly property bool trailingInteractive: root.password && root.trailingIcon.length === 0
	property var validator: null
	property int variant: M3TextField.Variant.Outlined

	signal accepted

	function forceFieldFocus(): void {
		field.forceActiveFocus();
	}

	implicitHeight: 56 + (supportRow.visible ? supportRow.implicitHeight + Appearance.spacing.extraSmall : 0)
	implicitWidth: 240

	CustomRect {
		id: filledBg

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		color: root.enabled ? (root.focused ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 1) : DynamicColors.palette.m3surfaceContainerHigh) : DynamicColors.palette.m3onSurface
		implicitHeight: 56
		opacity: root.enabled ? 1 : 0.04 // M3 filled disabled container @ 4%

		topLeftRadius: Appearance.rounding.small
		topRightRadius: Appearance.rounding.small
		visible: !root.outlined

		Behavior on color {
			CAnim {
			}
		}

		StateLayer {
			anchors.fill: parent
			color: root.isError ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurface
			enabled: root.enabled
			topLeftRadius: Appearance.rounding.small
			topRightRadius: Appearance.rounding.small

			onClicked: field.forceActiveFocus()
		}

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			color: root.accent
			implicitHeight: root.focused || root.isError ? 2 : 1
			opacity: root.enabled ? 1 : root.disabledOpacity

			Behavior on color {
				CAnim {
				}
			}
			Behavior on implicitHeight {
				Anim {
					type: Anim.StandardSmall
				}
			}
		}
	}

	CustomRect {
		id: outline

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		border.color: root.accent
		border.width: root.focused || root.isError ? 2 : 1
		color: "transparent"
		implicitHeight: 56
		opacity: root.enabled ? 1 : root.disabledOpacity
		radius: Appearance.rounding.small
		visible: root.outlined

		Behavior on border.color {
			CAnim {
			}
		}
		Behavior on border.width {
			Anim {
				type: Anim.StandardSmall
			}
		}

		StateLayer {
			anchors.fill: parent
			anchors.margins: outline.border.width
			color: root.isError ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurface
			enabled: root.enabled
			radius: Appearance.rounding.small

			onClicked: field.forceActiveFocus()
		}
	}

	Rectangle {
		color: root.notchColor
		height: outline.border.width
		opacity: root.enabled ? 1 : root.disabledOpacity
		visible: root.outlined && root.floating && root.label.length > 0
		width: labelText.width + Appearance.spacing.extraSmall
		x: labelText.x - Appearance.spacing.extraSmall / 2
		y: 0
	}

	CustomText {
		id: labelText

		color: root.labelColor
		font.pointSize: root.floating ? Appearance.font.size.small : Appearance.font.size.medium
		opacity: root.enabled ? 1 : root.disabledOpacity
		text: root.label
		visible: root.label.length > 0
		x: root.floating ? (Appearance.padding.larger + Appearance.spacing.extraSmall / 2) : (leading.visible ? leading.x + leading.width + Appearance.spacing.small : Appearance.padding.larger)
		y: root.floating ? (root.outlined ? -height / 2 : Appearance.padding.extraSmall) : (56 - height) / 2

		Behavior on color {
			CAnim {
			}
		}
		Behavior on x {
			Anim {
				type: Anim.StandardSmall
			}
		}
		Behavior on y {
			Anim {
				type: Anim.StandardSmall
			}
		}
	}

	MaterialIcon {
		id: leading

		anchors.left: parent.left
		anchors.leftMargin: Appearance.padding.larger
		anchors.top: parent.top
		anchors.topMargin: (56 - height) / 2
		color: root.iconColor
		font.pointSize: Appearance.font.size.medium
		opacity: root.enabled ? 1 : root.disabledOpacity
		text: root.leadingIcon
		visible: root.leadingIcon.length > 0

		Behavior on color {
			CAnim {
			}
		}
	}

	MaterialIcon {
		id: trailing

		anchors.right: parent.right
		anchors.rightMargin: Appearance.padding.larger
		anchors.top: parent.top
		anchors.topMargin: (56 - height) / 2
		color: root.isError ? DynamicColors.palette.m3error : (root.enabled ? DynamicColors.palette.m3onSurfaceVariant : DynamicColors.palette.m3onSurface)
		font.pointSize: Appearance.font.size.medium
		opacity: root.enabled ? 1 : root.disabledOpacity
		text: root.effectiveTrailingIcon
		visible: root.effectiveTrailingIcon.length > 0

		MouseArea {
			anchors.fill: parent
			anchors.margins: -Appearance.padding.small
			cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
			enabled: root.trailingInteractive && root.enabled

			onClicked: field.echoMode = field.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password
		}
	}

	CustomText {
		id: prefix

		anchors.left: leading.visible ? leading.right : parent.left
		anchors.leftMargin: leading.visible ? Appearance.spacing.small : Appearance.padding.larger
		anchors.top: parent.top
		anchors.topMargin: root.floating && !root.outlined ? Appearance.font.size.small + Appearance.padding.extraSmall : 0
		color: root.enabled ? DynamicColors.palette.m3onSurfaceVariant : DynamicColors.palette.m3onSurface
		font.pointSize: Appearance.font.size.medium
		height: 56
		opacity: root.enabled ? 1 : root.disabledOpacity
		text: root.prefixText
		verticalAlignment: Text.AlignVCenter
		visible: root.prefixText.length > 0 && root.floating
	}

	CustomText {
		id: suffix

		anchors.right: trailing.visible ? trailing.left : parent.right
		anchors.rightMargin: trailing.visible ? Appearance.spacing.small : Appearance.padding.larger
		anchors.top: parent.top
		anchors.topMargin: root.floating && !root.outlined ? Appearance.font.size.small + Appearance.padding.extraSmall : 0
		color: root.enabled ? DynamicColors.palette.m3onSurfaceVariant : DynamicColors.palette.m3onSurface
		font.pointSize: Appearance.font.size.medium
		height: 56
		opacity: root.enabled ? 1 : root.disabledOpacity
		text: root.suffixText
		verticalAlignment: Text.AlignVCenter
		visible: root.suffixText.length > 0 && root.floating
	}

	CustomTextField {
		id: field

		anchors.left: prefix.visible ? prefix.right : (leading.visible ? leading.right : parent.left)
		anchors.leftMargin: prefix.visible ? Appearance.spacing.extraSmall : (leading.visible ? Appearance.spacing.small : Appearance.padding.larger)
		anchors.right: suffix.visible ? suffix.left : (trailing.visible ? trailing.left : parent.right)
		anchors.rightMargin: suffix.visible ? Appearance.spacing.extraSmall : (trailing.visible ? Appearance.spacing.small : Appearance.padding.larger)
		anchors.top: parent.top
		color: DynamicColors.palette.m3onSurface
		echoMode: root.password ? TextInput.Password : TextInput.Normal
		enabled: root.enabled
		font.pointSize: Appearance.font.size.medium
		height: 56
		inputMethodHints: root.inputMethodHints
		maximumLength: root.maxLength > 0 ? root.maxLength : 32767
		opacity: root.enabled ? 1 : root.disabledOpacity
		placeholderText: root.focused ? root.placeholder : ""
		topPadding: root.floating && !root.outlined ? Appearance.font.size.small + Appearance.padding.extraSmall : 0
		validator: root.validator
		verticalAlignment: TextInput.AlignVCenter

		onAccepted: root.accepted()
		onTextEdited: if (root.isError)
			root.isError = false
	}

	Item {
		id: supportRow

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.topMargin: 56 + Appearance.spacing.extraSmall
		implicitHeight: Math.max(supportText.implicitHeight, counter.implicitHeight)
		visible: (root.isError && root.errorText.length > 0) || root.supportingText.length > 0 || root.maxLength > 0

		CustomText {
			id: supportText

			anchors.left: parent.left
			anchors.leftMargin: Appearance.padding.larger
			anchors.right: counter.visible ? counter.left : parent.right
			anchors.rightMargin: Appearance.spacing.small
			color: root.supportColor
			font.pointSize: Appearance.font.size.small
			opacity: root.enabled ? 1 : root.disabledOpacity
			text: root.isError && root.errorText.length > 0 ? root.errorText : root.supportingText
			wrapMode: Text.WordWrap
		}

		CustomText {
			id: counter

			anchors.right: parent.right
			anchors.rightMargin: Appearance.padding.larger
			color: root.supportColor
			font.pointSize: Appearance.font.size.small
			opacity: root.enabled ? 1 : root.disabledOpacity
			text: `${root.text.length}/${root.maxLength}`
			visible: root.maxLength > 0
		}
	}
}
