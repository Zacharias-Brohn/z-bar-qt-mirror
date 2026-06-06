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
	property color colour: type == CustomSplitButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondaryContainer
	property bool disabled
	property color disabledColour: Qt.alpha(DynamicColors.palette.m3onSurface, 0.1)
	property color disabledTextColour: Qt.alpha(DynamicColors.palette.m3onSurface, 0.38)
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
	property color textColour: type == CustomSplitButton.Filled ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
	readonly property alias textRow: textRow
	property int type: CustomSplitButton.Filled
	property real verticalPadding: Appearance.padding.small

	spacing: Math.floor(Appearance.spacing.extraSmall)

	CustomRect {
		bottomRightRadius: Appearance.rounding.small / 2
		color: root.disabled ? root.disabledColour : root.colour
		implicitHeight: expandBtn.implicitHeight
		implicitWidth: Math.max(root.minLeftWidth, textRow.implicitWidth + root.horizontalPadding * 2)
		radius: implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
		topRightRadius: Appearance.rounding.small / 2

		StateLayer {
			id: stateLayer

			bottomRightRadius: parent.bottomRightRadius
			color: root.textColour
			disabled: root.disabled
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
				color: root.disabled ? root.disabledTextColour : root.textColour
				fill: 1
				text: root.active?.activeIcon ?? root.fallbackIcon
			}

			CustomText {
				id: label

				Layout.alignment: Qt.AlignVCenter
				Layout.preferredWidth: implicitWidth
				animate: true
				clip: true
				color: root.disabled ? root.disabledTextColour : root.textColour
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
		color: root.disabled ? root.disabledColour : root.colour
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

			color: root.textColour
			disabled: root.disabled
			rect.bottomLeftRadius: parent.bottomLeftRadius
			rect.topLeftRadius: parent.topLeftRadius

			onClicked: root.expanded = !root.expanded
		}

		MaterialIcon {
			id: expandIcon

			anchors.centerIn: parent
			anchors.horizontalCenterOffset: root.expanded ? 0 : -Math.floor(root.verticalPadding / 4)
			color: root.disabled ? root.disabledTextColour : root.textColour
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
