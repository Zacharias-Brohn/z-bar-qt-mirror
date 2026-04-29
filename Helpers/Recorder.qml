// pragma Singleton
//
// import Quickshell
// import QtQuick
//
// Singleton {
// 	id: root
//
// 	function start(extraArgs = []): void {
// 		needsStart = true;
// 		startArgs = extraArgs;
// 		checkProc.running = true;
// 	}
//
// 	PersistentProperties {
// 		id: props
//
// 		property real elapsed: 0
// 		property bool paused: false
// 		property bool running: false
//
// 		reloadableId: "recorder"
// 	}
//
// 	Process {
// 		id: checkProc
//
// 		command: ["pidof", "gpu-screen-recorder"]
// 		running: true
//
// 		onExited: code => {
// 			props.running = code === 0;
//
// 			if (code === 0) {
// 				if (root.needsStop) {
// 					Quickshell.execDetached(["zshell-cli"]);
// 				}
// 			}
// 		}
// 	}
// }
