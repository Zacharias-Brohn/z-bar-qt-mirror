pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Modules.Settings.Common
import qs.Helpers
import qs.Components
import qs.Config
import qs.Daemons

PageBase {
	id: root

	isSubPage: true
	title: qsTr("App volumes")

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.extraSmall / 2
		width: root.cappedWidth

		CustomText {
			Layout.bottomMargin: Appearance.spacing.small
			Layout.fillWidth: true
			Layout.leftMargin: Appearance.padding.small
			color: DynamicColors.palette.m3outline
			font.pointSize: Appearance.font.size.small
			text: qsTr("Adjust the volume of individual apps currently playing audio.")
			wrapMode: Text.WordWrap
		}

		ItemList {
			id: streamList

			color: list.count === 0 ? DynamicColors.tPalette.m3surfaceContainer : "transparent"
			first: true
			last: true
			list.spacing: Appearance.spacing.extraSmall / 2
			placeholderIcon: "music_off"
			placeholderText: qsTr("No apps playing audio")
			showList: true

			delegate: SliderRow {
				id: stream

				required property int index
				required property PwNode modelData

				anchors.left: streamList.list.contentItem.left
				anchors.right: streamList.list.contentItem.right
				enabled: !stream.modelData?.audio?.muted
				first: index === 0
				icon: Icons.getVolumeIcon(stream.modelData?.audio?.volume ?? 0, stream.modelData?.audio?.muted ?? false)
				label: Audio.getStreamName(stream.modelData)
				last: index === streamList.list.count - 1
				value: stream.modelData?.audio?.volume ?? 0
				valueLabel: Math.round(value * 100) + "%"

				onMoved: v => Audio.setStreamVolume(stream.modelData, v)
			}
			model: ScriptModel {
				values: [...Audio.streams]
			}
		}
	}
}
