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

CustomRect {
	id: root

	readonly property int rounding: Appearance.rounding.small - Appearance.padding.small
	readonly property int topMargin: 0
	required property var wrapper

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + Appearance.padding.small * 2
	implicitWidth: layout.implicitWidth + Appearance.padding.small * 2
	radius: Appearance.rounding.small

	ColumnLayout {
		id: layout

		anchors.centerIn: parent
		implicitWidth: stack.currentItem ? stack.currentItem.childrenRect.height : 0
		spacing: 12

		RowLayout {
			id: tabBar

			property int tabHeight: 36

			Layout.fillWidth: true
			spacing: 6

			CustomClippingRect {
				Layout.fillWidth: true
				Layout.preferredHeight: tabBar.tabHeight
				color: stack.currentIndex === 0 ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
				radius: root.rounding

				StateLayer {
					function onClicked(): void {
						stack.currentIndex = 0;
					}

					CustomText {
						anchors.centerIn: parent
						color: stack.currentIndex === 0 ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3primary
						text: qsTr("Volumes")
					}
				}
			}

			CustomClippingRect {
				Layout.fillWidth: true
				Layout.preferredHeight: tabBar.tabHeight
				color: stack.currentIndex === 1 ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3surfaceContainer
				radius: root.rounding

				StateLayer {
					function onClicked(): void {
						stack.currentIndex = 1;
					}

					CustomText {
						anchors.centerIn: parent
						color: stack.currentIndex === 1 ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3primary
						text: qsTr("Devices")
					}
				}
			}
		}

		StackLayout {
			id: stack

			Layout.fillWidth: true
			Layout.preferredHeight: currentIndex === 0 ? vol.childrenRect.height : dev.childrenRect.height
			currentIndex: 0

			Behavior on currentIndex {
				SequentialAnimation {
					ParallelAnimation {
						Anim {
							duration: MaterialEasing.expressiveEffectsTime
							property: "opacity"
							target: stack
							to: 0
						}

						Anim {
							duration: MaterialEasing.expressiveEffectsTime
							property: "scale"
							target: stack
							to: 0.9
						}
					}

					PropertyAction {
					}

					ParallelAnimation {
						Anim {
							duration: MaterialEasing.expressiveEffectsTime
							property: "opacity"
							target: stack
							to: 1
						}

						Anim {
							duration: MaterialEasing.expressiveEffectsTime
							property: "scale"
							target: stack
							to: 1
						}
					}
				}
			}

			VolumesTab {
				id: vol
			}

			DevicesTab {
				id: dev
			}
		}
	}

	component DevicesTab: Item {
		implicitHeight: deviceColumn.height + Appearance.padding.normal
		implicitWidth: deviceColumn.width + Appearance.padding.normal

		ColumnLayout {
			id: deviceColumn

			anchors.centerIn: parent
			spacing: 12

			ButtonGroup {
				id: sinks
			}

			ButtonGroup {
				id: sources
			}

			CustomText {
				font.weight: 500
				text: qsTr("Output device")
			}

			Repeater {
				model: Audio.sinks

				CustomRadioButton {
					required property PwNode modelData

					ButtonGroup.group: sinks
					checked: Audio.sink?.id === modelData.id
					text: modelData.description

					onClicked: Audio.setAudioSink(modelData)
				}
			}

			CustomText {
				Layout.topMargin: 10
				font.weight: 500
				text: qsTr("Input device")
			}

			Repeater {
				model: Audio.sources

				CustomRadioButton {
					required property PwNode modelData

					ButtonGroup.group: sources
					checked: Audio.source?.id === modelData.id
					text: modelData.description

					onClicked: Audio.setAudioSource(modelData)
				}
			}
		}
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
					color: DynamicColors.palette.m3primary
					radius: Appearance.rounding.full

					MaterialIcon {
						anchors.alignWhenCentered: false
						anchors.centerIn: parent
						color: DynamicColors.palette.m3onPrimary
						font.pointSize: 22
						text: "speaker"
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

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: 42 + Appearance.spacing.smaller * 2
			Layout.topMargin: root.topMargin
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: root.rounding

			RowLayout {
				id: inputVolume

				anchors.left: parent.left
				anchors.margins: Appearance.spacing.smaller
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: 15

				Rectangle {
					Layout.alignment: Qt.AlignVCenter
					Layout.preferredHeight: 40
					Layout.preferredWidth: 40
					color: DynamicColors.palette.m3primary
					radius: Appearance.rounding.full

					MaterialIcon {
						anchors.alignWhenCentered: false
						anchors.centerIn: parent
						color: DynamicColors.palette.m3onPrimary
						font.pointSize: 22
						text: "mic"
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
