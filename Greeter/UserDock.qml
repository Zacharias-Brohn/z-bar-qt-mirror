pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

ColumnLayout {
	id: root

	required property var greeter

	anchors.fill: parent
	anchors.margins: Appearance.padding.large
	spacing: Appearance.spacing.smaller

	CustomText {
		Layout.fillWidth: true
		color: DynamicColors.palette.m3outline
		elide: Text.ElideRight
		font.family: Appearance.font.family.mono
		font.weight: 500
		text: root.greeter.users.length > 0 ? qsTr("%1 user%2").arg(root.greeter.users.length).arg(root.greeter.users.length === 1 ? "" : "s") : qsTr("Users")
	}

	CustomClippingRect {
		Layout.fillHeight: true
		Layout.fillWidth: true
		color: "transparent"
		radius: Appearance.rounding.small

		Loader {
			active: opacity > 0
			anchors.centerIn: parent
			opacity: root.greeter.users.length > 0 ? 0 : 1

			Behavior on opacity {
				Anim {
					duration: Appearance.anim.durations.extraLarge
				}
			}
			sourceComponent: ColumnLayout {
				spacing: Appearance.spacing.large

				MaterialIcon {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3outlineVariant
					fill: 1
					font.pointSize: Appearance.font.size.extraLarge * 2
					text: "account_circle"
				}

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3outlineVariant
					font.family: Appearance.font.family.mono
					font.pointSize: Appearance.font.size.large
					font.weight: 500
					text: qsTr("No Users Found")
				}
			}
		}

		ListView {
			id: users

			anchors.fill: parent
			clip: true
			highlightFollowsCurrentItem: false
			model: root.greeter.users
			spacing: Appearance.spacing.small

			delegate: CustomRect {
				id: user

				required property int index
				required property var modelData

				anchors.left: parent?.left
				anchors.right: parent?.right
				implicitHeight: row.implicitHeight + Appearance.padding.normal * 2
				radius: Appearance.rounding.normal - Appearance.padding.smaller

				StateLayer {
					function onClicked(): void {
						users.currentIndex = index;
					}
				}

				RowLayout {
					id: row

					anchors.fill: parent
					anchors.margins: Appearance.padding.normal
					spacing: Appearance.spacing.normal

					MaterialIcon {
						color: user.index === users.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurfaceVariant
						fill: 1
						font.pointSize: Appearance.font.size.extraLarge
						text: modelData.kind === "x11" ? "tv" : "account_circle"
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: Appearance.spacing.small / 2

						CustomText {
							Layout.fillWidth: true
							color: user.index === users.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
							elide: Text.ElideRight
							font.pointSize: Appearance.font.size.normal
							font.weight: 600
							text: modelData.username
						}
					}
				}
			}
			highlight: CustomRect {
				color: DynamicColors.palette.m3primary
				implicitHeight: users.currentItem?.implicitHeight ?? 0
				implicitWidth: users.width
				radius: Appearance.rounding.normal - Appearance.padding.smaller
				y: users.currentItem?.y ?? 0

				Behavior on y {
					Anim {
						duration: Appearance.anim.durations.small
						easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					}
				}
			}
		}
	}
}
