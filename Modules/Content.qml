pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import qs.Config
import qs.Components
import qs.Modules.WSOverview
import qs.Modules.SysTray.Popouts
import qs.Modules.Updates

Item {
	id: root

	readonly property Item current: currentPopout?.item ?? null
	readonly property Popout currentPopout: content.children.find(c => c.shouldBeActive) ?? null
	required property PopoutState popouts

	implicitHeight: (currentPopout?.implicitHeight ?? 0) + Appearance.padding.small * 2
	implicitWidth: (currentPopout?.implicitWidth ?? 0) + Appearance.padding.small * 2

	Item {
		id: content

		anchors.fill: parent

		Popout {
			name: "audio"

			sourceComponent: AudioPopout {
				wrapper: root.wrapper
			}
		}

		Repeater {
			model: ScriptModel {
				values: [...SystemTray.items.values]
			}

			Popout {
				id: trayMenu

				required property int index
				required property SystemTrayItem modelData

				name: `traymenu${index}`
				sourceComponent: trayMenuComponent

				Connections {
					function onHasCurrentChanged(): void {
						if (root.popouts.hasCurrent && trayMenu.shouldBeActive) {
							trayMenu.sourceComponent = null;
							trayMenu.sourceComponent = trayMenuComponent;
						}
					}

					target: root.popouts
				}

				Component {
					id: trayMenuComponent

					TrayMenuPopout {
						popouts: root.popouts
						trayItem: trayMenu.modelData.menu
					}
				}
			}
		}

		Popout {
			name: "upower"

			sourceComponent: UPowerPopout {
			}
		}

		Popout {
			name: "network"

			sourceComponent: NetworkPopout {
				wrapper: root.popouts
			}
		}

		Popout {
			name: "updates"

			sourceComponent: UpdatesPopout {
				wrapper: root.popouts
			}
		}
	}

	component Popout: Loader {
		id: popout

		required property string name
		readonly property bool shouldBeActive: root.popouts.currentName === name

		active: false
		// anchors.horizontalCenter: parent.horizontalCenter
		// anchors.top: parent.top
		// anchors.topMargin: 5
		anchors.centerIn: parent
		opacity: 0
		scale: 0.8

		states: State {
			name: "active"
			when: popout.shouldBeActive

			PropertyChanges {
				popout.active: true
				popout.opacity: 1
				popout.scale: 1
			}
		}
		transitions: [
			Transition {
				from: "active"
				to: ""

				SequentialAnimation {
					Anim {
						duration: MaterialEasing.expressiveEffectsTime
						properties: "opacity,scale"
					}

					PropertyAction {
						property: "active"
						target: popout
					}
				}
			},
			Transition {
				from: ""
				to: "active"

				SequentialAnimation {
					PropertyAction {
						property: "active"
						target: popout
					}

					Anim {
						properties: "opacity,scale"
					}
				}
			}
		]
	}
}
