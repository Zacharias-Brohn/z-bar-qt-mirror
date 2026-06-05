pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Config
import qs.Components
import qs.Daemons
import qs.Helpers

Item {
	id: root

	readonly property int rounding: Appearance.rounding.small - Appearance.padding.small
	readonly property int topMargin: 0
	required property var wrapper

	implicitHeight: vol.implicitHeight + Appearance.padding.small * 2
	implicitWidth: 600 + Appearance.padding.small * 2

	CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: parent.implicitHeight
		radius: Appearance.rounding.small
		y: parent.y

		Behavior on implicitHeight {
			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}
	}

	VolumesTab {
		id: vol

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
	}

	component VolumesTab: ColumnLayout {
		spacing: 12

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: 65 + Appearance.spacing.smaller * 2
			Layout.topMargin: root.topMargin
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: root.rounding

			Item {
				id: sinkIcon

				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.leftMargin: Appearance.padding.larger
				anchors.top: parent.top
				implicitWidth: childrenRect.width

				CustomRect {
					anchors.centerIn: parent
					color: Audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
					implicitHeight: 54
					implicitWidth: 54
					radius: Appearance.rounding.full

					MaterialIcon {
						anchors.alignWhenCentered: false
						anchors.centerIn: parent
						animate: true
						color: Audio.muted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
						font.pointSize: Appearance.font.size.extraLarge
						text: Audio.muted ? "volume_off" : "volume_up"
					}

					StateLayer {
						color: Audio.muted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary

						onClicked: {
							const audio = Audio.sink?.audio;
							if (audio)
								audio.muted = !audio.muted;
						}
					}
				}
			}

			ColumnLayout {
				anchors.bottom: parent.bottom
				anchors.bottomMargin: Appearance.padding.smallest
				anchors.left: sinkIcon.right
				anchors.leftMargin: Appearance.spacing.larger
				anchors.right: parent.right
				anchors.rightMargin: Appearance.padding.large
				anchors.top: parent.top
				anchors.topMargin: Appearance.padding.smaller

				RowLayout {
					Layout.fillHeight: true
					Layout.fillWidth: true

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						Layout.fillWidth: true
						text: "Output Volume"
					}

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
						font.bold: true
						text: qsTr("%1").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`)
					}
				}

				CustomMouseArea {
					Layout.bottomMargin: Appearance.padding.normal
					Layout.fillWidth: true
					Layout.preferredHeight: Appearance.padding.larger * 3

					CustomSlider {
						anchors.left: parent.left
						anchors.right: parent.right
						fgColor: Audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
						implicitHeight: parent.height
						value: Audio.volume

						Behavior on value {
							Anim {
							}
						}

						onInteraction: value => Audio.setVolume(value)
					}
				}
			}
		}

		CustomClippingRect {
			Layout.fillWidth: true
			Layout.preferredHeight: 65 + Appearance.spacing.smaller * 2
			Layout.topMargin: root.topMargin
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: root.rounding

			PwNodePeakMonitor {
				id: sourcePeak

				node: Audio.source
			}

			CustomRect {
				id: sourcePeakFill

				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.top: parent.top
				color: Qt.alpha(DynamicColors.palette.m3primary, 0.15)
				implicitWidth: parent.width * sourcePeak.peak

				Behavior on implicitWidth {
					Anim {
						duration: MaterialEasing.expressiveEffectsTime
					}
				}
			}

			Item {
				id: sourceIcon

				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.leftMargin: Appearance.padding.larger
				anchors.top: parent.top
				implicitWidth: childrenRect.width

				CustomRect {
					anchors.centerIn: parent
					color: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
					implicitHeight: 54
					implicitWidth: 54
					radius: Appearance.rounding.full

					MaterialIcon {
						anchors.alignWhenCentered: false
						anchors.centerIn: parent
						animate: true
						color: Audio.sourceMuted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
						font.pointSize: Appearance.font.size.extraLarge
						text: Audio.sourceMuted ? "mic_off" : "mic"
					}

					StateLayer {
						color: Audio.sourceMuted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary

						onClicked: {
							const audio = Audio.source?.audio;
							if (audio)
								audio.muted = !audio.muted;
						}
					}
				}
			}

			ColumnLayout {
				anchors.bottom: parent.bottom
				anchors.bottomMargin: Appearance.padding.smallest
				anchors.left: sourceIcon.right
				anchors.leftMargin: Appearance.spacing.larger
				anchors.right: parent.right
				anchors.rightMargin: Appearance.padding.large
				anchors.top: parent.top
				anchors.topMargin: Appearance.padding.smaller

				RowLayout {
					Layout.fillHeight: true
					Layout.fillWidth: true

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						Layout.fillWidth: true
						text: "Input Volume"
					}

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
						font.bold: true
						text: qsTr("%1").arg(Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`)
					}
				}

				CustomMouseArea {
					Layout.bottomMargin: Appearance.padding.normal
					Layout.fillWidth: true
					Layout.preferredHeight: Appearance.padding.larger * 3

					CustomSlider {
						anchors.left: parent.left
						anchors.right: parent.right
						fgColor: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
						implicitHeight: parent.height
						value: Audio.sourceVolume

						Behavior on value {
							Anim {
							}
						}

						onInteraction: value => Audio.setSourceVolume(value)
					}
				}
			}
		}

		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: 1
			Layout.topMargin: root.topMargin
			color: DynamicColors.tPalette.m3outline
			visible: appTracks.model.length > 0
		}

		Repeater {
			id: appTracks

			model: Audio.streams.filter(s => s.isSink)

			CustomClippingRect {
				id: appBox

				required property int index
				required property var modelData

				Layout.fillWidth: true
				Layout.preferredHeight: 65 + Appearance.spacing.smaller * 2
				Layout.topMargin: root.topMargin
				color: DynamicColors.tPalette.m3surfaceContainer
				radius: root.rounding

				PwNodePeakMonitor {
					id: peak

					node: appBox.modelData
				}

				CustomRect {
					id: peakFill

					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.top: parent.top
					color: Qt.alpha(DynamicColors.palette.m3primary, 0.15)
					implicitWidth: parent.width * peak.peak

					Behavior on implicitWidth {
						Anim {
							duration: MaterialEasing.expressiveEffectsTime
						}
					}
				}

				Item {
					id: appBoxIcon

					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.leftMargin: Appearance.padding.larger
					anchors.top: parent.top
					implicitWidth: childrenRect.width

					CustomRect {
						anchors.centerIn: parent
						color: appBox.modelData.audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
						implicitHeight: 54
						implicitWidth: 54
						radius: Appearance.rounding.full

						MaterialIcon {
							id: icon

							anchors.centerIn: parent
							animate: true
							color: appBox.modelData.audio.muted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
							font.pointSize: Appearance.font.size.extraLarge
							text: appBox.modelData.audio.muted ? "volume_off" : "volume_up"
						}

						StateLayer {
							color: appBox.modelData.audio.muted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
							radius: Appearance.rounding.full

							onClicked: {
								appBox.modelData.audio.muted = !appBox.modelData.audio.muted;
							}
						}
					}
				}

				TextMetrics {
					id: metrics

					elide: Text.ElideRight
					elideWidth: root.width - 50
					text: Audio.getStreamName(appBox.modelData)
				}

				ColumnLayout {
					anchors.bottom: parent.bottom
					anchors.bottomMargin: Appearance.padding.smallest
					anchors.left: appBoxIcon.right
					anchors.leftMargin: Appearance.spacing.larger
					anchors.right: parent.right
					anchors.rightMargin: Appearance.padding.large
					anchors.top: parent.top
					anchors.topMargin: Appearance.padding.smaller

					RowLayout {
						Layout.fillHeight: true
						Layout.fillWidth: true

						CustomText {
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
							Layout.fillWidth: true
							elide: Text.ElideRight
							text: metrics.elidedText
						}

						CustomText {
							Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
							font.bold: true
							text: qsTr("%1").arg(appBox.modelData.audio.muted ? qsTr("Muted") : `${Math.round(appBox.modelData.audio.volume * 100)}%`)
						}
					}

					CustomMouseArea {
						Layout.bottomMargin: Appearance.padding.normal
						Layout.fillWidth: true
						Layout.preferredHeight: Appearance.padding.larger * 3

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							fgColor: appBox.modelData.audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
							implicitHeight: parent.height
							value: appBox.modelData.audio.volume

							onInteraction: value => {
								Audio.setStreamVolume(appBox.modelData, value);
							}
						}
					}
				}
			}
		}
	}
}
