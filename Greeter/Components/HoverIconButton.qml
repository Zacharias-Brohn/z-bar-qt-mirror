import QtQuick
import QtQuick.Controls
import qs.Config

IconButton {
	id: root

	required property bool shouldBeVisible

	opacity: 0
	scale: 0
	visible: root.scale > 0

	Behavior on opacity {
		Anim {
			duration: Appearance.anim.durations.small
		}
	}
	Behavior on scale {
		Anim {
		}
	}

	onShouldBeVisibleChanged: {
		if (root.shouldBeVisible) {
			root.opacity = 1;
			root.scale = 1;
		} else {
			root.opacity = 0;
			root.scale = 0;
		}
	}
}
