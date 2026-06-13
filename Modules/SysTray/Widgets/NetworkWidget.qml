import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Daemons
import qs.Modules
import qs.Config
import qs.Components

RowLayout {
	id: root

	// property color barColor: DynamicColors.palette.m3primary
	property color textColor: DynamicColors.palette.m3onSurface

	MaterialIcon {
		Layout.alignment: Qt.AlignVCenter
		animate: true
		color: root.textColor // Network.connected ? root.textColor : DynamicColors.palette.m3error
		fill: 1
		font.pointSize: Appearance.font.size.larger
		text: "android_wifi_4_bar"
	}
}
