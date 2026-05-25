import Quickshell
import QtQuick
import ZShell.Models
import qs.Config

Repeater {
	model: FetchPlugins.plugins

	LazyLoader {
		required property FileSystemEntry modelData

		activeAsync: Config.plugins.entries.some(p => {
			return p.id === modelData.baseName && p.enabled;
		})
		source: modelData.path
	}
}
