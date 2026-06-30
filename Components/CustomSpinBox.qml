import QtQuick
import QtQuick.Templates
import qs.Config

DoubleSpinBox {
	id: root

	property int cLayer: 1
	property int repeatDecay: 50
	property int repeatRate: 400

	function decrease(): void {
		let newValue = Math.max(from, value - stepSize);
		const decimals = stepSize < 1 ? Math.max(1, Math.ceil(-Math.log10(stepSize))) : 0;
		newValue = Math.round(newValue * Math.pow(10, decimals)) / Math.pow(10, decimals);
		value = newValue;
		valueModified();
	}

	function increase(): void {
		let newValue = Math.min(to, value + stepSize);
		const decimals = stepSize < 1 ? Math.max(1, Math.ceil(-Math.log10(stepSize))) : 0;
		newValue = Math.round(newValue * Math.pow(10, decimals)) / Math.pow(10, decimals);
		value = newValue;
		valueModified();
	}

	decimals: stepSize < 1 ? Math.max(1, Math.ceil(-Math.log10(stepSize))) : 0
	editable: true
	implicitHeight: Math.max(up.indicator.implicitHeight, down.indicator.implicitHeight, contentItem.implicitHeight) + topPadding + bottomPadding
	implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
	leftPadding: up.indicator.implicitWidth + Appearance.spacing.extraSmall / 2
	rightPadding: down.indicator.implicitWidth + Appearance.spacing.extraSmall / 2
	spacing: Appearance.spacing.small

	contentItem: TextFieldBase {
		horizontalAlignment: TextField.AlignHCenter
		implicitWidth: 65
		inputMethodHints: Qt.ImhFormattedNumbersOnly
		leftPadding: Appearance.padding.larger
		readOnly: !root.editable
		rightPadding: Appearance.padding.larger
		text: root.textFromValue(root.value, root.locale)
		validator: root.validator

		background: CustomRect {
			color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, root.cLayer)
			radius: Appearance.rounding.extraSmall
		}
	}
	down.indicator: IconButton {
		id: downButton

		bottomRightRadius: pressed ? Appearance.rounding.small : Appearance.rounding.extraSmall
		color: enabled ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, root.cLayer) : disabledColor
		disabledColor: Qt.alpha(DynamicColors.palette.m3surfaceContainerHighest, 0.4)
		icon: "remove"
		isRound: true
		label.anchors.horizontalCenterOffset: pressed ? 0 : 2
		padding: Appearance.padding.extraSmall
		topRightRadius: pressed ? Appearance.rounding.small : Appearance.rounding.extraSmall
		type: IconButton.Text

		Behavior on bottomRightRadius {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		Behavior on label.anchors.horizontalCenterOffset {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		Behavior on topRightRadius {
			Anim {
				type: Anim.DefaultEffects
			}
		}
	}
	up.indicator: IconButton {
		id: upButton

		anchors.right: parent.right
		bottomLeftRadius: pressed ? Appearance.rounding.small : Appearance.rounding.extraSmall
		color: enabled ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, root.cLayer) : disabledColor
		disabledColor: Qt.alpha(DynamicColors.palette.m3surfaceContainerHighest, 0.4)
		icon: "add"
		isRound: true
		label.anchors.horizontalCenterOffset: pressed ? 0 : -2
		padding: Appearance.padding.extraSmall
		topLeftRadius: pressed ? Appearance.rounding.small : Appearance.rounding.extraSmall
		type: IconButton.Text

		Behavior on bottomLeftRadius {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		Behavior on label.anchors.horizontalCenterOffset {
			Anim {
				type: Anim.DefaultEffects
			}
		}
		Behavior on topLeftRadius {
			Anim {
				type: Anim.DefaultEffects
			}
		}
	}

	Timer {
		id: timer

		interval: root.repeatRate
		repeat: true
		running: upButton.pressed || downButton.pressed
		triggeredOnStart: true

		onRunningChanged: {
			if (!running)
				interval = root.repeatRate;
		}
		onTriggered: {
			if (upButton.pressed)
				root.increase();
			else if (downButton.pressed)
				root.decrease();
			if (interval > root.repeatDecay)
				interval -= root.repeatDecay;
		}
	}
}
