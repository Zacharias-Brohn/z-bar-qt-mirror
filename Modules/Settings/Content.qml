pragma ComponentBehavior: Bound

import QtQuick
import ZShell.Blobs
import qs.Components
import qs.Config

CustomClippingRect {
	id: root

	property color blobColor: DynamicColors.tPalette.m3surfaceContainerLow
	readonly property real ratio: 16.0 / 9.0
	readonly property SettingsState sState: SettingsState {
		id: sState

		onClose: root.close()
	}

	signal close

	implicitHeight: sState.screen.height * 0.7
	implicitWidth: implicitHeight * ratio
	radius: Appearance.rounding.large + Appearance.padding.normal

	Behavior on blobColor {
		CAnim {
		}
	}

	TapHandler {
		onTapped: root.focus = true
	}

	BlobGroup {
		id: blobGroup

		color: root.blobColor
		smoothing: Appearance.rounding.normal
	}

	BlobInvertedRect {
		anchors.fill: parent
		borderBottom: Appearance.padding.normal
		borderLeft: navPane.width + navPane.anchors.margins * 2
		borderRight: Appearance.padding.normal
		borderTop: Appearance.padding.normal
		group: blobGroup
		opacity: root.blobColor.a
		radius: Appearance.rounding.large
	}

	NavPane {
		id: navPane

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: Appearance.padding.large
		anchors.top: parent.top
		sState: root.sState
		width: Math.min(600, Math.round(root.width / 3))
	}

	Pages {
		anchors.bottom: parent.bottom
		anchors.left: navPane.right
		anchors.leftMargin: navPane.anchors.margins + anchors.margins
		anchors.margins: Appearance.padding.extraLarge
		anchors.right: parent.right
		anchors.top: parent.top
		sState: root.sState
	}

	PopupOverlay {
		anchors.fill: parent
	}
}
