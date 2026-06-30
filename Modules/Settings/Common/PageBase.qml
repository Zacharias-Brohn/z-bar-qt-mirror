pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Modules.Settings
import qs.Components
import qs.Config

ColumnLayout {
	id: root

	property bool animateScroll: false
	readonly property int cappedWidth: Math.min(800, width)
	default property Item contentChild
	readonly property alias flickable: flickable
	property bool isSubPage
	required property SettingsState sState
	required property string title

	function applySearchAnchor(): void {
		if (!sState.searchAnchor)
			return;
		scrollRetry.tries = 0;
		scrollRetry.lastHeight = -1;
		scrollRetry.stableFrames = 0;
		scrollRetry.restart();
	}

	function findAnchor(item: Item, anchor: string): Item {
		if (!item)
			return null;
		if (item.settingAnchor !== undefined && item.settingAnchor === anchor)
			return item;
		const kids = item.children;
		for (let i = 0; i < kids.length; i++) {
			const found = findAnchor(kids[i], anchor);
			if (found)
				return found;
		}
		return null;
	}

	function highlightAnchor(anchor: string): void {
		const row = findAnchor(contentChild, anchor);
		if (row && row.flashHighlight !== undefined)
			row.flashHighlight();
	}

	function scrollToAnchor(anchor: string): bool {
		if (!anchor || !contentChild)
			return false;
		const row = findAnchor(contentChild, anchor);
		if (!row)
			return false;
		const pos = row.mapToItem(flickable.contentItem, 0, 0);
		const inset = flickable.height * flickable.fadeAmount + Appearance.padding.large;
		const minY = -flickable.topMargin;
		const maxY = Math.max(minY, flickable.contentHeight + flickable.bottomMargin - flickable.height);
		const target = Math.max(minY, Math.min(pos.y - inset, maxY));
		root.animateScroll = true;
		flickable.contentY = target;
		Qt.callLater(() => root.animateScroll = false);
		if (row.flashHighlight !== undefined)
			row.flashHighlight();
		return true;
	}

	spacing: Appearance.spacing.large

	Component.onCompleted: applySearchAnchor()

	Timer {
		id: scrollRetry

		property real lastHeight: -1
		property int stableFrames: 0
		property int tries: 0

		interval: 16
		repeat: true

		onTriggered: {
			const h = flickable.contentHeight;
			if (h === lastHeight && h > flickable.height)
				stableFrames++;
			else
				stableFrames = 0;
			lastHeight = h;

			const ready = stableFrames >= 3 || tries >= 30;
			if (ready) {
				if (root.scrollToAnchor(root.sState.searchAnchor))
					root.sState.searchAnchor = "";
				stop();
			}
			tries++;
		}
	}

	Connections {
		function onHighlightSetting(anchor: string): void {
			root.highlightAnchor(anchor);
		}

		function onSearchAnchorChanged(): void {
			root.applySearchAnchor();
		}

		target: root.sState
	}

	MouseArea {
		Layout.bottomMargin: -flickable.topMargin
		implicitHeight: header.implicitHeight - Layout.bottomMargin
		implicitWidth: header.implicitWidth
		z: 1

		onClicked: focus = true

		RowLayout {
			id: header

			spacing: Appearance.spacing.large

			Loader {
				active: root.isSubPage
				asynchronous: true
				visible: active

				sourceComponent: IconButton {
					icon: "arrow_back"
					inactiveColor: DynamicColors.tPalette.m3surfaceContainerHigh
					inactiveOnColor: DynamicColors.palette.m3onSurfaceVariant
					isRound: true
					type: IconButton.Tonal

					onClicked: root.sState.closeSubPage()
				}
			}

			CustomText {
				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.large
				text: root.title
			}
		}
	}

	VerticalFadeFlickable {
		id: flickable

		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.topMargin: -topMargin
		bottomMargin: Appearance.padding.extraLarge
		contentHeight: root.contentChild?.implicitHeight ?? 0
		contentItem.children: [root.contentChild]
		fadeAmount: 0.1
		topMargin: Appearance.padding.large

		Behavior on contentY {
			enabled: root.animateScroll

			Anim {
				type: Anim.DefaultSpatial
			}
		}

		TapHandler {
			onTapped: flickable.focus = true
		}
	}
}
