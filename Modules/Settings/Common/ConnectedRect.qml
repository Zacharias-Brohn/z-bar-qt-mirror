import QtQuick
import qs.Components
import qs.Config

CustomRect {
	id: root

	property bool first
	property bool last
	property string settingAnchor

	function flashHighlight(): void {
		flash.restart();
	}

	bottomLeftRadius: last ? Appearance.rounding.large : Appearance.rounding.extraSmall
	bottomRightRadius: last ? Appearance.rounding.large : Appearance.rounding.extraSmall
	color: DynamicColors.tPalette.m3surfaceContainer
	topLeftRadius: first ? Appearance.rounding.large : Appearance.rounding.extraSmall
	topRightRadius: first ? Appearance.rounding.large : Appearance.rounding.extraSmall

	CustomRect {
		id: highlight

		anchors.fill: parent
		bottomLeftRadius: parent.bottomLeftRadius
		bottomRightRadius: parent.bottomRightRadius
		color: DynamicColors.palette.m3primary
		opacity: 0
		radius: parent.radius
		topLeftRadius: parent.topLeftRadius
		topRightRadius: parent.topRightRadius

		SequentialAnimation {
			id: flash

			Anim {
				duration: Appearance.anim.durations.small
				property: "opacity"
				target: highlight
				to: 0.2
			}

			Anim {
				duration: Appearance.anim.durations.normal
				property: "opacity"
				target: highlight
				to: 0.08
			}

			Anim {
				duration: Appearance.anim.durations.small
				property: "opacity"
				target: highlight
				to: 0.2
			}

			Anim {
				duration: Appearance.anim.durations.extraLarge
				property: "opacity"
				target: highlight
				to: 0
			}
		}
	}
}
