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
	implicitWidth: 400 + Appearance.padding.small * 2

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
			Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
			Layout.topMargin: root.topMargin
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: root.rounding

			RowLayout {
				id: outputVolume

				anchors.left: parent.left
				anchors.margins: Appearance.spacing.smaller
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: 15

				CustomRect {
					Layout.alignment: Qt.AlignVCenter
					Layout.preferredHeight: 40
					Layout.preferredWidth: 40
					color: Audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
					radius: Appearance.rounding.full

					MaterialIcon {
						anchors.alignWhenCentered: false
						anchors.centerIn: parent
						animate: true
						color: Audio.muted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
						font.pointSize: 22
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

				ColumnLayout {
					Layout.fillWidth: true

					RowLayout {
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
						Layout.bottomMargin: 5
						Layout.fillWidth: true
						Layout.preferredHeight: 10

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							color: Audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
							implicitHeight: 10
							value: Audio.volume

							Behavior on value {
								Anim {
								}
							}

							onMoved: Audio.setVolume(value)
						}
					}
				}
			}
		}

		CustomClippingRect {
			Layout.fillWidth: true
			Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
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

			RowLayout {
				id: inputVolume

				anchors.left: parent.left
				anchors.margins: Appearance.spacing.smaller
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: 15

				CustomRect {
					Layout.alignment: Qt.AlignVCenter
					Layout.preferredHeight: 40
					Layout.preferredWidth: 40
					color: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
					radius: Appearance.rounding.full

					MaterialIcon {
						anchors.alignWhenCentered: false
						anchors.centerIn: parent
						animate: true
						color: Audio.sourceMuted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
						font.pointSize: 22
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

				ColumnLayout {
					Layout.fillWidth: true

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
						Layout.bottomMargin: 5
						Layout.fillWidth: true
						implicitHeight: 10

						CustomSlider {
							anchors.left: parent.left
							anchors.right: parent.right
							color: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
							implicitHeight: 10
							value: Audio.sourceVolume

							Behavior on value {
								Anim {
								}
							}

							onMoved: Audio.setSourceVolume(value)
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
				Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
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

				RowLayout {
					id: layoutVolume

					anchors.fill: parent
					anchors.margins: Appearance.spacing.smaller
					spacing: 15

					CustomRect {
						Layout.alignment: Qt.AlignVCenter
						Layout.preferredHeight: 40
						Layout.preferredWidth: 40
						color: appBox.modelData.audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
						radius: Appearance.rounding.full

						MaterialIcon {
							id: icon

							anchors.centerIn: parent
							animate: true
							color: appBox.modelData.audio.muted ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onPrimary
							font.pointSize: 22
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

					ColumnLayout {
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						Layout.fillHeight: true

						TextMetrics {
							id: metrics

							elide: Text.ElideRight
							elideWidth: root.width - 50
							text: Audio.getStreamName(appBox.modelData)
						}

						RowLayout {
							Layout.fillHeight: true
							Layout.fillWidth: true

							CustomText {
								Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
								Layout.fillHeight: true
								Layout.fillWidth: true
								elide: Text.ElideRight
								text: metrics.elidedText
							}

							CustomText {
								Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
								Layout.fillHeight: true
								font.bold: true
								text: qsTr("%1").arg(appBox.modelData.audio.muted ? qsTr("Muted") : `${Math.round(appBox.modelData.audio.volume * 100)}%`)
							}
						}

						CustomMouseArea {
							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
							Layout.fillHeight: true
							Layout.fillWidth: true
							implicitHeight: 10

							CustomSlider {
								anchors.left: parent.left
								anchors.right: parent.right
								color: appBox.modelData.audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
								implicitHeight: 10
								value: appBox.modelData.audio.volume

								onMoved: {
									Audio.setStreamVolume(appBox.modelData, value);
								}
							}
						}
					}
				}
			}
		}
	}
}
