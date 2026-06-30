import Quickshell.Io

JsonObject {
	property bool enabled: true
	property int mediaUpdateInterval: 500
	property Performance performance: Performance {
	}
	property int resourceUpdateInterval: 1000
	property Sizes sizes: Sizes {
	}

	component Performance: JsonObject {
		property bool enabled: true
		property bool showBattery: true
		property bool showCpu: true
		property bool showGpu: true
		property bool showMemory: true
		property bool showNetwork: true
		property bool showStorage: true
	}
	component Sizes: JsonObject {
		readonly property int dateTimeWidth: 110
		readonly property int infoIconSize: 25
		readonly property int infoWidth: 200
		readonly property int mediaCoverArtSize: 150
		readonly property int mediaProgressSweep: 180
		readonly property int mediaProgressThickness: 8
		readonly property int mediaVisualizerSize: 200
		readonly property int mediaWidth: 200
		readonly property int resourceProgessThickness: 10
		readonly property int resourceSize: 200
		readonly property int tabIndicatorHeight: 3
		readonly property int tabIndicatorSpacing: 5
		readonly property int weatherWidth: 250
	}
}
