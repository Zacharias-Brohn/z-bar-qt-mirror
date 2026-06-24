pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Config
import qs.Helpers
import qs.Modules.SysTray
import qs.Modules.SysTray.Widgets

Item {
	id: root

	readonly property int contentHeight: Config.barConfig.height + padding * 2
	readonly property int exclusiveZone: Config.barConfig.autoHide ? Config.barConfig.border : contentHeight
	required property bool fullscreen
	property bool isHovered
	readonly property int padding: Math.max(Appearance.padding.smaller, Config.barConfig.border)
	required property Wrapper popouts
	required property ClipWrapper popoutsWrapper
	required property ShellScreen screen
	readonly property bool shouldBeVisible: !fullscreen && (!Config.barConfig.autoHide || visibilities.bar || isHovered)
	readonly property int vPadding: 6
	required property PersistentProperties visibilities

	function checkPopout(x: real): void {
		content.item?.checkPopout(x);
	}

	implicitHeight: fullscreen ? 0 : Config.barConfig.border
	visible: height > Config.barConfig.border

	states: State {
		name: "visible"
		when: root.shouldBeVisible

		PropertyChanges {
			root.implicitHeight: root.contentHeight
		}
	}
	transitions: [
		Transition {
			from: ""
			to: "visible"

			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitHeight"
				target: root
			}
		},
		Transition {
			from: "visible"
			to: ""

			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitHeight"
				target: root
			}
		}
	]

	Loader {
		id: content

		active: root.shouldBeVisible || root.visible
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right

		sourceComponent: Bar {
			fullscreen: root.fullscreen
			height: root.contentHeight
			popouts: root.popouts
			popoutsWrapper: root.popoutsWrapper
			screen: root.screen
			visibilities: root.visibilities
		}
	}
}
