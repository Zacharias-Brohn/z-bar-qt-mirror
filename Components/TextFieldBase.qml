import QtQuick
import QtQuick.Templates
import qs.Config

TextField {
	id: root

	color: DynamicColors.palette.m3onSurface
	cursorVisible: !readOnly
	font.pointSize: Appearance.font.size.small
	implicitHeight: contentHeight + topPadding + bottomPadding
	implicitWidth: contentWidth + leftPadding + rightPadding
	placeholderTextColor: DynamicColors.palette.m3onSurfaceVariant // No anim cause placeholder is custom
	renderType: echoMode === TextField.Password ? TextField.QtRendering : TextField.NativeRendering
	selectedTextColor: color
	selectionColor: Qt.alpha(DynamicColors.palette.m3primary, 0.4)
	verticalAlignment: TextInput.AlignVCenter

	Behavior on color {
		CAnim {
		}
	}
	cursorDelegate: Item {
	}
	Behavior on selectionColor {
		CAnim {
		}
	}

	CustomRect {
		id: cursor

		property bool disableBlink

		color: DynamicColors.palette.m3primary
		implicitHeight: root.cursorRectangle.height
		implicitWidth: 1.5
		radius: Appearance.rounding.large
		x: root.cursorRectangle.x
		y: root.cursorRectangle.y

		Behavior on opacity {
			Anim {
				type: Anim.StandardSmall
			}
		}
		Behavior on x {
			Anim {
				duration: Appearance.anim.durations.expressiveFastEffects
				easing.bezierCurve: [0.2, 1, 0.21, 1, 1, 1]
			}
		}

		Connections {
			function onCursorPositionChanged(): void {
				if (root.activeFocus && root.cursorVisible) {
					cursor.opacity = 1;
					cursor.disableBlink = true;
					enableBlink.restart();
				}
			}

			target: root
		}

		Timer {
			id: enableBlink

			interval: 500

			onTriggered: cursor.disableBlink = false
		}

		Timer {
			interval: 500
			repeat: true
			running: root.activeFocus && root.cursorVisible && !cursor.disableBlink
			triggeredOnStart: true

			onTriggered: parent.opacity = parent.opacity === 1 ? 0 : 1
		}

		Binding {
			cursor.opacity: 0
			when: !root.activeFocus || !root.cursorVisible
		}
	}
}
