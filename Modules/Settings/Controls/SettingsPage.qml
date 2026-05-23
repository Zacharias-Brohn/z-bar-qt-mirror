import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

CustomClippingRect {
	id: root

	default property alias contentData: clayout.data

	// Find and scroll to a section by its sectionId, then highlight a specific setting
	function scrollToSectionAndHighlight(sectionId: string, settingName: string): bool {
		// Find the section with matching sectionId
		for (let i = 0; i < clayout.children.length; i++) {
			const section = clayout.children[i];
			if (section.sectionId === sectionId) {
				// Scroll to the section with some padding
				const targetY = section.y - Appearance.padding.normal;
				flickable.contentY = Math.max(0, Math.min(targetY, flickable.contentHeight - flickable.height));

				// Use the singleton to highlight the setting
				SettingsHighlight.highlight(settingName);
				return true;
			}
		}
		return false;
	}

	radius: Appearance.rounding.normal - Appearance.padding.smaller

	CustomFlickable {
		id: flickable

		anchors.fill: parent
		clip: true
		contentHeight: clayout.implicitHeight

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
			anchors.right: parent.right
			spacing: Appearance.spacing.small

			// move: Transition {
			// 	Anim {
			// 		properties: "y"
			// 	}
			// }
		}
	}
}
