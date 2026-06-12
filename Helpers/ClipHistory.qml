pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import "../scripts/fuzzysort.js" as Fuzzy

Singleton {
	id: root

	property string cliphistBinary: "cliphist"
	property string currentEntry: ""
	property list<string> entries: []
	property real pasteDelay: 0.05
	readonly property var preparedEntries: entries.map(a => ({
				name: Fuzzy.prepare(displayText(a)),
				entry: a
			}))
	property string previewImageFile: "/tmp/qs-cliphist-preview.img"
	property string previewImageSource: ""
	property bool previewIsImage: false
	property string previewText: ""
	property int previewToken: 0
	property real scoreThreshold: 0.2

	function copy(entry): void {
		Quickshell.execDetached(["bash", "-c", `printf '${shellSingleQuoteEscape(entry)}' | ${root.cliphistBinary} decode | wl-copy`]);
	}

	function deleteEntry(entry): void {
		deleteProc.deleteEntry(entry);
	}

	function displayText(entry): string {
		return entry.replace(/^\s*\d+\s+/, "");
	}

	function entryIsImage(entry): bool {
		return !!(/^\d+\t\[\[.*binary data.*\d+x\d+.*\]\]$/.test(entry));
	}

	function fuzzyQuery(search: string): var {
		if (search.trim() === "") {
			return entries;
		}
		return Fuzzy.go(search, preparedEntries, {
			all: true,
			key: "name"
		}).map(r => {
			return r.obj.entry;
		});
	}

	function paste(entry): void {
		Quickshell.execDetached(["bash", "-c", `printf '${shellSingleQuoteEscape(entry)}' | ${root.cliphistBinary} decode | wl-copy && wl-paste`]);
	}

	function refresh(): void {
		readProc.buffer = [];
		readProc.running = true;
	}

	function refreshPreview(): void {
		previewToken += 1;
		const token = previewToken;

		if (!currentEntry) {
			previewText = "";
			previewImageSource = "";
			previewIsImage = false;
			return;
		}

		previewIsImage = entryIsImage(currentEntry);

		if (previewIsImage) {
			previewImageProc.token = token;
			previewImageProc.running = true;
		} else {
			previewTextProc.token = token;
			previewTextProc.running = true;
		}
	}

	function shellSingleQuoteEscape(str): string {
		return String(str).replace(/'/g, "'\\''");
	}

	function wipe(): void {
		wipeProc.running = true;
	}

	Process {
		id: deleteProc

		property string entry: ""

		function deleteEntry(entry) {
			deleteProc.entry = entry;
			deleteProc.running = true;
			deleteProc.entry = "";
		}

		command: ["bash", "-c", `echo '${root.shellSingleQuoteEscape(deleteProc.entry)}' | ${root.cliphistBinary} delete`]

		onExited: (exitCode, exitStatus) => {
			root.refresh();
		}
	}

	Process {
		id: wipeProc

		command: [root.cliphistBinary, "wipe"]

		onExited: (exitCode, exitStatus) => {
			root.refresh();
		}
	}

	Connections {
		function onClipboardTextChanged() {
			delayedUpdateTimer.restart();
		}

		target: Quickshell
	}

	Timer {
		id: delayedUpdateTimer

		interval: 50
		repeat: false

		onTriggered: {
			root.refresh();
		}
	}

	Process {
		id: previewTextProc

		property int token: 0

		command: ["bash", "-c", `
            printf '%s' '${root.shellSingleQuoteEscape(root.currentEntry)}' | ${root.cliphistBinary} decode
        `]
		running: false

		stdout: StdioCollector {
			onStreamFinished: {
				if (previewTextProc.token !== root.previewToken)
					return;
				root.previewText = this.text;
			}
		}
	}

	Process {
		id: previewImageProc

		property int token: 0

		command: ["bash", "-c", `
            set -euo pipefail
            tmp='${root.shellSingleQuoteEscape(root.previewImageFile)}'
            printf '%s' '${root.shellSingleQuoteEscape(root.currentEntry)}' | ${root.cliphistBinary} decode > "$tmp"
        `]
		running: false

		onExited: (exitCode, exitStatus) => {
			if (token !== root.previewToken)
				return;
			if (exitCode !== 0) {
				console.error("[Cliphist] image preview failed", exitCode, exitStatus);
				return;
			}

			root.previewImageSource = "";
			Qt.callLater(() => {
				root.previewImageSource = `file://${root.previewImageFile}`;
			});
		}
	}

	Process {
		id: readProc

		property list<string> buffer: []

		command: [root.cliphistBinary, "list"]

		stdout: SplitParser {
			onRead: line => {
				readProc.buffer.push(line);
			}
		}

		onExited: (exitCode, exitStatus) => {
			if (exitCode === 0) {
				root.entries = readProc.buffer;
			} else {
				console.error("[Cliphist] Failed to refresh with code", exitCode, "and status", exitStatus);
			}
		}
	}

	IpcHandler {
		function update(): void {
			root.refresh();
		}

		target: "cliphistService"
	}
}
