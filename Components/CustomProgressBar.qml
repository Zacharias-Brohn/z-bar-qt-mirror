pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates
import ZShell
import ZShell.Components
import ZShell.Internal
import qs.Config

ProgressBar {
	id: root

	enum IndeterminateAnimState {
		Running,
		Completing,
		Stopped
	}

	property color bgColor: DynamicColors.palette.m3secondaryContainer
	property color fgColor: DynamicColors.palette.m3primary
	property int indeterminateAnimState: CustomProgressBar.Stopped
	property real waveAmplitude: 0.5
	property int waveDuration: 1000
	property int waveFrequency: 6
	property bool wavePaused
	property bool wavy

	function toBounds(startFrac: real, endFrac: real, gapSize: real): point {
		startFrac = ZUtils.clamp(startFrac, 0, 1);
		endFrac = ZUtils.clamp(endFrac, 0, 1);

		// Ramp down gap size
		const GAP_RAMP_DOWN_THRESHOLD = 0.01;
		gapSize += height / 2;
		const startGapSize = (gapSize * ZUtils.clamp(startFrac, 0, GAP_RAMP_DOWN_THRESHOLD) / GAP_RAMP_DOWN_THRESHOLD);
		const endGapSize = (gapSize * (1 - ZUtils.clamp(endFrac, 1 - GAP_RAMP_DOWN_THRESHOLD, 1)) / GAP_RAMP_DOWN_THRESHOLD);
		const start = width * startFrac + startGapSize;
		const end = width * endFrac - endGapSize;

		return start >= end ? Qt.point(0, 0) : Qt.point(start, end);
	}

	function updateIAnimState(): void {
		if (indeterminate) {
			manager.completeEndProgress = 0;
			indeterminateAnimState = CustomProgressBar.Running;
		} else if (indeterminateAnimState === CustomProgressBar.Running) {
			indeterminateAnimState = CustomProgressBar.Completing;
		}
	}

	implicitHeight: 4
	implicitWidth: 200

	contentItem: Loader {
		anchors.fill: parent
		asynchronous: true
		sourceComponent: root.indeterminate || root.indeterminateAnimState !== CustomProgressBar.Stopped ? indeterminateComp : determinateComp
	}

	Component.onCompleted: updateIAnimState()
	onIndeterminateChanged: updateIAnimState()

	LinearIndicatorManager {
		id: manager

		gap: Appearance.spacing.extraSmall

		Anim on completeEndProgress {
			duration: manager.completeEndDuration
			running: root.indeterminateAnimState === CustomProgressBar.Completing
			to: 1

			onFinished: {
				if (root.indeterminateAnimState === CustomProgressBar.Completing)
					root.indeterminateAnimState = CustomProgressBar.Stopped;
			}
		}
		Anim on progress {
			duration: manager.duration
			easing.type: Easing.Linear
			from: 0
			loops: Animation.Infinite
			running: root.indeterminateAnimState !== CustomProgressBar.Stopped
			to: 1
		}
	}

	Component {
		id: determinateComp

		Item {
			Line {
				id: remaining

				anchors.right: parent.right
				implicitWidth: parent.width - wave.implicitWidth - Appearance.spacing.extraSmall
			}

			Line {
				property real implicitSize

				anchors.right: parent.right
				anchors.rightMargin: (parent.height - implicitHeight) / 2
				anchors.verticalCenter: parent.verticalCenter
				color: root.fgColor
				implicitHeight: implicitSize
				implicitWidth: implicitSize
				radius: Appearance.rounding.full

				Behavior on implicitSize {
					Anim {
						type: Anim.FastSpatial
					}
				}

				Component.onCompleted: implicitSize = Qt.binding(() => parent.width - wave.implicitWidth < parent.height ? parent.height : 4)
			}

			Wave {
				id: wave

				anchors.left: parent.left

				Behavior on implicitWidth {
					Anim {
					}
				}

				Component.onCompleted: implicitWidth = Qt.binding(() => parent.width * root.visualPosition)
			}
		}
	}

	Component {
		id: indeterminateComp

		Item {
			id: content

			Line {
				bounds: {
					const i = manager.activeIndicators[0]; // qmllint disable unresolved-type
					return i ? root.toBounds(0, i.startFraction, i.gapSize / 2) : Qt.point(0, 0);
				}
			}

			Line {
				bounds: {
					const i = manager.activeIndicators[manager.activeIndicators.length - 1]; // qmllint disable unresolved-type
					return i ? root.toBounds(i.endFraction, 1, i.gapSize / 2) : Qt.point(0, 0);
				}
			}

			Instantiator {
				model: Math.max(manager.activeIndicators.length, 1) - 1 // qmllint disable unresolved-type

				delegate: Line {
					readonly property LinearIndicatorSegment cur: manager.activeIndicators[index] // qmllint disable unresolved-type
					required property int index
					readonly property LinearIndicatorSegment next: manager.activeIndicators[index + 1 % manager.activeIndicators.length] // qmllint disable unresolved-type

					bounds: root.toBounds(cur.endFraction, next.startFraction, cur.gapSize / 2)
				}

				onObjectAdded: (_, obj) => content.data.push(obj)
				onObjectRemoved: (_, obj) => {
					const idx = content.data.indexOf(obj);
					if (idx !== -1)
						content.data.splice(idx, 1);
				}
			}

			Instantiator {
				model: manager.activeIndicators // qmllint disable unresolved-type

				delegate: Wave {
					readonly property point bounds: root.toBounds(modelData.startFraction, modelData.endFraction, modelData.gapSize / 2)
					required property LinearIndicatorSegment modelData

					color: root.fgColor
					implicitWidth: bounds.y - bounds.x
					x: bounds.x
				}

				onObjectAdded: (_, obj) => content.data.push(obj)
				onObjectRemoved: (_, obj) => {
					const idx = content.data.indexOf(obj);
					if (idx !== -1)
						content.data.splice(idx, 1);
				}
			}
		}
	}

	component Line: CustomRect {
		property point bounds

		anchors.verticalCenter: parent.verticalCenter
		color: root.bgColor
		implicitHeight: parent.height
		implicitWidth: bounds.y - bounds.x
		radius: Appearance.rounding.full
		x: bounds.x
	}
	component Wave: WavyLine {
		id: wave

		amplitudeMultiplier: root.wavy ? root.waveAmplitude : 0
		anchors.verticalCenter: parent.verticalCenter
		color: root.fgColor
		frequency: root.waveFrequency
		fullLength: parent.width
		implicitHeight: lineWidth * amplitudeMultiplier * 2 + lineWidth
		lineWidth: parent.height
		startX: x

		Behavior on amplitudeMultiplier {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		Behavior on color {
			CAnim {
			}
		}
		Anim on waveProgress {
			duration: root.waveDuration
			easing.type: Easing.Linear
			from: 0
			loops: Animation.Infinite
			paused: wave.amplitudeMultiplier === 0 || root.wavePaused
			running: true
			to: 1
		}
	}
}
