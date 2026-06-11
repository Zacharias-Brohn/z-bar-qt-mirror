import QtQuick
import qs.Config

ButtonBase {
	id: root

	property alias font: label.font
	property alias icon: label.text
	readonly property alias label: label

	activeColor: type === IconButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondary
	activeOnColor: type === IconButton.Filled ? DynamicColors.palette.m3onPrimary : type === IconButton.Tonal ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3primary
	implicitHeight: {
		const h = label.implicitHeight + padding * 2;
		if (h % 2 !== 0)
			return h + 1;
		return h;
	}
	implicitWidth: implicitHeight
	inactiveColor: {
		if (!isToggle && type === IconButton.Filled)
			return DynamicColors.palette.m3primary;
		return type === IconButton.Filled ? DynamicColors.tPalette.m3surfaceContainer : DynamicColors.palette.m3secondaryContainer;
	}
	inactiveOnColor: {
		if (!isToggle && type === IconButton.Filled)
			return DynamicColors.palette.m3onPrimary;
		return type === IconButton.Tonal ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurfaceVariant;
	}
	padding: type === IconButton.Text ? Appearance.padding.extraSmall / 2 : Appearance.padding.small

	MaterialIcon {
		id: label

		anchors.centerIn: parent
		anchors.verticalCenterOffset: 1
		color: root.onColor
		fill: !root.isToggle || root.internalChecked ? 1 : 0

		Behavior on fill {
			Anim {
				type: Anim.DefaultEffects
			}
		}
	}
}
