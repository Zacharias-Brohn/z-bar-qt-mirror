pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ConnectedRect {
	id: root

	property alias delegate: list.delegate
	property int extraHeight
	readonly property alias list: list
	property alias model: list.model
	property string placeholderIcon
	property string placeholderText
	property bool showList

	Layout.fillWidth: true
	clip: true
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: (showList && list.count > 0 ? list.contentHeight : placeholder.implicitHeight + Appearance.padding.extraLarge * 2) + extraHeight

	Behavior on implicitHeight {
		Anim {
		}
	}

	Loader {
		id: placeholder

		active: opacity > 0
		anchors.centerIn: parent
		opacity: root.showList && list.count > 0 ? 0 : 1

		Behavior on opacity {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		sourceComponent: ColumnLayout {
			spacing: Appearance.spacing.extraSmall

			MaterialIcon {
				Layout.alignment: Qt.AlignHCenter
				animate: true
				color: DynamicColors.palette.m3outline
				font.pointSize: Appearance.font.size.large
				text: root.placeholderIcon
			}

			CustomText {
				Layout.alignment: Qt.AlignHCenter
				animate: true
				color: DynamicColors.palette.m3outline
				font.pointSize: Appearance.font.size.large
				text: root.placeholderText
			}
		}
	}

	ListView {
		id: list

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		interactive: false
		opacity: root.showList ? 1 : 0
		spacing: 0

		add: Transition {
			Anim {
				from: 0
				property: "opacity"
				to: 1
				type: Anim.DefaultEffects
			}
		}
		displaced: Transition {
			Anim {
				property: "opacity"
				to: 1
				type: Anim.DefaultEffects
			}

			Anim {
				property: "y"
			}
		}
		move: Transition {
			Anim {
				property: "opacity"
				to: 1
				type: Anim.DefaultEffects
			}

			Anim {
				property: "y"
			}
		}
		Behavior on opacity {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		remove: Transition {
			Anim {
				property: "opacity"
				to: 0
				type: Anim.DefaultEffects
			}
		}
	}
}
