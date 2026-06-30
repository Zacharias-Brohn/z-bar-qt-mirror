import QtQuick
import Quickshell
import Quickshell.Bluetooth

QtObject {
	id: root

	property bool animatingContainer
	property int currentPageIdx
	property bool isWindow
	property ShellScreen screen
	property bool searchOpen
	property DesktopEntry selectedApp
	property BluetoothDevice selectedBtDevice
	property string selectedWallpaperCategory
	property list<int> subPageIdxStack

	signal close
	signal subPageClosed
	signal subPageOpened(idx: int)

	function closeSubPage(): void {
		subPageClosed();
		subPageIdxStack.pop();
	}

	function openSubPage(idx: int): void {
		subPageIdxStack.push(idx);
		subPageOpened(idx);
	}

	onCurrentPageIdxChanged: subPageIdxStack.length = 0
}
