pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomMouseArea {
	id: root

	property int activeGrid: 1
	required property PersistentProperties dashState
	property bool initialized: false
	property int month1
	property int month2
	readonly property int realCurrMonth: dashState.currentDate.getMonth()
	readonly property int realCurrYear: dashState.currentDate.getFullYear()
	property int year1
	property int year2

	function handleDateChange() {
		const currM = activeGrid === 1 ? month1 : month2;
		const currY = activeGrid === 1 ? year1 : year2;
		if (realCurrMonth !== currM || realCurrYear !== currY) {
			monthChangeAnim.direction = (realCurrYear > currY || (realCurrYear === currY && realCurrMonth > currM)) ? -1 : 1;

			if (activeGrid === 1) {
				month2 = realCurrMonth;
				year2 = realCurrYear;
				activeGrid = 2;
			} else {
				month1 = realCurrMonth;
				year1 = realCurrYear;
				activeGrid = 1;
			}
			if (initialized)
				monthChangeAnim.restart();
		}
	}

	function onWheel(event: WheelEvent): void {
		if (event.angleDelta.y > 0)
			root.dashState.currentDate = new Date(root.realCurrYear, root.realCurrMonth - 1, 1);
		else if (event.angleDelta.y < 0)
			root.dashState.currentDate = new Date(root.realCurrYear, root.realCurrMonth + 1, 1);
	}

	acceptedButtons: Qt.MiddleButton
	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: inner.implicitHeight + inner.anchors.margins * 2

	Component.onCompleted: {
		month1 = realCurrMonth;
		year1 = realCurrYear;
		month2 = realCurrMonth;
		year2 = realCurrYear;

		initialized = true;
	}
	onClicked: root.dashState.currentDate = new Date()
	onRealCurrMonthChanged: handleDateChange()
	onRealCurrYearChanged: handleDateChange()

	SequentialAnimation {
		id: monthChangeAnim

		property int direction: 0

		ScriptAction {
			script: {
				if (activeGrid === 1) {
					titleTranslate1.x = -monthChangeAnim.direction * titleClip.width;
					grid1Translate.x = -monthChangeAnim.direction * gridClip.width;
					titleTranslate2.x = 0;
					grid2Translate.x = 0;
				} else {
					titleTranslate2.x = -monthChangeAnim.direction * titleClip.width;
					grid2Translate.x = -monthChangeAnim.direction * gridClip.width;
					titleTranslate1.x = 0;
					grid1Translate.x = 0;
				}
			}
		}

		ParallelAnimation {
			Anim {
				property: "x"
				target: titleTranslate1
				to: root.activeGrid === 1 ? 0 : monthChangeAnim.direction * titleClip.width
				type: Anim.DefaultSpatial
			}

			Anim {
				property: "x"
				target: grid1Translate
				to: root.activeGrid === 1 ? 0 : monthChangeAnim.direction * gridClip.width
				type: Anim.DefaultSpatial
			}

			Anim {
				property: "x"
				target: titleTranslate2
				to: root.activeGrid === 2 ? 0 : monthChangeAnim.direction * titleClip.width
				type: Anim.DefaultSpatial
			}

			Anim {
				property: "x"
				target: grid2Translate
				to: root.activeGrid === 2 ? 0 : monthChangeAnim.direction * gridClip.width
				type: Anim.DefaultSpatial
			}
		}
	}

	ColumnLayout {
		id: inner

		anchors.fill: parent
		anchors.margins: Appearance.padding.large
		spacing: Appearance.spacing.extraSmall

		RowLayout {
			id: monthNavigationRow

			Layout.fillWidth: true
			spacing: Appearance.spacing.extraSmall

			IconButton {
				icon: "chevron_left"
				padding: Appearance.padding.small
				type: IconButton.Text

				onClicked: root.dashState.currentDate = new Date(root.realCurrYear, root.realCurrMonth - 1, 1)
			}

			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true
				implicitHeight: monthYearDisplay1.implicitHeight + Appearance.padding.extraSmall * 2
				implicitWidth: monthYearDisplay1.implicitWidth + Appearance.padding.large * 2

				StateLayer {
					color: DynamicColors.palette.m3primary
					enabled: {
						const now = new Date();
						return root.realCurrMonth !== now.getMonth() || root.realCurrYear !== now.getFullYear();
					}
					radius: pressed ? Appearance.rounding.small : Appearance.rounding.large

					Behavior on radius {
						Anim {
							type: Anim.DefaultEffects
						}
					}

					onClicked: root.dashState.currentDate = new Date()
				}

				Item {
					id: titleClip

					anchors.fill: parent
					clip: true

					CustomText {
						id: monthYearDisplay1

						anchors.centerIn: parent
						// qmllint enable missing-property
						color: DynamicColors.palette.m3primary

						// qmllint disable missing-property
						text: grid1.item ? grid1.item.title : ""
						visible: root.activeGrid === 1 || monthChangeAnim.running

						transform: Translate {
							id: titleTranslate1
						}
					}

					CustomText {
						id: monthYearDisplay2

						anchors.centerIn: parent
						// qmllint enable missing-property
						color: DynamicColors.palette.m3primary

						// qmllint disable missing-property
						text: grid2.item ? grid2.item.title : ""
						visible: root.activeGrid === 2 || monthChangeAnim.running

						transform: Translate {
							id: titleTranslate2
						}
					}
				}
			}

			IconButton {
				icon: "chevron_right"
				padding: Appearance.padding.small
				type: IconButton.Text

				onClicked: root.dashState.currentDate = new Date(root.realCurrYear, root.realCurrMonth + 1, 1)
			}
		}

		DayOfWeekRow {
			id: daysRow

			Layout.fillWidth: true
			locale: Qt.locale()

			delegate: CustomText {
				required property var model

				color: (model.day === 0) ? DynamicColors.palette.m3tertiary : DynamicColors.palette.m3onSurface
				horizontalAlignment: Text.AlignHCenter
				text: Qt.locale("en_US").standaloneDayName(model.day, Locale.ShortFormat)
			}
		}

		Item {
			id: gridClip

			Layout.fillWidth: true
			clip: true
			implicitHeight: grid1.implicitHeight

			Component {
				id: gridComp

				Item {
					id: internalGridContainer

					property int month
					property alias title: internalGrid.title
					property int year

					implicitHeight: internalGrid.implicitHeight

					MonthGrid {
						id: internalGrid

						anchors.fill: parent
						locale: daysRow.locale
						month: internalGridContainer.month
						spacing: 3
						title: `${Qt.locale("en_US").standaloneMonthName(month, Locale.LongFormat)} ${year}`
						year: internalGridContainer.year

						delegate: Item {
							id: dayItem

							required property var model

							implicitHeight: text.implicitHeight + Appearance.padding.normal * 2
							implicitWidth: implicitHeight

							CustomText {
								id: text

								anchors.centerIn: parent
								color: {
									const dayOfWeek = dayItem.model.date.getDay();
									if (dayOfWeek === 0)
										return DynamicColors.palette.m3tertiary;

									return DynamicColors.palette.m3onSurfaceVariant;
								}
								horizontalAlignment: Text.AlignHCenter
								opacity: dayItem.model.today || dayItem.model.month === internalGrid.month ? 1 : 0.4
								text: internalGrid.locale.toString(dayItem.model.day)
							}
						}
					}

					CustomRect {
						id: todayIndicator

						property Item today
						readonly property Item todayItem: internalGrid.contentItem.children.find(c => c.model.today) ?? null

						clip: true
						color: DynamicColors.palette.m3primary
						implicitHeight: width
						implicitWidth: today ? (Math.max(today.implicitWidth, today.implicitHeight) - Appearance.padding.extraSmall) : 0
						opacity: todayItem ? 1 : 0
						radius: Appearance.rounding.full
						scale: todayItem ? 1 : 0.7
						x: today ? today.x + (today.width - implicitWidth) / 2 : 0
						y: today ? today.y + Appearance.padding.extraSmall / 2 : 0

						Behavior on opacity {
							Anim {
								type: Anim.DefaultEffects
							}
						}
						Behavior on scale {
							Anim {
								type: Anim.FastSpatial
							}
						}
						Behavior on x {
							Anim {
							}
						}
						Behavior on y {
							Anim {
							}
						}

						onTodayItemChanged: {
							if (todayItem)
								today = todayItem;
						}

						Coloriser {
							colorizationColor: DynamicColors.palette.m3onPrimary
							implicitHeight: internalGrid.height
							implicitWidth: internalGrid.width
							source: internalGrid
							sourceColor: DynamicColors.palette.m3onSurface
							x: -todayIndicator.x
							y: -todayIndicator.y
						}
					}
				}
			}

			Loader {
				id: grid1

				anchors.fill: parent
				sourceComponent: gridComp
				visible: root.activeGrid === 1 || monthChangeAnim.running

				transform: Translate {
					id: grid1Translate
				}

				Binding {
					property: "month"
					target: grid1.item
					value: root.month1
				}

				Binding {
					property: "year"
					target: grid1.item
					value: root.year1
				}
			}

			Loader {
				id: grid2

				anchors.fill: parent
				sourceComponent: gridComp
				visible: root.activeGrid === 2 || monthChangeAnim.running

				transform: Translate {
					id: grid2Translate
				}

				Binding {
					property: "month"
					target: grid2.item
					value: root.month2
				}

				Binding {
					property: "year"
					target: grid2.item
					value: root.year2
				}
			}
		}
	}
}
