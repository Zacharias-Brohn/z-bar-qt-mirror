pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root

	// The list of users that can log in graphically
	// Each user object has: username, uid, home, shell, gecos (full name), face (avatar path)
	property var users: []

	// The currently selected user index
	property int selectedIndex: 0

	// The currently selected user object (or null if none)
	readonly property var selectedUser: selectedIndex >= 0 && selectedIndex < users.length ? users[selectedIndex] : null

	// Convenience property for the selected username
	readonly property string selectedUsername: selectedUser ? selectedUser.username : ""

	// Path to store the default user preference
	readonly property string defaultUserFile: "/etc/zshell-greeter/default-user"

	// Select a user by username
	function selectUser(username: string): bool {
		for (let i = 0; i < users.length; i++) {
			if (users[i].username === username) {
				selectedIndex = i;
				return true;
			}
		}
		return false;
	}

	// Select the next user in the list (wraps around)
	function selectNext(): void {
		if (users.length === 0)
			return;
		selectedIndex = (selectedIndex + 1) % users.length;
	}

	// Select the previous user in the list (wraps around)
	function selectPrevious(): void {
		if (users.length === 0)
			return;
		selectedIndex = (selectedIndex - 1 + users.length) % users.length;
	}

	// Save the current user as the default for next login
	function saveDefaultUser(): void {
		if (selectedUser) {
			defaultUserStorage.setText(selectedUser.username);
		}
	}

	// Process to fetch the list of graphical users
	Process {
		id: userLister

		command: ["python3", Quickshell.shellDir + "/scripts/get-users"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				try {
					root.users = JSON.parse(text);

					// If we have users and no selection yet, try to select the default user
					if (root.users.length > 0) {
						// Try to load the default user
						if (defaultUserStorage.loaded) {
							const defaultUsername = defaultUserStorage.text().trim();
							if (defaultUsername && !root.selectUser(defaultUsername)) {
								// Default user not found, select first user
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

	// FileView for persisting the default user
	FileView {
		id: defaultUserStorage

		path: root.defaultUserFile
		preload: true

		onLoaded: {
			// If users are already loaded, try to select the default user
			if (root.users.length > 0) {
				const defaultUsername = text().trim();
				if (defaultUsername) {
					root.selectUser(defaultUsername);
				}
			}
		}

		onLoadFailed: {
			// File doesn't exist yet, that's fine - we'll create it on first save
			console.log("No default user file found, will use first user");
		}
	}
}
