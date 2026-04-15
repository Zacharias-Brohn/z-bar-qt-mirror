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
	readonly property alias controlCenter: controlCenter
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
	readonly property alias winfo: winfo

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
		enabled: root.offsetScale < 1

		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}
	Behavior on implicitWidth {
		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}

	Keys.onEscapePressed: {
		// Forward escape to password popout if active, otherwise close
		if (currentName === "wirelesspassword" && content.item) {
			const passwordPopout = (content.item as Content)?.children.find(c => c.name === "wirelesspassword");
			if (passwordPopout && passwordPopout.item) {
				passwordPopout.item.closeDialog();
				return;
			}
		}
		close();
	}
	Keys.onPressed: event => {
		// Don't intercept keys when password popout is active - let it handle them
		if (currentName === "wirelesspassword") {
			event.accepted = false;
		}
	}

	PopoutState {
		id: popoutState

		onDetachRequested: mode => root.detach(mode)
	}

	HyprlandFocusGrab {
		active: root.isDetached
		windows: [QsWindow.window]

		onCleared: root.close()
	}

	Binding {
		property: "WlrLayershell.keyboardFocus"
		target: QsWindow.window
		value: WlrKeyboardFocus.OnDemand
		when: root.isDetached || (root.hasCurrent && root.currentName === "wirelesspassword")
	}

	Comp {
		id: content

		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		shouldBeActive: root.hasCurrent && !root.detachedMode

		sourceComponent: Content {
			popouts: popoutState
		}
	}

	Comp {
		id: winfo

		anchors.centerIn: parent
		shouldBeActive: root.detachedMode === "winfo"

		sourceComponent: WindowInfo {
			client: Hypr.activeToplevel
			screen: root.screen
		}
	}

	Comp {
		id: controlCenter

		anchors.centerIn: parent
		shouldBeActive: root.detachedMode === "any"

		sourceComponent: ControlCenter {
			active: root.queuedMode
			screen: root.screen

			onClose: root.close()
		}
	}

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
