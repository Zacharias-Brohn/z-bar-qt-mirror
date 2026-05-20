import QtQuick

QtObject {
	id: root

	property string currentName
	property bool hasCurrent
	property var submenus: []

	signal detachRequested(mode: string)

	function clearSubmenus(): void {
		submenus = [];
	}

	function closeSubmenus(level: int): void {
		submenus = submenus.slice(0, level);
	}

	function pushSubmenu(level: int, handle: var, sourceItem: var, sourceWidth: int): void {
		let newSubmenus = submenus.slice(0, level);
		newSubmenus.push({
			"handle": handle,
			"sourceItem": sourceItem,
			"sourceWidth": sourceWidth
		});
		submenus = newSubmenus;
	}

	onCurrentNameChanged: {
		root.clearSubmenus();
	}
	onHasCurrentChanged: {
		root.clearSubmenus();
	}
}
