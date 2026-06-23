import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomClippingRect {
	id: root

	required property color accent
	required property string icon
	required property string label
	required property string subLabel
	required property real temperature
	required property real usage

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Math.max(tempProg.implicitHeight + detailsRow.implicitHeight + Appearance.spacing.large, usageColumn.implicitHeight + usageLabel.implicitHeight) + Appearance.padding.large * 2
	implicitWidth: 450
	radius: Appearance.rounding.large - Appearance.padding.normal

	CustomRect {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.top: parent.top
		color: Qt.alpha(root.accent, 0.05)
		implicitWidth: parent.width * root.usage

		Behavior on implicitWidth {
			Anim {
			}
		}
	}

	CircularProgress {
		id: tempProg

		anchors.left: parent.left
		anchors.margins: Appearance.padding.large
		anchors.top: parent.top
		fgColor: root.accent
		implicitSize: Math.max(icon.implicitWidth, icon.implicitHeight) + Appearance.padding.larger * 2
		spacing: Appearance.spacing.extraSmall
		strokeWidth: Appearance.padding.extraSmall
		value: root.usage

		Behavior on clampedVal {
			Anim {
			}
		}

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			color: root.accent
			text: root.icon
		}
	}

	ColumnLayout {
		anchors.left: tempProg.right
		anchors.margins: Appearance.spacing.large
		anchors.right: usageColumn.left
		anchors.verticalCenter: tempProg.verticalCenter
		spacing: Appearance.spacing.extraSmall

		CustomText {
			color: root.accent
			text: root.label
		}

		CustomText {
			Layout.fillWidth: true
			color: DynamicColors.palette.m3onSurfaceVariant
			elide: Text.ElideRight
			text: root.subLabel
		}
	}

	ColumnLayout {
		id: detailsRow

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: Appearance.padding.largeIncreased
		spacing: Appearance.spacing.extraSmall

		RowLayout {
			Layout.leftMargin: -Appearance.padding.extraSmall
			spacing: Appearance.spacing.extraSmall

			MaterialIcon {
				Layout.topMargin: Math.round(fontInfo.pointSize * 0.08)
				color: root.temperature > 90 ? DynamicColors.palette.m3error : root.accent
				fill: 1
				text: root.temperature > 90 ? "thermometer_alert" : "thermometer"
			}

			CustomText {
				text: `${Math.ceil(root.temperature)}°${"C"}`
			}
		}

		CustomProgressBar {
			fgColor: root.accent
			implicitHeight: Appearance.padding.small
			indeterminate: isNaN(root.usage) || isNaN(root.temperature)
			value: root.temperature / 100
		}
	}

	Column {
		id: usageColumn

		anchors.margins: Appearance.padding.large
		anchors.right: parent.right
		anchors.rightMargin: 32
		anchors.verticalCenter: parent.verticalCenter
		spacing: 0

		CustomText {
			id: usageLabel

			anchors.right: parent.right
			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.normal
			text: qsTr("Usage")
		}

		CustomText {
			anchors.right: parent.right
			color: root.accent
			font.pointSize: Appearance.font.size.extraLarge
			font.weight: Font.Medium
			text: isNaN(root.usage) ? "...%" : Math.round(root.usage * 100) + "%"
		}
	}
}
