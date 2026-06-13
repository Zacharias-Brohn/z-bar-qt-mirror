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
	property bool previewIsCode: looksLikeCode(previewText)
	property bool previewIsImage: false
	readonly property string previewMarkup: previewIsCode ? generateHighlightedMarkup(previewText) : previewText
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

	function escapeHtml(str): string {
		return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
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

	function generateHighlightedMarkup(text): string {
		const raw = String(text ?? "");
		const lines = raw.split("\n").map(line => highlightCodeLine(line));
		return `<div style="font-family:monospace; white-space:pre-wrap;">${lines.join("<br>")}</div>`;
	}

	function highlightCodeLine(rawLine): string {
		const line = String(rawLine ?? "");

		const kwColor = DynamicColors.palette.m3primary;
		const strColor = DynamicColors.palette.m3tertiary;
		const comColor = Qt.alpha(DynamicColors.palette.m3onSurface, 0.55);

		const keywordRe = /\b(function|class|import|const|let|var|if|else|for|while|return|switch|case|break|continue|try|catch|throw|async|await|new|null|true|false|public|private|protected|static|extends|struct|enum)\b/g;

		let out = "";
		let i = 0;

		while (i < line.length) {
			const ch = line[i];

			// Line comment
			if (line.slice(i, i + 2) === "//") {
				out += `<span style="color:${comColor};">${escapeHtml(line.slice(i))}</span>`;
				break;
			}

			// Shell/Python-style comment
			if (ch === "#" && i === 0) {
				out += `<span style="color:${comColor};">${escapeHtml(line.slice(i))}</span>`;
				break;
			}

			// Quoted string
			if (ch === "'" || ch === '"' || ch === "`") {
				const quote = ch;
				let j = i + 1;
				while (j < line.length) {
					if (line[j] === "\\") {
						j += 2;
						continue;
					}
					if (line[j] === quote) {
						j += 1;
						break;
					}
					j += 1;
				}

				out += `<span style="color:${strColor};">${escapeHtml(line.slice(i, j))}</span>`;
				i = j;
				continue;
			}

			// Plain code text until next special token
			let j = i;
			while (j < line.length) {
				const two = line.slice(j, j + 2);
				const c = line[j];

				if (two === "//")
					break;
				if (c === "'" || c === '"' || c === "`")
					break;
				if (c === "#" && j === 0)
					break;

				j += 1;
			}

			let segment = escapeHtml(line.slice(i, j));
			segment = segment.replace(keywordRe, `<span style="color:${kwColor}; font-weight:600;">$1</span>`);
			out += segment;
			i = j;
		}

		return out === "" ? "&nbsp;" : out;
	}

	function looksLikeCode(text): bool {
		const t = String(text ?? "").trim();

		if (t === "")
			return false;

		const lines = t.split("\n");

		if (lines.length < 2)
			return false;

		let score = 0;

		for (const line of lines) {
			if (/^\s{4,}|\t/.test(line))
				score += 2;

			if (/[{}()[\];]/.test(line))
				score += 1;

			if (/\b(function|class|import|const|let|var|if|else|for|while|return|switch|case|try|catch|async|await)\b/.test(line))
				score += 2;

			if (/=>|:=/.test(line))
				score += 1;
		}

		return score >= 4;
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

		previewImageSource = "";
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
