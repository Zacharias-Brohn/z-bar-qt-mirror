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

	property color barColor: DynamicColors.palette.m3primary
	property color textColor: DynamicColors.palette.m3onSurface

	MaterialIcon {
		id: mic

		Layout.alignment: Qt.AlignVCenter
		animate: true
		color: (Audio.sourceMuted ?? false) ? DynamicColors.palette.m3error : root.textColor
		fill: 1
		font.pointSize: Appearance.font.size.larger
		text: Audio.sourceMuted ? "mic_off" : "mic"
	}

	MaterialIcon {
		Layout.alignment: Qt.AlignVCenter
		animate: true
		color: Audio.muted ? DynamicColors.palette.m3error : root.textColor
		fill: 1
		font.pointSize: Appearance.font.size.larger
		text: Audio.muted ? "volume_off" : "volume_up"
	}
}
