pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root

	readonly property string defaultUserFile: "/etc/zshell-greeter/default-user"
	property int selectedIndex: 0
	readonly property var selectedUser: selectedIndex >= 0 && selectedIndex < users.length ? users[selectedIndex] : null
	readonly property string selectedUsername: selectedUser ? selectedUser.username : ""
	property var users: []

	function saveDefaultUser(): void {
		if (selectedUser) {
			defaultUserStorage.setText(selectedUser.username);
		}
	}

	function selectNext(): void {
		if (users.length === 0)
			return;
		selectedIndex = (selectedIndex + 1) % users.length;
	}

	function selectPrevious(): void {
		if (users.length === 0)
			return;
		selectedIndex = (selectedIndex - 1 + users.length) % users.length;
	}

	function selectUser(username: string): bool {
		for (let i = 0; i < users.length; i++) {
			if (users[i].username === username) {
				selectedIndex = i;
				return true;
			}
		}
		return false;
	}

	Process {
		id: userLister

		command: ["python3", Quickshell.shellDir + "/scripts/get-users"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				try {
					root.users = JSON.parse(text);

					if (root.users.length > 0) {
						if (defaultUserStorage.loaded) {
							const defaultUsername = defaultUserStorage.text().trim();
							if (defaultUsername && !root.selectUser(defaultUsername)) {
								root.selectedIndex = 0;
							}
						} else {
							root.selectedIndex = 0;
						}
					}
				} catch (e) {
					console.error("Failed to parse users:", e);
				}
			}
		}
	}

	FileView {
		id: defaultUserStorage

		path: root.defaultUserFile
		preload: true

		onLoadFailed: {}
		onLoaded: {
			if (root.users.length > 0) {
				const defaultUsername = text().trim();
				if (defaultUsername) {
					root.selectUser(defaultUsername);
				}
			}
		}
	}
}
