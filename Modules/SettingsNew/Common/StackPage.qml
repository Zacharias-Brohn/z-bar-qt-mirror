import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Modules.SettingsNew
import qs.Config

StackView {
	id: root

	readonly property int animMovement: Appearance.padding.extraLarge * 2
	default property list<Component> pages
	required property SettingsState sState

	function openSubPage(idx: int, immediate: bool): void {
		const page = pages[idx];
		if (page) {
			push(page, {
				sState
			}, immediate ? StackView.Immediate : StackView.PushTransition);
		} else {
			console.warn(logCat, "Attempted to open invalid sub-page index", idx);
			sState.closeSubPage();
		}
	}

	clip: busy

	popEnter: Transition {
		SequentialAnimation {
			PropertyAction {
				property: "opacity"
				value: 0
			}

			PauseAnimation {
				duration: Appearance.anim.durations.expressiveEffects
			}

			ParallelAnimation {
				Anim {
					property: "opacity"
					to: 1
					type: Anim.SlowEffects
				}

				Anim {
					from: -root.animMovement
					property: "x"
					to: 0
					type: Anim.SlowEffects
				}
			}
		}
	}
	popExit: Transition {
		Anim {
			property: "opacity"
			to: 0
			type: Anim.DefaultEffects
		}
	}
	pushEnter: Transition {
		SequentialAnimation {
			PropertyAction {
				property: "opacity"
				value: 0
			}

			PauseAnimation {
				duration: Appearance.anim.durations.expressiveEffects
			}

			ParallelAnimation {
				Anim {
					property: "opacity"
					to: 1
					type: Anim.SlowEffects
				}

				Anim {
					from: root.animMovement
					property: "x"
					to: 0
					type: Anim.SlowEffects
				}
			}
		}
	}
	pushExit: Transition {
		Anim {
			property: "opacity"
			to: 0
			type: Anim.DefaultEffects
		}
	}

	Component.onCompleted: {
		openSubPage(0, true);
		for (const page of sState.subPageIdxStack)
			openSubPage(page, true);
	}

	LoggingCategory {
		id: logCat

		defaultLogLevel: LoggingCategory.Info
		name: "ZShell.settings"
	}

	Connections {
		function onSubPageClosed(): void {
			if (root.depth < root.sState.subPageIdxStack.length) {
				console.log(logCat, "Attempted to close page while depth < stack depth. Ignoring.");
				return;
			}
			root.pop();
		}

		function onSubPageOpened(idx: int): void {
			root.openSubPage(idx, false);
		}

		target: root.sState
	}
}
