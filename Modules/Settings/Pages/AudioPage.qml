pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Daemons
import qs.Config
import qs.Components
import qs.Modules.Settings.Common
import qs.Helpers

PageBase {
	id: root

	title: qsTr("Audio")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		// Output
		SliderRow {
			enabled: !Audio.muted
			first: true
			icon: Icons.getVolumeIcon(Audio.volume, Audio.muted)
			label: qsTr("Output")
			value: Audio.volume
			valueLabel: Math.round(value * 100) + "%"

			onMoved: v => Audio.setVolume(v)
		}

		ToggleRow {
			checked: Audio.muted
			text: qsTr("Muted")

			onToggled: Audio.setStreamMuted(Audio.sink, checked)
		}

		AudioDeviceList {
			currentId: Audio.sink?.id ?? -1
			iconName: "speaker"
			nodes: Audio.sinks
			placeholderIcon: "speaker"
			placeholderText: qsTr("No output devices")

			onSelected: node => Audio.setAudioSink(node)
		}

		// Input
		SliderRow {
			Layout.topMargin: Appearance.spacing.large - parent.spacing
			enabled: !Audio.sourceMuted
			first: true
			icon: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
			label: qsTr("Input")
			value: Audio.sourceVolume
			valueLabel: Math.round(value * 100) + "%"

			onMoved: v => Audio.setSourceVolume(v)
		}

		ToggleRow {
			checked: Audio.sourceMuted
			text: qsTr("Muted")

			onToggled: Audio.setStreamMuted(Audio.source, checked)
		}

		AudioDeviceList {
			currentId: Audio.source?.id ?? -1
			iconName: "mic"
			nodes: Audio.sources
			placeholderIcon: "mic_off"
			placeholderText: qsTr("No input devices")

			onSelected: node => Audio.setAudioSource(node)
		}

		// Per-app volumes
		ConnectedRect {
			Layout.fillWidth: true
			Layout.topMargin: Appearance.spacing.large - parent.spacing
			first: true
			implicitHeight: appLayout.implicitHeight + appLayout.anchors.margins * 2
			last: true

			StateLayer {
				onClicked: root.sState.openSubPage(1)
			}

			RowLayout {
				id: appLayout

				anchors.fill: parent
				anchors.leftMargin: Appearance.padding.largeIncreased
				anchors.margins: Appearance.padding.normal
				anchors.rightMargin: Appearance.padding.largeIncreased
				spacing: Appearance.spacing.small

				MaterialIcon {
					font.pointSize: Appearance.font.size.medium
					text: "tune"
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 0

					CustomText {
						Layout.fillWidth: true
						elide: Text.ElideRight
						font.pointSize: Appearance.font.size.small
						text: qsTr("App volumes")
					}

					CustomText {
						Layout.fillWidth: true
						animate: true
						color: DynamicColors.palette.m3outline
						elide: Text.ElideRight
						font.pointSize: Appearance.font.size.small
						text: Audio.streams.length === 0 ? qsTr("No apps playing audio") : Audio.streams.length === 1 ? qsTr("1 app playing audio") : qsTr("%1 apps playing audio").arg(Audio.streams.length)
					}
				}

				MaterialIcon {
					color: DynamicColors.palette.m3onSurfaceVariant
					font.pointSize: Appearance.font.size.medium
					text: "chevron_right"
				}
			}
		}
	}
}
