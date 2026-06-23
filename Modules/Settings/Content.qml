pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Modules as Modules
import qs.Modules.Settings.Categories as Cat
import qs.Config
import qs.Helpers

Item {
	id: root

	property string currentCategory: "general"
	property int currentIndex: 0
	property int lastIndex: 0
	readonly property real nonAnimHeight: Math.floor(screen.height / 1.5) + viewWrapper.anchors.margins * 2
	readonly property real nonAnimWidth: view.implicitWidth + Math.floor(screen.width / 2) + viewWrapper.anchors.margins * 2
	property string pendingSection: ""
	property string pendingSetting: ""
	required property ShellScreen screen
	required property PersistentProperties visibilities

	function scrollToSetting(section: string, settingName: string) {
		root.pendingSection = section;
		root.pendingSetting = settingName;
		scrollTimer.restart();
	}

	function setCategory(category: string, index: int): void {
		currentIndex = index;
		currentCategory = category;
	}

	implicitHeight: nonAnimHeight
	implicitWidth: nonAnimWidth

	Timer {
		id: scrollTimer

		interval: 50

		onTriggered: {
			if (root.pendingSection && stack.currentItem) {
				stack.currentItem.scrollToSectionAndHighlight(root.pendingSection, root.pendingSetting);
				root.pendingSection = "";
				root.pendingSetting = "";
			}
		}
	}

	Connections {
		function onCurrentCategoryChanged() {
			if (root.currentCategory === "general") {
				stack.replaceCurrentItem(general, [], StackView.PopTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "wallpaper") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(background, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(background, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "bar") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(bar, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(bar, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "appearance") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(appearance, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(appearance, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "lockscreen") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(lockscreen, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(lockscreen, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "services") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(services, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(services, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "notifications") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(notifications, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(notifications, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "sidebar") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(sidebar, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(sidebar, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "utilities") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(utilities, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(utilities, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "dashboard") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(dashboard, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(dashboard, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "osd") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(osd, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(osd, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "launcher") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(launcher, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(launcher, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "screenshot") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(screenshot, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(screenshot, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			} else if (root.currentCategory === "updates") {
				if (root.currentIndex < root.lastIndex)
					stack.replaceCurrentItem(updates, [], StackView.PopTransition);
				else
					stack.replaceCurrentItem(updates, [], StackView.PushTransition);
				root.lastIndex = root.currentIndex;
			}
		}

		target: root
	}

	CustomClippingRect {
		id: viewWrapper

		anchors.fill: parent
		anchors.margins: Appearance.padding.smaller
		radius: Appearance.rounding.large - Appearance.padding.smaller

		SettingsSearch {
			id: searchBar

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top

			onSettingSelected: (category, section, settingName) => {
				layout.selectCategory(category);
				root.scrollToSetting(section, settingName);
			}
		}

		Item {
			id: view

			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: searchBar.bottom
			anchors.topMargin: Appearance.spacing.smaller
			implicitWidth: layout.implicitWidth

			Categories {
				id: layout

				anchors.fill: parent
				content: root

				onSettingSelected: (category, section, settingName) => {
					root.scrollToSetting(section, settingName);
				}
			}
		}

		CustomClippingRect {
			id: categoryContent

			anchors.bottom: parent.bottom
			anchors.left: view.right
			anchors.leftMargin: Appearance.spacing.smaller
			anchors.right: parent.right
			anchors.top: searchBar.bottom
			anchors.topMargin: Appearance.spacing.smaller
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.normal

			StackView {
				id: stack

				anchors.fill: parent
				initialItem: general

				popEnter: Transition {
					SequentialAnimation {
						Anim {
							duration: 0
							from: 0
							property: "opacity"
							to: 0
						}

						PauseAnimation {
							duration: Appearance.anim.durations.expressiveEffects
						}

						ParallelAnimation {
							Anim {
								duration: Appearance.anim.durations.expressiveFastSpatial
								from: 0
								property: "opacity"
								to: 1
							}

							Anim {
								duration: Appearance.anim.durations.expressiveFastSpatial
								from: -50
								property: "y"
								to: 0
							}
						}
					}
				}
				popExit: Transition {
					ParallelAnimation {
						Anim {
							duration: Appearance.anim.durations.expressiveFastSpatial
							from: 1
							property: "opacity"
							to: 0
						}

						Anim {
							duration: Appearance.anim.durations.expressiveFastSpatial
							from: 0
							property: "y"
							to: 50
						}
					}
				}
				pushEnter: Transition {
					SequentialAnimation {
						Anim {
							duration: 0
							from: 0
							property: "opacity"
							to: 0
						}

						PauseAnimation {
							duration: Appearance.anim.durations.expressiveEffects
						}

						ParallelAnimation {
							Anim {
								duration: Appearance.anim.durations.expressiveFastSpatial
								from: 0
								property: "opacity"
								to: 1
							}

							Anim {
								duration: Appearance.anim.durations.expressiveFastSpatial
								from: 50
								property: "y"
								to: 0
							}
						}
					}
				}
				pushExit: Transition {
					ParallelAnimation {
						Anim {
							duration: Appearance.anim.durations.expressiveFastSpatial
							from: 1
							property: "opacity"
							to: 0
						}

						Anim {
							duration: Appearance.anim.durations.expressiveFastSpatial
							from: 0
							property: "y"
							to: -50
						}
					}
				}
			}
		}
	}

	Component {
		id: general

		Cat.General {
		}
	}

	Component {
		id: background

		Cat.Background {
			screen: root.screen
		}
	}

	Component {
		id: appearance

		Cat.Appearance {
		}
	}

	Component {
		id: bar

		Cat.Bar {
		}
	}

	Component {
		id: lockscreen

		Cat.Lockscreen {
		}
	}

	Component {
		id: services

		Cat.Services {
		}
	}

	Component {
		id: notifications

		Cat.Notifications {
		}
	}

	Component {
		id: sidebar

		Cat.Sidebar {
		}
	}

	Component {
		id: utilities

		Cat.Utilities {
		}
	}

	Component {
		id: dashboard

		Cat.Dashboard {
		}
	}

	Component {
		id: osd

		Cat.Osd {
		}
	}

	Component {
		id: launcher

		Cat.Launcher {
		}
	}

	Component {
		id: screenshot

		Cat.Screenshot {
		}
	}

	Component {
		id: updates

		Cat.SystemUpdates {
		}
	}
}
