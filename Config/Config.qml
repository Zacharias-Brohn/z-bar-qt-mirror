pragma Singleton

import Quickshell
import Quickshell.Io
import ZShell
import QtQuick
import qs.Helpers
import qs.Paths

Singleton {
	id: root

	property alias appearance: adapter.appearance
	property alias background: adapter.background
	property alias bar: adapter.bar
	property alias clipboard: adapter.clipboard
	property alias colors: adapter.colors
	property alias dashboard: adapter.dashboard
	property alias dock: adapter.dock
	property alias general: adapter.general
	property alias launcher: adapter.launcher
	property alias lock: adapter.lock
	property bool migratingLegacyBar: false
	property alias notifs: adapter.notifs
	property alias osd: adapter.osd
	property alias overview: adapter.overview
	property bool recentlySaved: false
	property alias screenshot: adapter.screenshot
	property alias services: adapter.services
	property alias sidebar: adapter.sidebar
	property alias utilities: adapter.utilities

	function applyLegacyBarConfig(legacy): void {
		const tray = legacy.tray ?? {};
		const popouts = legacy.popouts ?? {};

		bar.autoHide = pick(legacy.autoHide, bar.autoHide);
		bar.hideWhenNotif = pick(legacy.hideWhenNotif, bar.hideWhenNotif);
		bar.rounding = pick(legacy.rounding, bar.rounding);
		bar.border = pick(legacy.border, bar.border);
		bar.smoothing = pick(legacy.smoothing, bar.smoothing);
		bar.height = pick(legacy.height, bar.height);
		bar.tray.trayIconSize = pick(tray.trayIconSize, bar.tray.trayIconSize);
		bar.popouts.tray = pick(popouts.tray, bar.popouts.tray);
		bar.popouts.audio = pick(popouts.audio, bar.popouts.audio);
		bar.popouts.activeWindow = pick(popouts.activeWindow, bar.popouts.activeWindow);
		bar.popouts.resources = pick(popouts.resources, bar.popouts.resources);
		bar.popouts.clock = pick(popouts.clock, bar.popouts.clock);
		bar.popouts.network = pick(popouts.network, bar.popouts.network);
		bar.popouts.upower = pick(popouts.upower, bar.popouts.upower);
		bar.entries = pick(legacy.entries, bar.entries);
	}

	function migrateLegacyBarConfig(raw): bool {
		if (raw.bar !== undefined || raw.barConfig === undefined)
			return false;

		migratingLegacyBar = true;
		applyLegacyBarConfig(raw.barConfig);
		migratingLegacyBar = false;
		return true;
	}

	function pick(value, fallback) {
		return value === undefined ? fallback : value;
	}

	function save(): void {
		saveTimer.restart();
		recentlySaved = true;
		recentSaveCooldown.restart();
	}

	function saveNoToast(): void {
		saveTimer.restart();
	}

	ElapsedTimer {
		id: timer
	}

	Timer {
		id: saveTimer

		interval: 500

		onTriggered: {
			timer.restart();
			fileView.writeAdapter();
		}
	}

	Timer {
		id: recentSaveCooldown

		interval: 2000

		onTriggered: {
			root.recentlySaved = false;
		}
	}

	FileView {
		id: fileView

		path: `${Paths.config}/config.json`
		watchChanges: true

		onAdapterUpdated: {
			if (!root.migratingLegacyBar)
				root.save();
		}
		onFileChanged: {
			if (!root.recentlySaved) {
				timer.restart();
				reload();
			} else {
				reload();
			}
		}
		onLoadFailed: err => {
			if (err !== FileViewError.FileNotFound)
				Toaster.toast(qsTr("Failed to read config"), FileViewError.toString(err), "settings_alert", Toast.Warning);
		}
		onLoaded: {
			ModeScheduler.checkStartup();
			Hyprsunset.checkStartup();
			try {
				const raw = JSON.parse(text());
				const migrated = root.migrateLegacyBarConfig(raw);
				if (migrated)
					root.save();

				const elapsed = timer.elapsedMs();

				if (adapter.utilities.toasts.configLoaded && !root.recentlySaved) {
					Toaster.toast(qsTr("Config loaded"), qsTr("Config loaded in %1ms").arg(elapsed), "rule_settings");
				} else if (adapter.utilities.toasts.configLoaded && root.recentlySaved) {
					Toaster.toast(qsTr("Config saved"), qsTr("Config reloaded in %1ms").arg(elapsed), "settings_alert");
				}
			} catch (e) {
				Toaster.toast(qsTr("Failed to load config"), e.message, "settings_alert", Toast.Error);
			}
		}
		onSaveFailed: err => Toaster.toast(qsTr("Failed to save config"), FileViewError.toString(err), "settings_alert", Toast.Error)

		JsonAdapter {
			id: adapter

			property AppearanceConf appearance: AppearanceConf {
			}
			property BackgroundConfig background: BackgroundConfig {
			}
			property BarConfig bar: BarConfig {
			}
			property ClipboardConfig clipboard: ClipboardConfig {
			}
			property Colors colors: Colors {
			}
			property DashboardConfig dashboard: DashboardConfig {
			}
			property DockConfig dock: DockConfig {
			}
			property General general: General {
			}
			property Launcher launcher: Launcher {
			}
			property LockConf lock: LockConf {
			}
			property NotifConfig notifs: NotifConfig {
			}
			property Osd osd: Osd {
			}
			property Overview overview: Overview {
			}
			property Screenshot screenshot: Screenshot {
			}
			property Services services: Services {
			}
			property SidebarConfig sidebar: SidebarConfig {
			}
			property UtilConfig utilities: UtilConfig {
			}
		}
	}
}
