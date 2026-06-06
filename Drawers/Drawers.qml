pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Variants {
	model: Quickshell.screens

	Scope {
		id: scope

		required property ShellScreen modelData

		Exclusions {
			bar: content.bar
			screen: scope.modelData
		}

		Windows {
			id: content

			screen: scope.modelData
		}
	}
}
