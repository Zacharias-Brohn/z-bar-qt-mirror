import QtQuick
import QtQuick.Layouts
import qs.Config

Row {
	id: root

	enum Type {
		Filled,
		Tonal
	}

	property alias active: menu.active
	property color color: type == CustomSplitButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondaryContainer
	property color disabledColor: Qt.alpha(DynamicColors.palette.m3onSurface, 0.1)
	property color disabledTextColor: Qt.alpha(DynamicColors.palette.m3onSurface, 0.38)
	readonly property alias expandBtn: expandBtn
	property alias expanded: menu.expanded
	property string fallbackIcon
	property string fallbackText
	property real horizontalPadding: Appearance.padding.larger
	readonly property alias iconLabel: iconLabel
	readonly property alias label: label
	readonly property alias menu: menu
	property alias menuItems: menu.items
	property bool menuOnTop
	property real minLeftWidth
	readonly property alias stateLayer: stateLayer
	property color textColor: type == CustomSplitButton.Filled ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
	readonly property alias textRow: textRow
	property int type: CustomSplitButton.Filled
	property real verticalPadding: Appearance.padding.small

	spacing: Math.floor(Appearance.spacing.extraSmall)

	CustomRect {
		bottomRightRadius: Appearance.rounding.small / 2
		color: !root.enabled ? root.disabledColor : root.color
		implicitHeight: expandBtn.implicitHeight
		implicitWidth: Math.max(root.minLeftWidth, textRow.implicitWidth + root.horizontalPadding * 2)
		radius: implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
		topRightRadius: Appearance.rounding.small / 2

		StateLayer {
			id: stateLayer

			bottomRightRadius: parent.bottomRightRadius
			color: root.textColor
			enabled: root.enabled
			topRightRadius: parent.topRightRadius

			onClicked: root.active?.clicked()
		}

		RowLayout {
			id: textRow

			anchors.centerIn: parent
			anchors.horizontalCenterOffset: Math.floor(root.verticalPadding / 4)
			spacing: Appearance.spacing.small

			MaterialIcon {
				id: iconLabel

				Layout.alignment: Qt.AlignVCenter
				animate: true
				color: !root.enabled ? root.disabledTextColor : root.textColor
				fill: 1
				text: root.active?.activeIcon ?? root.fallbackIcon
			}

			CustomText {
				id: label

				Layout.alignment: Qt.AlignVCenter
				Layout.preferredWidth: implicitWidth
				animate: true
				clip: true
				color: !root.enabled ? root.disabledTextColor : root.textColor
				text: root.active?.activeText ?? root.fallbackText

				Behavior on Layout.preferredWidth {
					Anim {
						type: Anim.Emphasized
					}
				}
			}
		}
	}

	CustomRect {
		id: expandBtn

		property real rad: root.expanded ? implicitHeight / 2 * Math.min(1, Appearance.rounding.scale) : Appearance.rounding.small / 2

		bottomLeftRadius: rad
		color: !root.enabled ? root.disabledColor : root.color
		implicitHeight: expandIcon.implicitHeight + root.verticalPadding * 2
		implicitWidth: implicitHeight
		radius: implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
		topLeftRadius: rad

		Behavior on rad {
			Anim {
			}
		}

		StateLayer {
			id: expandStateLayer

			color: root.textColor
			enabled: root.enabled
			rect.bottomLeftRadius: parent.bottomLeftRadius
			rect.topLeftRadius: parent.topLeftRadius

			onClicked: root.expanded = !root.expanded
		}

		MaterialIcon {
			id: expandIcon

			anchors.centerIn: parent
			anchors.horizontalCenterOffset: root.expanded ? 0 : -Math.floor(root.verticalPadding / 4)
			color: !root.enabled ? root.disabledTextColor : root.textColor
			rotation: root.expanded ? 180 : 0
			text: "expand_more"

			Behavior on anchors.horizontalCenterOffset {
				Anim {
				}
			}
			Behavior on rotation {
				Anim {
				}
			}
		}
	}

	Menu {
		id: menu

		attachSideY: root.menuOnTop ? Menu.Top : Menu.Bottom
		attachTo: expandBtn
		marginY: Appearance.spacing.small * (root.menuOnTop ? -1 : 1)
		thisSideY: root.menuOnTop ? Menu.Bottom : Menu.Top
	}
}
