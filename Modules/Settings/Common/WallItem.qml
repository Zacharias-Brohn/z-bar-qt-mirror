pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Config

Item {
	id: root

	property alias imgHeight: imgWrapper.implicitHeight
	property alias radius: imgWrapper.radius
	property alias source: img.source

	signal clicked

	Layout.fillWidth: true
	implicitHeight: layout.implicitHeight

	ColumnLayout {
		id: layout

		anchors.fill: parent
		spacing: Appearance.spacing.small

		CustomClippingRect {
			id: imgWrapper

			Layout.fillWidth: true
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitHeight: width
			radius: Appearance.rounding.large

			Image {
				id: img

				anchors.fill: parent
				asynchronous: true
				fillMode: Image.PreserveAspectCrop
				opacity: status === Image.Ready ? 1 : 0
				retainWhileLoading: true
				sourceSize: {
					const dpr = (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1;
					return Qt.size(width * dpr, height * dpr);
				}

				Behavior on opacity {
					Anim {
						type: Anim.SlowEffects
					}
				}
			}
		}
	}

	StateLayer {
		anchors.bottomMargin: layout.implicitHeight - imgWrapper.implicitHeight

		onClicked: root.clicked()
	}
}
