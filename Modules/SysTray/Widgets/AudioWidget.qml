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
	readonly property bool hasContent: mic.visible || speaker.visible
	property color textColor: DynamicColors.palette.m3onSurface

	width: hasContent ? implicitWidth : 0

	MaterialIcon {
		id: mic

		readonly property bool shouldBeVisible: Config.bar.tray.showMicrophone

		Layout.alignment: Qt.AlignVCenter
		Layout.maximumWidth: shouldBeVisible ? implicitWidth : 0
		animate: true
		color: (Audio.sourceMuted ?? false) ? DynamicColors.palette.m3error : root.textColor
		fill: 1
		font.pointSize: Appearance.font.size.larger
		opacity: shouldBeVisible ? 1 : 0
		scale: shouldBeVisible ? 1 : 0
		text: Audio.sourceMuted ? "mic_off" : "mic"
		visible: opacity > 0

		Behavior on Layout.maximumWidth {
			Anim {
			}
		}
		Behavior on opacity {
			Anim {
			}
		}
		Behavior on scale {
			Anim {
			}
		}
	}

	MaterialIcon {
		id: speaker

		readonly property bool shouldBeVisible: Config.bar.tray.showAudio

		Layout.alignment: Qt.AlignVCenter
		Layout.maximumWidth: shouldBeVisible ? implicitWidth : 0
		animate: true
		color: Audio.muted ? DynamicColors.palette.m3error : root.textColor
		fill: 1
		font.pointSize: Appearance.font.size.larger
		opacity: shouldBeVisible ? 1 : 0
		scale: shouldBeVisible ? 1 : 0
		text: Audio.muted ? "volume_off" : "volume_up"
		visible: opacity > 0

		Behavior on Layout.maximumWidth {
			Anim {
			}
		}
		Behavior on opacity {
			Anim {
			}
		}
		Behavior on scale {
			Anim {
			}
		}
	}
}
