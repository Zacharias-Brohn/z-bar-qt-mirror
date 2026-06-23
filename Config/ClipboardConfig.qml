import Quickshell.Io

JsonObject {
	property bool enabled: true
	property int maxEntriesShown: 10
	property Sizes sizes: Sizes {
	}

	component Sizes: JsonObject {
		property int itemHeight: 60
		property int minPreviewWidth: 200
		property int previewWidth: 500
		property int width: 500
	}
}
