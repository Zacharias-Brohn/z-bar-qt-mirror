import QtQuick
import Quickshell
import Quickshell.Bluetooth

QtObject {
	id: root

	property bool animatingContainer
	property int currentPageIdx
	property bool isWindow
	property string lastAnchor
	property list<int> pendingSubPath
	property ShellScreen screen
	property string searchAnchor
	property bool searchOpen
	property string searchText
	property DesktopEntry selectedApp
	property BluetoothDevice selectedBtDevice
	property string selectedWallpaperCategory
	property list<int> subPageIdxStack

	signal close
	signal highlightSetting(anchor: string)
	signal subPageClosed
	signal subPageOpened(idx: int)

	function closeSubPage(): void {
		subPageClosed();
		subPageIdxStack.pop();
	}

	// Jump straight to a setting from search: open the page, then any sub-pages
	// along subPath, then let the page scroll to the anchor. subPageIdxStack is
	// filled directly so a freshly loaded StackPage opens the whole chain at
	// once (see StackPage.Component.onCompleted), which avoids the half-open
	// state that firing openSubPage signals one by one would cause.
	function jumpToSetting(pageIdx: int, subPath: var, anchor: string): void {
		const samePage = currentPageIdx === pageIdx;
		const sameSub = subPageIdxStack.length === subPath.length && subPath.every((v, i) => subPageIdxStack[i] === v);
		if (samePage && sameSub && anchor === lastAnchor) {
			// Re-clicking the exact same setting: flash it again, don't scroll.
			highlightSetting(anchor);
			return;
		}
		lastAnchor = anchor;
		if (samePage && sameSub) {
			// Same page, different setting: just scroll to it.
			searchAnchor = "";
			searchAnchor = anchor;
			return;
		}
		// Different page, or same page but different sub-page: point at the
		// target sub-page chain and load the destination page, which scrolls to
		// the anchor once it's ready.
		searchAnchor = anchor;
		if (!samePage) {
			pendingSubPath = subPath.slice();
			currentPageIdx = pageIdx;
		} else {
			// Same page: close back to the page root, then open the chain.
			while (subPageIdxStack.length > 0)
				closeSubPage();
			for (let i = 0; i < subPath.length; i++)
				openSubPage(subPath[i]);
		}
	}

	function openSubPage(idx: int): void {
		subPageIdxStack.push(idx);
		subPageOpened(idx);
	}

	onCurrentPageIdxChanged: {
		subPageIdxStack = pendingSubPath;
		pendingSubPath = [];
	}
}
