pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root

	readonly property alias elapsed: props.elapsed
	property bool needsPause
	property bool needsStart
	property bool needsStop
	readonly property alias paused: props.paused
	readonly property alias running: props.running
	property list<string> startArgs

	function start(extraArgs = []): void {
		needsStart = true;
		startArgs = extraArgs;
		checkProc.running = true;
	}

	function stop(): void {
		needsStop = true;
		checkProc.running = true;
	}

	function togglePause(): void {
		needsPause = true;
		checkProc.running = true;
	}

	PersistentProperties {
		id: props

		property real elapsed: 0
		property bool paused: false
		property bool running: false

		reloadableId: "recorder"
	}

	Process {
		id: checkProc

		command: ["pidof", "gpu-screen-recorder"]
		running: true

		onExited: code => {
			props.running = code === 0;

			if (code === 0) {
				if (root.needsStop) {
					Quickshell.execDetached(["zshell-cli", "record", "record"]);
					props.running = false;
					props.paused = false;
				} else if (root.needsPause) {
					Quickshell.execDetached(["zshell-cli", "record", "record", "-p"]);
					props.paused = !props.paused;
				}
			} else if (root.needsStart) {
				Quickshell.execDetached(["zshell-cli", "record", "record", ...root.startArgs]);
				props.running = true;
				props.paused = false;
				props.elapsed = 0;
			}

			root.needsStart = false;
			root.needsStop = false;
			root.needsPause = false;
		}
	}

	Connections {
		function onSecondsChanged(): void {
			props.elapsed++;
		}

		target: Time // qmllint disable incompatible-type
	}
}
