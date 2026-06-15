import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	default property alias contentData: clayout.data

	function scrollToSectionAndHighlight(sectionId: string, settingName: string): bool {
		for (let i = 0; i < clayout.children.length; i++) {
			const section = clayout.children[i];
			if (section.sectionId === sectionId) {
				const targetY = section.y - Appearance.padding.normal;
				flickable.contentY = Math.max(0, Math.min(targetY, flickable.contentHeight - flickable.height));

				SettingsHighlight.highlight(settingName);
				return true;
			}
		}
		return false;
	}

	CustomFlickable {
		id: flickable

		anchors.fill: parent
		// for future:
		// anchors.leftMargin: Appearance.padding.extraLarge
		// anchors.rightMargin: Appearance.padding.extraLarge
		clip: true
		contentHeight: clayout.implicitHeight + clayout.anchors.margins * 2

		CustomScrollBar.vertical: CustomScrollBar {
			flickable: flickable
		}

		TapHandler {
			acceptedButtons: Qt.LeftButton

			onTapped: function (eventPoint) {
				const menu = SettingsDropdowns.activeMenu;
				if (!menu)
					return;

				const p = eventPoint.scenePosition;

				if (SettingsDropdowns.hit(SettingsDropdowns.activeTrigger, p))
					return;

				if (SettingsDropdowns.hit(menu, p))
					return;

				SettingsDropdowns.closeActive();
			}
		}

		Column {
			id: clayout

			anchors.left: parent.left
			anchors.margins: Appearance.padding.extraSmall
			anchors.right: parent.right
			anchors.top: parent.top
			spacing: Appearance.spacing.small

			// move: Transition {
			// 	Anim {
			// 		properties: "y"
			// 	}
			// }
		}
	}
}
