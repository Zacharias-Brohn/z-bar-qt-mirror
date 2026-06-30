import QtQuick
import Quickshell
import qs.Config

Image {
	id: root

	property int fadeInAnim: Anim.DefaultEffects
	property int fadeInLargeAnim: Anim.StandardLarge
	property int fadeOutAnim: Anim.FastEffects
	property bool fadingOut
	property bool hadPrevious
	property bool preventInit

	function maybeStartInAnim(): void {
		if (!preventInit && !opacityInAnim.running && status === Image.Ready) {
			opacityInAnim.type = hadPrevious ? fadeInAnim : fadeInLargeAnim;
			opacityInAnim.start();
		}
	}

	asynchronous: true
	fillMode: Image.PreserveAspectCrop
	opacity: 0
	retainWhileLoading: true
	sourceSize: {
		const dpr = (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1;
		return Qt.size(width * dpr, height * dpr);
	}

	Anim on opacity {
		id: opacityInAnim

		running: false
		to: 1
	}
	Behavior on source {
		SequentialAnimation {
			ScriptAction {
				script: opacityInAnim.stop()
			}

			PropertyAction {
				property: "fadingOut"
				target: root
				value: true
			}

			Anim {
				property: "opacity"
				target: root
				to: 0
				type: root.fadeOutAnim
			}

			PropertyAction {
				property: "fadingOut"
				target: root
				value: false
			}

			PropertyAction {
				property: "hadPrevious"
				target: root
				value: root.source
			}

			PropertyAction {
			}

			ScriptAction {
				script: root.maybeStartInAnim()
			}
		}
	}

	onPreventInitChanged: maybeStartInAnim()
	onStatusChanged: maybeStartInAnim()
}
