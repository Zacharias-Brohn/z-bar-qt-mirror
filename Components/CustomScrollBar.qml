import QtQuick
import QtQuick.Templates
import qs.Helpers
import qs.Config

ScrollBar {
	id: root

	readonly property real effectiveSize: Math.max(nonAnimHeight, root.minimumSize)
	readonly property real effectiveTravel: Math.max(0, 1 - root.effectiveSize)
	required property Flickable flickable
	readonly property real nonAnimHeight: flickable.height / flickable.contentHeight
	readonly property real nonAnimY: flickable.contentY / flickable.contentHeight
	readonly property real rawTravel: Math.max(0, 1 - root.nonAnimHeight)
	readonly property bool reversed: flickable instanceof ListView && flickable.verticalLayoutDirection === ListView.BottomToTop
	property bool shouldBeActive
	readonly property real travelScale: root.rawTravel > 0 ? root.effectiveTravel / root.rawTravel : 0

	enabled: !Visibilities.getForActive().isDrawing
	implicitWidth: Appearance.padding.extraSmall * 2

	contentItem: Item {
	}
	Behavior on position {
		enabled: !fullMouse.pressed

		Anim {
		}
	}

	onHoveredChanged: {
		if (hovered)
			shouldBeActive = hovered;
		else
			hideDelay.restart();
	}

	Connections {
		function onMovingChanged() {
			if (root.flickable.moving)
				root.shouldBeActive = true;
			else
				hideDelay.restart();
		}

		target: root.flickable
	}

	CustomClippingRect {
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.top: parent.top
		implicitWidth: handle.implicitWidth
		radius: Appearance.rounding.full

		CustomRect {
			id: handle

			anchors.right: parent.right
			color: DynamicColors.palette.m3secondary
			implicitHeight: root.height * root.effectiveSize
			implicitWidth: fullMouse.pressed || fullMouse.containsMouse ? Appearance.padding.extraSmall * 2 : Appearance.padding.extraSmall
			opacity: {
				if (!root.enabled)
					return 0;
				if (root.size === 1)
					return 0;
				if (fullMouse.pressed)
					return 1;
				if (fullMouse.containsMouse)
					return 0.8;
				if (root.policy === ScrollBar.AlwaysOn || root.shouldBeActive)
					return 0.6;
				return 0;
			}
			radius: Appearance.rounding.full
			y: root.reversed ? root.height * (1 + root.nonAnimY) * root.travelScale : root.height * root.nonAnimY * root.travelScale

			Behavior on implicitWidth {
				Anim {
				}
			}
			Behavior on opacity {
				Anim {
					type: Anim.DefaultEffects
				}
			}

			MouseArea {
				id: mouse

				acceptedButtons: Qt.NoButton
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true
			}
		}
	}

	Timer {
		id: hideDelay

		interval: 600

		onTriggered: root.shouldBeActive = root.flickable.moving || root.hovered
	}

	CustomMouseArea {
		id: fullMouse

		property real pressOffset: 0

		function contentYFromThumbTop(thumbTop) {
			var visualPos = root.effectiveTravel > 0 ? thumbTop / root.travelScale : 0;

			return root.reversed ? (visualPos - 1) * root.flickable.contentHeight : visualPos * root.flickable.contentHeight;
		}

		function updateFromEvent(event) {
			var posInTrack = event.y / root.height;
			var thumbTop = posInTrack - pressOffset;
			thumbTop = Math.max(0, Math.min(root.effectiveTravel, thumbTop));

			root.flickable.contentY = contentYFromThumbTop(thumbTop);
		}

		function visualThumbTop() {
			const visualPos = root.reversed ? (1 + root.nonAnimY) : root.nonAnimY;
			return visualPos * root.travelScale;
		}

		anchors.fill: parent
		cursorShape: undefined
		hoverEnabled: true
		preventStealing: true

		onPositionChanged: event => {
			if (pressed)
				updateFromEvent(event);
		}
		onPressed: event => {
			var currentTop = visualThumbTop();
			var currentBottom = currentTop + root.effectiveSize;
			var clickPos = event.y / root.height;

			var clickedInsideThumb = clickPos >= currentTop && clickPos <= currentBottom;

			if (clickedInsideThumb) {
				pressOffset = clickPos - currentTop;
			} else {
				pressOffset = root.effectiveSize / 2;
			}

			updateFromEvent(event);
		}
		onWheel: event => {
			var delta = event.angleDelta.y > 0 ? -0.1 : 0.1;
			var newPos = Math.max(0, Math.min(1 - root.size, root.position + delta));
			root.position = newPos;
		}
	}
}
