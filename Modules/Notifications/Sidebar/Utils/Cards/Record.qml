pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

CustomRect {
	id: root

	required property var props
	required property PersistentProperties visibilities

	Layout.fillWidth: true
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + layout.anchors.margins * 2
	radius: Appearance.rounding.smallest

	ColumnLayout {
		id: layout

		anchors.fill: parent
		anchors.margins: Appearance.padding.large
		spacing: Appearance.spacing.normal

		RowLayout {
			spacing: Appearance.spacing.normal
			z: 1

			CustomRect {
				color: Recorder.running ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3secondaryContainer
				implicitHeight: {
					const h = icon.implicitHeight + Appearance.padding.smaller * 2;
					return h - (h % 2);
				}
				implicitWidth: implicitHeight
				radius: Appearance.rounding.full

				MaterialIcon {
					id: icon

					anchors.centerIn: parent
					anchors.horizontalCenterOffset: -0.5
					anchors.verticalCenterOffset: 1.5
					color: Recorder.running ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSecondaryContainer
					font.pointSize: Appearance.font.size.large
					text: "screen_record"
				}
			}

			ColumnLayout {
				Layout.fillWidth: true
				spacing: 0

				CustomText {
					Layout.fillWidth: true
					elide: Text.ElideRight
					font.pointSize: Appearance.font.size.normal
					text: qsTr("Screen Recorder")
				}

				CustomText {
					Layout.fillWidth: true
					color: DynamicColors.palette.m3onSurfaceVariant
					elide: Text.ElideRight
					font.pointSize: Appearance.font.size.small
					text: Recorder.paused ? qsTr("Recording paused") : Recorder.running ? qsTr("Recording running") : qsTr("Recording off")
				}
			}

			CustomSplitButton {
				active: menuItems.find(m => root.props.recordingMode === m.icon + m.text) ?? menuItems[0]
				enabled: !Recorder.running
				menuOnTop: true

				menuItems: [
					MenuItem {
						activeText: qsTr("Fullscreen")
						icon: "fullscreen"
						text: qsTr("Record fullscreen")

						onClicked: Recorder.start()
					},
					MenuItem {
						activeText: qsTr("Region")
						icon: "screenshot_region"
						text: qsTr("Record region")

						onClicked: Recorder.start(["-r"])
					},
					MenuItem {
						activeText: qsTr("Fullscreen")
						icon: "select_to_speak"
						text: qsTr("Record fullscreen with sound")

						onClicked: Recorder.start(["-s"])
					},
					MenuItem {
						activeText: qsTr("Region")
						icon: "volume_up"
						text: qsTr("Record region with sound")

						onClicked: Recorder.start(["-s", "-r"])
					}
				]

				menu.onItemSelected: item => root.props.recordingMode = item.icon + item.text
			}
		}

		Loader {
			id: listOrControls

			property bool running: Recorder.running

			Layout.fillWidth: true
			Layout.preferredHeight: implicitHeight
			asynchronous: true
			sourceComponent: running ? recordingControls : recordingList

			Behavior on Layout.preferredHeight {
				id: locHeightAnim

				enabled: false

				Anim {
				}
			}
			Behavior on running {
				SequentialAnimation {
					ParallelAnimation {
						Anim {
							duration: Appearance.anim.durations.small
							easing: Appearance.anim.curves.standardAccel
							property: "scale"
							target: listOrControls
							to: 0.7
						}

						Anim {
							duration: Appearance.anim.durations.small
							easing: Appearance.anim.curves.standardAccel
							property: "opacity"
							target: listOrControls
							to: 0
						}
					}

					PropertyAction {
						property: "enabled"
						target: locHeightAnim
						value: true
					}

					PropertyAction {
					}

					PropertyAction {
						property: "enabled"
						target: locHeightAnim
						value: false
					}

					ParallelAnimation {
						Anim {
							duration: Appearance.anim.durations.small
							easing: Appearance.anim.curves.standardDecel
							property: "scale"
							target: listOrControls
							to: 1
						}

						Anim {
							duration: Appearance.anim.durations.small
							easing: Appearance.anim.curves.standardDecel
							property: "opacity"
							target: listOrControls
							to: 1
						}
					}
				}
			}
		}
	}

	Component {
		id: recordingList

		RecordingList {
			props: root.props
			visibilities: root.visibilities
		}
	}

	Component {
		id: recordingControls

		RowLayout {
			spacing: Appearance.spacing.normal

			CustomRect {
				color: Recorder.paused ? DynamicColors.palette.m3tertiary : DynamicColors.palette.m3error
				implicitHeight: recText.implicitHeight + Appearance.padding.smaller * 2
				implicitWidth: recText.implicitWidth + Appearance.padding.normal * 2
				radius: Appearance.rounding.full

				Behavior on implicitWidth {
					Anim {
					}
				}
				SequentialAnimation on opacity {
					alwaysRunToEnd: true
					loops: Animation.Infinite
					running: !Recorder.paused

					Anim {
						duration: Appearance.anim.durations.large
						easing: Appearance.anim.curves.emphasizedAccel
						from: 1
						to: 0
					}

					Anim {
						duration: Appearance.anim.durations.extraLarge
						easing: Appearance.anim.curves.emphasizedDecel
						from: 0
						to: 1
					}
				}

				CustomText {
					id: recText

					anchors.centerIn: parent
					animate: true
					color: Recorder.paused ? DynamicColors.palette.m3onTertiary : DynamicColors.palette.m3onError
					font.family: Appearance.font.family.mono
					text: Recorder.paused ? "PAUSED" : "REC"
				}
			}

			CustomText {
				font.pointSize: Appearance.font.size.normal
				text: {
					const elapsed = Recorder.elapsed;

					const hours = Math.floor(elapsed / 3600);
					const mins = Math.floor((elapsed % 3600) / 60);
					const secs = Math.floor(elapsed % 60).toString().padStart(2, "0");

					let time;
					if (hours > 0)
						time = `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
					else
						time = `${mins}:${secs}`;

					return qsTr("Recording for %1").arg(time);
				}
			}

			Item {
				Layout.fillWidth: true
			}

			IconButton {
				checked: Recorder.paused
				font.pointSize: Appearance.font.size.large
				icon: Recorder.paused ? "play_arrow" : "pause"
				isToggle: true
				label.animate: true
				type: IconButton.Tonal

				onClicked: {
					Recorder.togglePause();
					internalChecked = Recorder.paused;
				}
			}

			IconButton {
				font.pointSize: Appearance.font.size.large
				icon: "stop"
				inactiveColor: DynamicColors.palette.m3error
				inactiveOnColor: DynamicColors.palette.m3onError

				onClicked: Recorder.stop()
			}
		}
	}
}
