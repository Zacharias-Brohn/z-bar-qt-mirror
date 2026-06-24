pragma ComponentBehavior: Bound

import QtQuick
import qs.Effects

CustomFlickable {
	id: root

	property real bottomFadeOpacity: fadeShouldBeActive(false) ? 0 : 1
	property real fadeAmount: 0.1
	property real topFadeOpacity: fadeShouldBeActive(true) ? 0 : 1

	function fadeShouldBeActive(isStart: bool): bool {
		// When content is smaller than flickable size, hide fade when rebound starts
		if (contentHeight + topMargin + bottomMargin < height && rebound.running && ((isStart ? verticalOvershoot > 0 : verticalOvershoot < 0)))
			return false;

		if (isStart)
			return visibleArea.yPosition > 0;
		return visibleArea.yPosition + visibleArea.heightRatio < 1;
	}

	flickableDirection: Flickable.VerticalFlick
	layer.enabled: true

	Behavior on bottomFadeOpacity {
		Anim {
			type: Anim.SlowEffects
		}
	}
	layer.effect: Mask {
		maskSource: mask

		Rectangle {
			id: mask

			anchors.fill: parent
			layer.enabled: true
			visible: false

			gradient: Gradient {
				orientation: Gradient.Vertical

				GradientStop {
					color: Qt.rgba(0, 0, 0, root.topFadeOpacity)
					position: 0
				}

				GradientStop {
					color: Qt.rgba(0, 0, 0, 1)
					position: root.fadeAmount
				}

				GradientStop {
					color: Qt.rgba(0, 0, 0, 1)
					position: 1 - root.fadeAmount
				}

				GradientStop {
					color: Qt.rgba(0, 0, 0, root.bottomFadeOpacity)
					position: 1
				}
			}
		}
	}
	Behavior on topFadeOpacity {
		Anim {
			type: Anim.SlowEffects
		}
	}
}
