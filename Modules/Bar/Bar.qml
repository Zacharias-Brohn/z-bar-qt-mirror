pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Config
import qs.Modules.SysTray
import qs.Modules.Network
import qs.Modules.Updates

RowLayout {
	id: root

	required property Wrapper popouts
	required property ClipWrapper popoutsWrapper
	required property ShellScreen screen
	required property bool fullscreen
	readonly property int vPadding: 6
	required property PersistentProperties visibilities

	function checkPopout(x: real): void {
		const ch = childAt(x, height / 2) as WrappedLoader;

		if (!ch || ch?.id === "spacer") {
			if (!popouts.currentName.startsWith("traymenu") || Config.bar.tray.showOnHover)
				popouts.hasCurrent = false;
			return;
		}

		if (visibilities.sidebar || visibilities.dashboard || visibilities.resources || visibilities.settings)
			return;

		if (ch.id === "tray") {
			const tray = ch.item;
			const localPos = tray.mapFromItem(root, x, height / 2);
			const sub = tray.getHoveredSubItem(localPos.x, localPos.y);
			if (sub) {
				popouts.currentName = sub.id;
				popouts.currentCenter = Qt.binding(() => {
					const centerX = sub.item.mapToItem(root, sub.item.width / 2, 0).x;
					return centerX;
				});
				popouts.hasCurrent = true;
				return;
			}

			if (!popouts.currentName.startsWith("traymenu") || Config.bar.tray.showOnHover)
				popouts.hasCurrent = false;
		}

		const id = ch.id;
		const top = ch.x;
		const item = ch.item;
		const itemWidth = item.implicitWidth;

		if (id === "updates") {
			popouts.currentName = "updates";
			popouts.currentCenter = Qt.binding(() => item.mapToItem(root, itemWidth / 2, 0).x);
			popouts.hasCurrent = true;
		}
	}

	spacing: Appearance.spacing.small

	Repeater {
		id: repeater

		model: Config.bar.entries

		DelegateChooser {
			role: "id"

			DelegateChoice {
				roleValue: "hyprsunset"

				delegate: WrappedLoader {
					sourceComponent: HyprsunsetWidget {
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "spacer"

				delegate: WrappedLoader {
					Layout.fillWidth: true
				}
			}

			DelegateChoice {
				roleValue: "workspaces"

				delegate: WrappedLoader {
					sourceComponent: Workspaces {
						screen: root.screen
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "tray"

				delegate: WrappedLoader {
					sourceComponent: TrayWidget {
						loader: root
						popouts: root.popouts
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "resources"

				delegate: WrappedLoader {
					sourceComponent: Resources {
						visibilities: root.visibilities
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "updates"

				delegate: WrappedLoader {
					sourceComponent: UpdatesWidget {
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "notifBell"

				delegate: WrappedLoader {
					sourceComponent: NotifBell {
						popouts: root.popouts
						visibilities: root.visibilities
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "clock"

				delegate: WrappedLoader {
					sourceComponent: Clock {
						loader: root
						popouts: root.popouts
						visibilities: root.visibilities
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "activeWindow"

				delegate: WrappedLoader {
					sourceComponent: WindowTitle {
						bar: root
						visible: !root.fullscreen
					}
				}
			}

			DelegateChoice {
				roleValue: "network"

				delegate: WrappedLoader {
					sourceComponent: NetworkWidget {
					}
				}
			}

			DelegateChoice {
				roleValue: "media"

				delegate: WrappedLoader {
					sourceComponent: MediaWidget {
						visible: !root.fullscreen
					}
				}
			}
		}
	}

	component WrappedLoader: Loader {
		required property bool enabled
		required property string id
		required property int index

		function findFirstEnabled(): Item {
			const count = repeater.count;
			for (let i = 0; i < count; i++) {
				const item = repeater.itemAt(i);
				if (item?.enabled)
					return item;
			}
			return null;
		}

		function findLastEnabled(): Item {
			for (let i = repeater.count - 1; i >= 0; i--) {
				const item = repeater.itemAt(i);
				if (item?.enabled)
					return item;
			}
			return null;
		}

		Layout.alignment: Qt.AlignVCenter
		Layout.leftMargin: findFirstEnabled() === this ? root.vPadding : 0
		Layout.rightMargin: findLastEnabled() === this ? root.vPadding : 0
		active: enabled
		visible: enabled
	}
}
