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

	function jumpToSetting(pageIdx: int, subPath: var, anchor: string): void {
		const samePage = currentPageIdx === pageIdx;
		const sameSub = subPageIdxStack.length === subPath.length && subPath.every((v, i) => subPageIdxStack[i] === v);
		if (samePage && sameSub && anchor === lastAnchor) {
			highlightSetting(anchor);
			return;
		}
		lastAnchor = anchor;
		if (samePage && sameSub) {
			searchAnchor = "";
			searchAnchor = anchor;
			return;
		}
		searchAnchor = anchor;
		if (!samePage) {
			pendingSubPath = subPath.slice();
			currentPageIdx = pageIdx;
		} else {
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
