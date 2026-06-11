import Quickshell.Io

JsonObject {
	property bool enabled: true
	property int maxEntriesShown: 10
	property Sizes sizes: Sizes {
	}

	component Sizes: JsonObject {
		property int itemHeight: 60
		property int width: 500
	}
}
