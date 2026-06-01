import Quickshell.Io
import Quickshell

JsonObject {
	property Apps apps: Apps {
	}
	property Battery battery: Battery {
	}
	property Color color: Color {
	}
	property string dateFormat: "ddd d MMM - hh:mm:ss"
	property bool desktopIcons: false
	property bool lidWatch: true
	property Idle idle: Idle {
	}
	property string logo: ""
	property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/Wallpapers"

	component Apps: JsonObject {
		property list<string> audio: ["pavucontrol"]
		property list<string> explorer: ["dolphin"]
		property list<string> playback: ["mpv"]
		property list<string> terminal: ["kitty"]
	}
	component Battery: JsonObject {
		property int critPerc: 5
		property list<var> popupThresholds: [
			{
				perc: 20,
				name: qsTr("Low battery"),
				message: qsTr("Battery is low"),
				icon: "battery_android_frame_2"
			},
		]
	}
	component Color: JsonObject {
		property int hyprsunsetTemp: 5000
		property string mode: "dark"
		property bool neovimColors: false
		property bool scheduleDark: false
		property int scheduleDarkEnd: 0
		property int scheduleDarkStart: 0
		property bool scheduleHyprsunset: false
		property int scheduleHyprsunsetEnd: 0
		property int scheduleHyprsunsetStart: 0
		property bool schemeGeneration: true
		property bool smart: false
	}
	component Idle: JsonObject {
		property list<var> timeouts: [
			{
				name: "Lock",
				timeout: 180,
				idleAction: "lock"
			},
			{
				name: "Screen",
				timeout: 300,
				idleAction: "dpms off",
				activeAction: "dpms on"
			}
		]
	}
}
