pragma Singleton

import Quickshell
import ZShell.Models

Singleton {
	id: root

	property alias plugins: plugins.entries

	FileSystemModel {
		id: plugins

		nameFilters: ["*.qml"]
		path: Quickshell.env("HOME") + "/.config/zshell"
		recursive: false
	}
}
