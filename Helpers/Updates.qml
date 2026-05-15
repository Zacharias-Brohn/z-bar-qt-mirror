pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Paths
import qs.Config

Singleton {
	id: root

	property int availableUpdates: 0
	property string cmd: ""
	property bool commandReady
	property bool loaded
	property double now: Date.now()
	property var updates: ({})
	property bool updating
	property string updatingPackage: ""

	function formatUpdateTime(timestamp) {
		const diffMs = root.now - timestamp;
		const minuteMs = 60 * 1000;
		const hourMs = 60 * minuteMs;
		const dayMs = 24 * hourMs;

		if (diffMs < minuteMs)
			return "just now";

		if (diffMs < hourMs)
			return Math.floor(diffMs / minuteMs) + " min ago";

		if (diffMs < 48 * hourMs)
			return Math.floor(diffMs / hourMs) + " hr ago";

		return Qt.formatDateTime(new Date(timestamp), "dd hh:mm");
	}

	function performPackageUpdate(pkg: string): void {
		if (root.cmd === "pacman")
			pkgUpdateProc.command = ["pkexec", root.cmd, "--noconfirm", "-Sy", pkg];
		else
			pkgUpdateProc.command = [root.cmd, "--noconfirm", "--sudo", "pkexec", "-Sy", pkg];
		pkgUpdateProc.running = true;
	}

	function performSystemUpdate(): void {
		if (root.cmd === "pacman")
			sysUpdateProc.command = ["pkexec", root.cmd, "--noconfirm", "-Syu"];
		else
			sysUpdateProc.command = [root.cmd, "--noconfirm", "--sudo", "pkexec", "-Syu"];
		sysUpdateProc.running = true;
	}

	onUpdatesChanged: {
		if (!root.loaded)
			return;

		saveTimer.restart();
		availableUpdates = Object.keys(updates).length;
	}

	Timer {
		interval: 1
		repeat: true
		running: Config.services.updates

		onTriggered: {
			if (!root.loaded || !root.commandReady)
				return;

			if (Config.services.updates)
				updatesProc.running = true;
			interval = 5000;
		}
	}

	Timer {
		interval: 60000
		repeat: true
		running: true

		onTriggered: root.now = Date.now()
	}

	Process {
		id: cmdDetect

		command: ["sh", "-c", "command -v checkupdates || command -v yay || command -v paru"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				const cmd = this.text.trim();
				let helper;

				if (cmd.length > 0) {
					helper = cmd.split("/").pop();
				} else {
					helper = "pacman";
				}

				if (helper === "checkupdates") {
					updatesProc.command = [helper];
				} else {
					updatesProc.command = [helper, "-Qu"];
				}
				root.commandReady = true;
			}
		}
	}

	Process {
		id: updateCmdDetect

		command: ["sh", "-c", "command -v yay || command -v paru"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				const cmd = this.text.trim();
				let helper;

				if (cmd.length > 0) {
					helper = cmd.split("/").pop();
				} else {
					helper = "pacman";
				}

				root.cmd = helper;
			}
		}
	}

	Process {
		id: updatesProc

		command: []
		running: false

		stdout: StdioCollector {
			onStreamFinished: {
				const output = this.text;
				const lines = output.trim().split("\n").filter(line => line.length > 0);

				const oldMap = root.updates;
				const now = Date.now();

				root.updates = lines.reduce((acc, pkg) => {
					acc[pkg] = oldMap[pkg] ?? now;
					return acc;
				}, {});
				root.availableUpdates = lines.length;
			}
		}
	}

	Process {
		id: sysUpdateProc

		command: []
		running: false

		stdout: StdioCollector {
			onStreamFinished: {
				root.updating = false;
			}
		}

		onRunningChanged: {
			if (running)
				root.updating = true;
		}
	}

	Process {
		id: pkgUpdateProc

		command: []
		running: false

		stdout: StdioCollector {
			onStreamFinished: {
				root.updating = false;
			}
		}

		onRunningChanged: {
			if (running) {
				root.updatingPackage = command[command.length - 1];
				root.updating = true;
			}
		}
	}

	Timer {
		id: saveTimer

		interval: 1000

		onTriggered: storage.setText(JSON.stringify(root.updates))
	}

	FileView {
		id: storage

		path: `${Paths.state}/updates.json`

		onLoadFailed: err => {
			if (err === FileViewError.FileNotFound) {
				root.updates = ({});
				root.loaded = true;
				setText("{}");
				return;
			}

			root.updates = ({});
			root.loaded = true;
		}
		onLoaded: {
			try {
				const data = JSON.parse(text());
				root.updates = data && typeof data === "object" && !Array.isArray(data) ? data : {};
			} catch (e) {
				root.updates = ({});
			}

			root.loaded = true;
		}
	}
}
