import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property list<real> animCurve: Appearance.anim.curves.expressiveDefaultSpatial
	property int animLength: Appearance.anim.durations.expressiveDefaultSpatial
	readonly property alias content: content
	readonly property Item current: (content.item as Content)?.current ?? null
	property real currentCenter
	property alias currentName: popoutState.currentName
	property string detachedMode
	property alias hasCurrent: popoutState.hasCurrent
	readonly property bool isDetached: detachedMode.length > 0
	readonly property real nonAnimHeight: children.find(c => c.shouldBeActive)?.implicitHeight ?? content.implicitHeight
	readonly property real nonAnimWidth: children.find(c => c.shouldBeActive)?.implicitWidth ?? content.implicitWidth
	required property real offsetScale
	property string queuedMode
	required property ShellScreen screen
	property alias state: popoutState

	function close(): void {
		hasCurrent = false;
		detachedMode = "";
	}

	function detach(mode: string): void {
		setAnims(true);
		if (mode === "winfo") {
			detachedMode = mode;
		} else {
			queuedMode = mode;
			detachedMode = "any";
		}
		setAnims(false);
		focus = true;
	}

	function setAnims(detach: bool): void {
		const type = `expressive${detach ? "Slow" : "Default"}Spatial`;
		animLength = Appearance.anim.durations[type];
		animCurve = Appearance.anim.curves[type];
	}

	focus: hasCurrent
	implicitHeight: nonAnimHeight
	implicitWidth: nonAnimWidth

	Behavior on implicitHeight {
		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}
	Behavior on implicitWidth {
		enabled: root.offsetScale < 1

		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}

	PopoutState {
		id: popoutState
	}

	Comp {
		id: content

		// anchors.horizontalCenter: parent.horizontalCenter
		// anchors.top: parent.top
		anchors.centerIn: parent
		shouldBeActive: root.hasCurrent && !root.detachedMode

		sourceComponent: Content {
			popouts: popoutState
			screen: root.screen
		}
	}

	// Comp {
	// 	id: winfo
	//
	// 	anchors.centerIn: parent
	// 	shouldBeActive: root.detachedMode === "winfo"
	//
	// 	sourceComponent: WindowInfo {
	// 		client: Hypr.activeToplevel
	// 		screen: root.screen
	// 	}
	// }
	//
	// Comp {
	// 	id: controlCenter
	//
	// 	anchors.centerIn: parent
	// 	shouldBeActive: root.detachedMode === "any"
	//
	// 	sourceComponent: ControlCenter {
	// 		active: root.queuedMode
	// 		screen: root.screen
	//
	// 		onClose: root.close()
	// 	}
	// }

	component Comp: Loader {
		id: comp

		property bool shouldBeActive

		active: false
		opacity: 0

		// Makes the loader load on the same frame shouldBeActive becomes true, which ensures size is set
		states: State {
			name: "active"
			when: comp.shouldBeActive

			PropertyChanges {
				comp.active: true
				comp.opacity: 1
			}
		}
		transitions: [
			Transition {
				from: ""
				to: "active"

				SequentialAnimation {
					PropertyAction {
						property: "active"
					}

					Anim {
						property: "opacity"
					}
				}
			},
			Transition {
				from: "active"
				to: ""

				SequentialAnimation {
					Anim {
						property: "opacity"
					}

					PropertyAction {
						property: "active"
					}
				}
			}
		]
	}
}
