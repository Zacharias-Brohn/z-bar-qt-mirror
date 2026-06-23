import QtQuick
import ZShell.Blobs
import qs.Components
import qs.Config

Item {
	id: root

	property real animDriver
	property alias color: blobGroup.color
	default required property Item content
	property bool hoverOverride
	readonly property alias hovered: btn.containsMouse
	property alias icon: icon.text
	property bool open
	property int padding
	property bool pressOverride
	property int topMovement: Appearance.padding.large

	implicitHeight: btn.implicitHeight * 0.9
	implicitWidth: btn.implicitWidth * 0.9

	Binding {
		property: "opacity"
		target: root.content
		value: root.animDriver
	}

	BlobGroup {
		id: blobGroup

		color: DynamicColors.palette.m3surfaceContainerHighest
		smoothing: Appearance.rounding.medium

		Behavior on color {
			CAnim {
			}
		}
	}

	BlobRect {
		id: btnRect

		anchors.fill: parent
		anchors.margins: (!(btn.pressed || root.pressOverride) && (btn.containsMouse || root.hoverOverride) ? -Appearance.padding.extraSmall : 0) + (root.open ? -Appearance.padding.extraSmall : 0)
		group: blobGroup
		radius: root.open ? Appearance.rounding.large : Appearance.rounding.medium

		Behavior on anchors.margins {
			Anim {
			}
		}
		Behavior on radius {
			Anim {
				type: Anim.DefaultEffects
			}
		}
	}

	BlobRect {
		id: rect

		anchors.right: parent.right
		anchors.top: parent.top
		deformScale: 0.00001
		group: blobGroup
		implicitHeight: parent.height
		implicitWidth: parent.width
		radius: Appearance.rounding.large

		states: State {
			name: "open"
			when: root.open

			PropertyChanges {
				rect.anchors.rightMargin: root.width - Appearance.spacing.small
				rect.anchors.topMargin: -root.topMovement
				rect.implicitHeight: root.content.implicitHeight + root.padding * 2
				rect.implicitWidth: root.content.implicitWidth + root.padding * 2
				root.animDriver: 1
			}
		}
		transitions: Transition {
			Anim {
				properties: "rightMargin,implicitWidth"
			}

			Anim {
				duration: Appearance.anim.durations.expressiveFastSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
				properties: "topMargin,implicitHeight"
			}

			Anim {
				property: "animDriver"
				type: Anim.DefaultEffects
			}
		}

		MouseArea { // MouseArea to catch inputs
			anchors.fill: parent
			children: [root.content]
			clip: true
		}
	}

	MouseArea {
		id: btn

		anchors.centerIn: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		implicitHeight: icon.implicitHeight + Appearance.padding.extraSmall * 2
		implicitWidth: implicitHeight

		onClicked: root.open = !root.open

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.medium
			text: "view_apps"
		}
	}
}
