import QtQuick
import qs.Config

ButtonBase {
	id: root

	readonly property alias label: label
	property alias text: label.text

	activeColor: type === TextButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondary
	activeOnColor: {
		if (type === TextButton.Text)
			return DynamicColors.palette.m3primary;
		return type === TextButton.Filled ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondary;
	}
	horizontalPadding: Appearance.padding.normal
	implicitHeight: label.implicitHeight + verticalPadding * 2
	implicitWidth: label.implicitWidth + horizontalPadding * 2
	inactiveColor: {
		if (!isToggle && type === TextButton.Filled)
			return DynamicColors.palette.m3primary;
		return type === TextButton.Filled ? DynamicColors.tPalette.m3surfaceContainer : DynamicColors.palette.m3secondaryContainer;
	}
	inactiveOnColor: {
		if (!isToggle && type === TextButton.Filled)
			return DynamicColors.palette.m3onPrimary;
		if (type === TextButton.Text)
			return DynamicColors.palette.m3primary;
		return type === TextButton.Filled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer;
	}
	verticalPadding: Appearance.padding.small

	CustomText {
		id: label

		anchors.centerIn: parent
		color: root.onColor
	}
}
