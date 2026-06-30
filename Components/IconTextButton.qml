import QtQuick
import QtQuick.Layouts
import qs.Config

ButtonBase {
	id: root

	property alias icon: iconLabel.text
	readonly property alias iconLabel: iconLabel
	readonly property alias label: label
	property alias text: label.text

	activeColor: type === TextButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondary
	activeOnColor: {
		if (type === TextButton.Text)
			return DynamicColors.palette.m3primary;
		return type === TextButton.Filled ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondary;
	}
	horizontalPadding: Appearance.padding.larger
	implicitHeight: row.implicitHeight + verticalPadding * 2
	implicitWidth: row.implicitWidth + horizontalPadding * 2
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

	RowLayout {
		id: row

		anchors.centerIn: parent
		spacing: Appearance.spacing.small

		MaterialIcon {
			id: iconLabel

			Layout.alignment: Qt.AlignVCenter
			color: root.onColor
			fill: root.internalChecked ? 1 : 0
			font: {
				const f = Qt.font(root.font);
				f.pointSize = Math.round(root.font.pointSize * 1.2);
				f.family = "Material Symbols Rounded";
				return f;
			}

			Behavior on fill {
				Anim {
					type: Anim.DefaultEffects
				}
			}
		}

		CustomText {
			id: label

			Layout.alignment: Qt.AlignVCenter
			Layout.topMargin: -1
			color: root.onColor
			font: root.font
		}
	}
}
