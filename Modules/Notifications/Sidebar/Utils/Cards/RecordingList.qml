pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import ZShell.Models
import qs.Components
import qs.Helpers
import qs.Paths
import qs.Config

ColumnLayout {
	id: root

	required property var props
	required property PersistentProperties visibilities

	spacing: 0

	WrapperMouseArea {
		Layout.fillWidth: true
		cursorShape: Qt.PointingHandCursor

		onClicked: root.props.recordingListExpanded = !root.props.recordingListExpanded

		RowLayout {
			spacing: Appearance.spacing.smaller

			MaterialIcon {
				Layout.alignment: Qt.AlignVCenter
				font.pointSize: Appearance.font.size.large
				text: "list"
			}

			CustomText {
				Layout.alignment: Qt.AlignVCenter
				Layout.fillWidth: true
				font.pointSize: Appearance.font.size.normal
				text: qsTr("Recordings")
			}

			IconButton {
				icon: root.props.recordingListExpanded ? "unfold_less" : "unfold_more"
				label.animate: true
				type: IconButton.Text

				onClicked: root.props.recordingListExpanded = !root.props.recordingListExpanded
			}
		}
	}

	CustomListView {
		id: list

		Layout.fillWidth: true
		Layout.rightMargin: -Appearance.spacing.small
		clip: true
		implicitHeight: (Appearance.font.size.larger + Appearance.padding.small) * (root.props.recordingListExpanded ? 10 : 3)

		CustomScrollBar.vertical: CustomScrollBar {
			flickable: list
		}
		add: Transition {
			Anim {
				from: 0
				property: "opacity"
				to: 1
			}

			Anim {
				from: 0.5
				property: "scale"
				to: 1
			}
		}
		delegate: RowLayout {
			id: recording

			property string baseName
			required property FileSystemEntry modelData

			anchors.left: list.contentItem.left
			anchors.right: list.contentItem.right
			anchors.rightMargin: Appearance.spacing.small
			spacing: Appearance.spacing.small / 2

			Component.onCompleted: baseName = modelData.baseName

			CustomText {
				Layout.fillWidth: true
				Layout.rightMargin: Appearance.spacing.small / 2
				color: DynamicColors.palette.m3onSurfaceVariant
				elide: Text.ElideRight
				text: {
					const time = recording.baseName;
					const matches = time.match(/^recording_(\d{4})(\d{2})(\d{2})_(\d{2})-(\d{2})-(\d{2})/);
					if (!matches)
						return time;
					const date = new Date(...matches.slice(1));
					date.setMonth(date.getMonth() - 1);
					return qsTr("Recording at %1").arg(Qt.formatDateTime(date, Qt.locale()));
				}
			}

			IconButton {
				icon: "play_arrow"
				type: IconButton.Text

				onClicked: {
					root.visibilities.sidebar = false;
					Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.playback, recording.modelData.path]);
				}
			}

			IconButton {
				icon: "folder"
				type: IconButton.Text

				onClicked: {
					root.visibilities.sidebar = false;
					Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.explorer, recording.modelData.path]);
				}
			}
		}
		displaced: Transition {
			Anim {
				properties: "opacity,scale"
				to: 1
			}

			Anim {
				property: "y"
			}
		}
		Behavior on implicitHeight {
			Anim {
			}
		}
		model: FileSystemModel {
			nameFilters: ["recording_*.mp4"]
			path: Paths.recsdir
			sortReverse: true
		}
		remove: Transition {
			Anim {
				property: "opacity"
				to: 0
			}

			Anim {
				property: "scale"
				to: 0.5
			}
		}

		Loader {
			active: opacity > 0
			anchors.centerIn: parent
			asynchronous: true
			opacity: list.count === 0 ? 1 : 0

			Behavior on opacity {
				Anim {
				}
			}
			sourceComponent: ColumnLayout {
				spacing: Appearance.spacing.small

				MaterialIcon {
					Layout.alignment: Qt.AlignHCenter
					Layout.preferredHeight: root.props.recordingListExpanded ? implicitHeight : 0
					color: DynamicColors.palette.m3outline
					font.pointSize: Appearance.font.size.extraLarge
					opacity: root.props.recordingListExpanded ? 1 : 0
					scale: root.props.recordingListExpanded ? 1 : 0
					text: "scan_delete"

					Behavior on Layout.preferredHeight {
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

				RowLayout {
					spacing: Appearance.spacing.smaller

					MaterialIcon {
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: !root.props.recordingListExpanded ? implicitWidth : 0
						color: DynamicColors.palette.m3outline
						opacity: !root.props.recordingListExpanded ? 1 : 0
						scale: !root.props.recordingListExpanded ? 1 : 0
						text: "scan_delete"

						Behavior on Layout.preferredWidth {
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

					CustomText {
						color: DynamicColors.palette.m3outline
						text: qsTr("No recordings found")
					}
				}
			}
		}
	}
}
