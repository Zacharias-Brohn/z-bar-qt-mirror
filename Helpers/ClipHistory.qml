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
	property list<string> entries: []
	property real pasteDelay: 0.05
	readonly property var preparedEntries: entries.map(a => ({
				name: Fuzzy.prepare(`${a.replace(/^\s*\S+\s+/, "")}`),
				entry: a
			}))
	property real scoreThreshold: 0.2

	function copy(entry) {
		Quickshell.execDetached(["bash", "-c", `printf '${shellSingleQuoteEscape(entry)}' | ${root.cliphistBinary} decode | wl-copy`]);
	}

	function deleteEntry(entry) {
		deleteProc.deleteEntry(entry);
	}

	function entryIsImage(entry) {
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

	function paste(entry) {
		Quickshell.execDetached(["bash", "-c", `printf '${shellSingleQuoteEscape(entry)}' | ${root.cliphistBinary} decode | wl-copy && wl-paste`]);
	}

	function refresh() {
		readProc.buffer = [];
		readProc.running = true;
	}

	function shellSingleQuoteEscape(str) {
		return String(str).replace(/'/g, "'\\''");
	}

	function wipe() {
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
