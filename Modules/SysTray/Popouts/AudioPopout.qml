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
	implicitWidth: 500 + Appearance.padding.small * 2

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

			ColumnLayout {
				anchors.bottomMargin: Appearance.padding.smaller
				anchors.fill: parent
				anchors.leftMargin: Appearance.padding.larger
				anchors.rightMargin: Appearance.padding.larger
				anchors.topMargin: Appearance.padding.smaller

				RowLayout {
					Layout.fillHeight: true
					Layout.fillWidth: true

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						Layout.fillWidth: true
						text: "Output volume"
					}

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
						color: Qt.alpha(DynamicColors.palette.m3onSurface, 0.7)
						font.bold: true
						text: qsTr("%1").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`)
					}
				}

				RowLayout {
					spacing: Appearance.spacing.large

					CustomMouseArea {
						Layout.bottomMargin: Appearance.padding.normal
						Layout.fillWidth: true
						Layout.preferredHeight: Appearance.padding.larger * 3

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							bgColor: Audio.muted ? Qt.alpha(DynamicColors.palette.m3errorContainer, 0.5) : DynamicColors.palette.m3secondaryContainer
							fgColor: Audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
							implicitHeight: parent.height
							insetColor: Audio.muted ? (inset.attached ? DynamicColors.palette.m3onErrorContainer : DynamicColors.palette.m3onError) : (inset.attached ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onPrimary)
							insetIcon: Audio.muted || Audio.volume < 0.001 ? "volume_off" : "volume_up"
							value: Audio.volume

							Behavior on value {
								Anim {
								}
							}

							onInteraction: value => Audio.setVolume(value)
						}
					}

					CustomSwitch {
						Layout.bottomMargin: Appearance.padding.normal
						checked: !Audio.muted

						onToggled: {
							const audio = Audio.sink?.audio;
							if (audio)
								audio.muted = !audio.muted;
						}
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

			ColumnLayout {
				anchors.bottomMargin: Appearance.padding.smaller
				anchors.fill: parent
				anchors.leftMargin: Appearance.padding.larger
				anchors.rightMargin: Appearance.padding.larger
				anchors.topMargin: Appearance.padding.smaller

				RowLayout {
					Layout.fillHeight: true
					Layout.fillWidth: true

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						Layout.fillWidth: true
						text: "Input volume"
					}

					CustomText {
						Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
						color: Qt.alpha(DynamicColors.palette.m3onSurface, 0.7)
						font.bold: true
						text: qsTr("%1").arg(Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`)
					}
				}

				RowLayout {
					spacing: Appearance.spacing.large

					CustomMouseArea {
						Layout.bottomMargin: Appearance.padding.normal
						Layout.fillWidth: true
						Layout.preferredHeight: Appearance.padding.larger * 3

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							bgColor: Audio.sourceMuted ? Qt.alpha(DynamicColors.palette.m3errorContainer, 0.5) : DynamicColors.palette.m3secondaryContainer
							fgColor: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
							implicitHeight: parent.height
							insetColor: Audio.sourceMuted ? (inset.attached ? DynamicColors.palette.m3onErrorContainer : DynamicColors.palette.m3onError) : (inset.attached ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onPrimary)
							insetIcon: Audio.sourceMuted || Audio.sourceVolume < 0.001 ? "mic_off" : "mic"
							value: Audio.sourceVolume

							Behavior on value {
								Anim {
								}
							}

							onInteraction: value => Audio.setSourceVolume(value)
						}
					}

					CustomSwitch {
						Layout.bottomMargin: Appearance.padding.normal
						checked: !Audio.sourceMuted

						onToggled: {
							const audio = Audio.source?.audio;
							if (audio)
								audio.muted = !audio.muted;
						}
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

				TextMetrics {
					id: metrics

					elide: Text.ElideRight
					elideWidth: root.width - 50
					text: Audio.getStreamName(appBox.modelData)
				}

				ColumnLayout {
					anchors.bottomMargin: Appearance.padding.smaller
					anchors.fill: parent
					anchors.leftMargin: Appearance.padding.larger
					anchors.rightMargin: Appearance.padding.larger
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
							color: Qt.alpha(DynamicColors.palette.m3onSurface, 0.7)
							font.bold: true
							text: qsTr("%1").arg(appBox.modelData.audio.muted ? qsTr("Muted") : `${Math.round(appBox.modelData.audio.volume * 100)}%`)
						}
					}

					RowLayout {
						spacing: Appearance.spacing.large

						CustomMouseArea {
							Layout.bottomMargin: Appearance.padding.normal
							Layout.fillWidth: true
							Layout.preferredHeight: Appearance.padding.larger * 3

							CustomSlider {
								anchors.left: parent.left
								anchors.right: parent.right
								bgColor: appBox.modelData.audio.muted ? Qt.alpha(DynamicColors.palette.m3errorContainer, 0.5) : DynamicColors.palette.m3secondaryContainer
								fgColor: appBox.modelData.audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
								implicitHeight: parent.height
								insetColor: appBox.modelData.audio.muted ? (inset.attached ? DynamicColors.palette.m3onErrorContainer : DynamicColors.palette.m3onError) : (inset.attached ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onPrimary)
								insetIcon: appBox.modelData.audio.muted || appBox.modelData.audio.volume < 0.001 ? "volume_off" : "volume_up"
								value: appBox.modelData.audio.volume

								Behavior on value {
									Anim {
									}
								}

								onInteraction: value => Audio.setStreamVolume(appBox.modelData, value)
							}
						}

						CustomSwitch {
							Layout.bottomMargin: Appearance.padding.normal
							checked: !appBox.modelData.audio.muted

							onToggled: {
								appBox.modelData.audio.muted = !appBox.modelData.audio.muted;
							}
						}
					}
				}
			}
		}
	}
}
