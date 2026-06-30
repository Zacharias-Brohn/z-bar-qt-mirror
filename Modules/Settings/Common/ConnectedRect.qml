import QtQuick
import qs.Components
import qs.Config

CustomRect {
	property bool first
	property bool last

	bottomLeftRadius: last ? Appearance.rounding.large : Appearance.rounding.extraSmall
	bottomRightRadius: last ? Appearance.rounding.large : Appearance.rounding.extraSmall
	color: DynamicColors.tPalette.m3surfaceContainer
	topLeftRadius: first ? Appearance.rounding.large : Appearance.rounding.extraSmall
	topRightRadius: first ? Appearance.rounding.large : Appearance.rounding.extraSmall
}
