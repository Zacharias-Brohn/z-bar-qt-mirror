import Quickshell.Io
import Quickshell.Services.UPower

JsonObject {
	property int blurAmount: 40
	property bool enableFprint: true
	property int maxFprintTries: 3
	property bool lidWatch: UPower.displayDevice.isLaptopBattery
	property bool recolorLogo: false
	property bool showNotifContent: false
	property bool showNotifIcon: true
	property Sizes sizes: Sizes {
	}

	component Sizes: JsonObject {
		property int centerWidth: 600
		property real heightMult: 0.7
		property real ratio: 16 / 9
	}
}
