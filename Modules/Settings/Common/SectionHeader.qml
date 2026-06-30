import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomText {
	property bool first

	Layout.bottomMargin: Appearance.spacing.extraSmall
	Layout.fillWidth: true
	Layout.leftMargin: Appearance.padding.small
	Layout.topMargin: first ? 0 : Appearance.spacing.large - ((parent as ColumnLayout).spacing ?? 0)
	color: DynamicColors.palette.m3onSurfaceVariant
	elide: Text.ElideRight
	font.pointSize: Appearance.font.size.medium
}
