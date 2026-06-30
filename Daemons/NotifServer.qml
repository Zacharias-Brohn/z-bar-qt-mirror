pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import QtQuick
import ZShell
import qs.Components
import qs.Modules
import qs.Helpers
import qs.Paths
import qs.Config

Singleton {
	id: root

	readonly property var appCooldownMap: new Map()
	property alias dnd: props.dnd
	property list<Notif> list: []
	property bool loaded
	readonly property list<Notif> notClosed: list.filter(n => !n.closed)
	readonly property list<Notif> popups: list.filter(n => n.popup)
	property alias server: server

	function shouldThrottle(appName: string): bool {
		if (props.dnd || [...Visibilities.screens.values()].some(v => v.sidebar))
			return false;

		const key = (appName || "unknown").trim().toLowerCase();
		const cooldownSec = Config.notifs.appNotifCooldown;
		const cooldownMs = Math.max(0, cooldownSec * 1000);

		if (cooldownMs <= 0)
			return true;

		const now = Date.now();
		const until = appCooldownMap.get(key) ?? 0;

		if (now < until)
			return false;

		appCooldownMap.set(key, now + cooldownMs);
		return true;
	}

	onListChanged: {
		if (loaded) {
			saveTimer.restart();
		}
	}

	Timer {
		id: saveTimer

		interval: 1000

		onTriggered: storage.setText(JSON.stringify(root.notClosed.map(n => ({
					time: n.time,
					id: n.id,
					summary: n.summary,
					body: n.body,
					appIcon: n.appIcon,
					appName: n.appName,
					image: n.image,
					expireTimeout: n.expireTimeout,
					urgency: n.urgency,
					resident: n.resident,
					hasActionIcons: n.hasActionIcons,
					actions: n.actions
				}))))
	}

	PersistentProperties {
		id: props

		property bool dnd

		reloadableId: "notifs"
	}

	NotificationServer {
		id: server

		actionsSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		imageSupported: true
		keepOnReload: false
		persistenceSupported: true

		onNotification: notif => {
			notif.tracked = true;

			const is_popup = root.shouldThrottle(notif.appName);

			const comp = notifComp.createObject(root, {
				popup: is_popup,
				notification: notif
			});
			root.list = [comp, ...root.list];
		}
	}

	FileView {
		id: storage

		path: `${Paths.state}/notifs.json`
		printErrors: false

		onLoadFailed: err => {
			if (err === FileViewError.FileNotFound) {
				root.loaded = true;
				Qt.callLater(() => setText("[]"));
			}
		}
		onLoaded: {
			const data = JSON.parse(text());
			for (const notif of data)
				root.list.push(notifComp.createObject(root, notif));
			root.list.sort((a, b) => b.time - a.time);
			root.loaded = true;
		}
	}

	CustomShortcut {
		description: "Clear all notifications"
		name: "clearnotifs"

		onPressed: {
			for (const notif of root.list.slice())
				notif.close();
		}
	}

	IpcHandler {
		function clear(): void {
			for (const notif of root.list.slice())
				notif.close();
		}

		function disableDnd(): void {
			props.dnd = false;
		}

		function enableDnd(): void {
			props.dnd = true;
		}

		function isDndEnabled(): bool {
			return props.dnd;
		}

		function toggleDnd(): void {
			props.dnd = !props.dnd;
		}

		target: "notifs"
	}

	Component {
		id: notifComp

		Notif {
		}
	}

	component Notif: QtObject {
		id: notif

		property list<var> actions
		property string appIcon
		property string appName
		property string body
		property string cachedImageSource: ""
		property bool cachingImage: false
		property bool closed
		readonly property Connections conn: Connections {
			function onActionsChanged(): void {
				notif.actions = notif.notification.actions.map(a => ({
							identifier: a.identifier,
							text: a.text,
							invoke: () => a.invoke()
						}));
			}

			function onAppIconChanged(): void {
				notif.appIcon = notif.notification.appIcon;
			}

			function onAppNameChanged(): void {
				notif.appName = notif.notification.appName;
			}

			function onBodyChanged(): void {
				notif.body = notif.notification.body;
			}

			function onClosed(): void {
				notif.close();
			}

			function onExpireTimeoutChanged(): void {
				notif.expireTimeout = notif.notification.expireTimeout;
			}

			function onHasActionIconsChanged(): void {
				notif.hasActionIcons = notif.notification.hasActionIcons;
			}

			function onHintsChanged(): void {
				notif.hints = notif.notification.hints;
			}

			function onImageChanged(): void {
				notif.imageSource = notif.notification.image || "";
				notif.image = notif.imageSource;
				notif.cacheImageIfNeeded();
			}

			function onResidentChanged(): void {
				notif.resident = notif.notification.resident;
			}

			function onSummaryChanged(): void {
				notif.summary = notif.notification.summary;
			}

			function onUrgencyChanged(): void {
				notif.urgency = notif.notification.urgency;
			}

			target: notif.notification
		}
		property real expireTimeout: 5
		property bool hasActionIcons
		property var hints
		property string image
		property string imageSource
		property var locks: new Set()
		property string notifId
		property Notification notification
		property bool popup
		property bool resident
		property string summary
		property date time: new Date()
		readonly property string timeStr: {
			const diff = Time.date.getTime() - time.getTime();
			const m = Math.floor(diff / 60000);

			if (m < 1)
				return qsTr("now");

			const h = Math.floor(m / 60);
			const d = Math.floor(h / 24);

			if (d > 0)
				return `${d}d`;
			if (h > 0)
				return `${h}h`;
			return `${m}m`;
		}
		readonly property Timer timer: Timer {
			property bool paused: false
			property int remainingTime: totalTime
			property int totalTime: Config.notifs.defaultExpireTimeout

			interval: 50
			repeat: true
			running: !paused

			onTriggered: {
				remainingTime -= interval;

				if (remainingTime <= 0) {
					remainingTime = 0;
					notif.popup = false;
					stop();
				}
			}
		}
		property int urgency: NotificationUrgency.Normal

		function cacheImageIfNeeded(): void {
			const source = imageSource;

			if (!source || cachingImage)
				return;

			if (cachedImageSource === source)
				return;

			cachingImage = true;

			ZShellIo.cacheImage(Qt.resolvedUrl(source), Paths.notifimagecache, (path, url) => {
				cachedImageSource = source;
				image = path;
				cachingImage = false;
			}, () => {
				cachingImage = false;
			});
		}

		function close(): void {
			closed = true;
			if (locks.size === 0 && root.list.includes(this)) {
				root.list = root.list.filter(n => n !== this);
				notification?.dismiss();
				destroy();
			}
		}

		function lock(item: Item): void {
			locks.add(item);
		}

		function unlock(item: Item): void {
			locks.delete(item);
			if (closed)
				close();
		}

		Component.onCompleted: {
			if (!notification)
				return;

			notifId = notification.id;
			summary = notification.summary;
			body = notification.body;
			appIcon = notification.appIcon;
			appName = notification.appName;
			imageSource = notification.image || "";
			image = imageSource;
			hints = notification.hints;
			expireTimeout = notification.expireTimeout;
			urgency = notification.urgency;
			resident = notification.resident;
			hasActionIcons = notification.hasActionIcons;
			actions = notification.actions.map(a => ({
						identifier: a.identifier,
						text: a.text,
						invoke: () => a.invoke()
					}));

			cacheImageIfNeeded();
		}
	}
}
