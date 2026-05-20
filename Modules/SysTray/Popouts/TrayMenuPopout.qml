pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Modules
import qs.Config

SubMenu {
	id: root

	handle: trayItem
	level: 0

	required property QsMenuHandle trayItem
}