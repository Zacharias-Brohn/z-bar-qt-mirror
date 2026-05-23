import Quickshell.Io

JsonObject {
	property Presets presets: Presets {
	}
	property string schemeType: "vibrant"

	component Presets: JsonObject {
		property string accent: ""
		property string name: ""
		property string variant: ""
	}
}
