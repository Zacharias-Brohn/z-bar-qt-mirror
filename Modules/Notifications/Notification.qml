pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.Notifications
import ZShell.Components
import qs.Daemons
import qs.Helpers
import qs.Config
import qs.Components

CustomRect {
	id: root

	readonly property int bodyTextFormat: /[<*_`#\[\]]/.test(modelData.body) ? Text.MarkdownText : Text.PlainText
	property bool expanded: Config.notifs.openExpanded
	readonly property bool hasAppIcon: modelData.appIcon.length > 0
	readonly property bool hasImage: modelData.image.length > 0
	required property NotifServer.Notif modelData
	readonly property int nonAnimHeight: summary.implicitHeight + (root.expanded ? Appearance.spacing.extraSmall * 2 + appName.height + body.height + actions.height + actions.anchors.topMargin : bodyPreview.height) + inner.anchors.margins * 2

	color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondaryContainer : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: inner.implicitHeight
	radius: Appearance.rounding.small
	x: implicitWidth

	Behavior on x {
		Anim {
			easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
		}
	}

	Component.onCompleted: {
		x = 0;
		modelData.lock(this);
	}
	Component.onDestruction: modelData.unlock(this)

	MouseArea {
		property int startY

		acceptedButtons: Qt.LeftButton | Qt.MiddleButton
		anchors.fill: parent
		cursorShape: root.expanded && body.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
		drag.axis: Drag.XAxis
		drag.target: parent
		hoverEnabled: true
		preventStealing: true

		onClicked: event => {
			if (!Config.notifs.actionOnClick || event.button !== Qt.LeftButton)
				return;

			const actions = root.modelData.actions;
			if (actions.length === 1)
				actions[0].invoke();
		}
		onEntered: root.modelData.timer.stop()
		onExited: {
			if (!pressed)
				root.modelData.timer.start();
		}
		onPositionChanged: event => {
			if (pressed) {
				const diffY = event.y - startY;
				if (Math.abs(diffY) > Config.notifs.expandThreshold)
					root.expanded = diffY > 0;
			}
		}
		onPressed: event => {
			root.modelData.timer.stop();
			startY = event.y;
			if (event.button === Qt.MiddleButton)
				root.modelData.close();
		}
		onReleased: event => {
			if (!containsMouse)
				root.modelData.timer.start();

			if (Math.abs(root.x) < root.implicitWidth * Config.notifs.clearThreshold)
				root.x = 0;
			else
				root.modelData.popup = false;
		}

		Item {
			id: inner

			anchors.left: parent.left
			anchors.margins: Appearance.padding.normal
			anchors.right: parent.right
			anchors.top: parent.top
			implicitHeight: root.nonAnimHeight

			Behavior on implicitHeight {
				Anim {
				}
			}

			Loader {
				id: image

				active: root.hasImage
				anchors.left: parent.left
				anchors.top: parent.top
				asynchronous: true
				height: Config.notifs.sizes.image
				visible: root.hasImage || root.hasAppIcon
				width: Config.notifs.sizes.image

				sourceComponent: CustomClippingRect {
					color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2) : DynamicColors.palette.m3secondaryContainer
					implicitHeight: Config.notifs.sizes.image
					implicitWidth: Config.notifs.sizes.image
					radius: Appearance.rounding.full

					Image {
						anchors.fill: parent
						asynchronous: true
						cache: false
						fillMode: Image.PreserveAspectCrop
						source: Qt.resolvedUrl(root.modelData.image)
						sourceSize: {
							const size = Config.notifs.sizes.image * ((QsWindow.window as QsWindow)?.devicePixelRatio ?? 1);
							return Qt.size(size, size);
						}
					}
				}
			}

			Loader {
				id: appIcon

				active: root.hasAppIcon || !root.hasImage
				anchors.bottom: root.hasImage ? image.bottom : undefined
				anchors.horizontalCenter: root.hasImage ? undefined : image.horizontalCenter
				anchors.right: root.hasImage ? image.right : undefined
				anchors.verticalCenter: root.hasImage ? undefined : image.verticalCenter
				asynchronous: true

				sourceComponent: CustomRect {
					color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2) : DynamicColors.palette.m3secondaryContainer
					implicitHeight: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
					implicitWidth: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
					radius: Appearance.rounding.full

					Loader {
						id: icon

						active: root.hasAppIcon
						anchors.centerIn: parent
						asynchronous: true
						height: Math.round(parent.width * 0.6)
						width: Math.round(parent.width * 0.6)

						sourceComponent: ColoredIcon {
							anchors.fill: parent
							color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
							layer.enabled: root.modelData.appIcon.endsWith("symbolic")
							source: Quickshell.iconPath(root.modelData.appIcon)
						}
					}

					Loader {
						active: !root.hasAppIcon
						anchors.centerIn: parent
						anchors.verticalCenterOffset: 1
						asynchronous: true

						sourceComponent: MaterialIcon {
							color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
							text: Icons.getNotifIcon(root.modelData.summary, root.modelData.urgency)
						}
					}
				}
			}

			Shape {
				id: progressIndicator

				anchors.centerIn: appIcon
				height: appIcon.implicitHeight + progressShape.strokeWidth * 2
				preferredRendererType: Shape.CurveRenderer
				width: appIcon.implicitWidth + progressShape.strokeWidth * 2

				ShapePath {
					id: progressShape

					capStyle: ShapePath.RoundCap
					fillColor: "transparent"
					strokeColor: DynamicColors.palette.m3primary
					strokeWidth: 2

					PathAngleArc {
						id: progressArc

						centerX: progressIndicator.width / 2
						centerY: progressIndicator.height / 2
						radiusX: progressIndicator.width / 2 - Appearance.padding.extraSmall / 2
						radiusY: progressIndicator.height / 2 - Appearance.padding.extraSmall / 2
						startAngle: -90
						sweepAngle: ((root.modelData.hints.value ?? 0) / 100) * 360

						Behavior on sweepAngle {
							Anim {
								easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
							}
						}
					}
				}
			}

			CustomText {
				id: appName

				anchors.left: image.right
				anchors.leftMargin: Appearance.spacing.small
				anchors.top: parent.top
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				maximumLineCount: 1
				opacity: root.expanded ? 1 : 0
				text: appNameMetrics.elidedText

				Behavior on opacity {
					Anim {
						type: Anim.DefaultEffects
					}
				}
			}

			TextMetrics {
				id: appNameMetrics

				elide: Text.ElideRight
				elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - Appearance.spacing.small * 3
				font: appName.font
				text: root.modelData.appName
			}

			CustomText {
				id: summary

				anchors.left: image.right
				anchors.leftMargin: Appearance.spacing.small
				anchors.top: parent.top
				animate: true
				height: implicitHeight
				maximumLineCount: 1
				text: summaryMetrics.elidedText

				Behavior on height {
					Anim {
					}
				}
				states: State {
					name: "expanded"
					when: root.expanded

					PropertyChanges {
						body.anchors.topMargin: Appearance.spacing.extraSmall
						bodyPreview.anchors.topMargin: Appearance.spacing.extraSmall
						summary.anchors.topMargin: Appearance.spacing.extraSmall
						summary.maximumLineCount: undefined
					}

					AnchorChanges {
						anchors.top: appName.bottom
						target: summary
					}
				}
				transitions: Transition {
					PropertyAction {
						property: "maximumLineCount"
						target: summary
					}

					Anim {
						property: "topMargin"
					}

					AnchorAnim {
					}
				}
			}

			TextMetrics {
				id: summaryMetrics

				elide: Text.ElideRight
				elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - Appearance.spacing.small * 3
				font: summary.font
				text: root.modelData.summary
			}

			CustomText {
				id: timeSep

				anchors.left: summary.right
				anchors.leftMargin: Appearance.spacing.small
				anchors.top: parent.top
				color: DynamicColors.palette.m3onSurfaceVariant
				text: "•"

				states: State {
					name: "expanded"
					when: root.expanded

					AnchorChanges {
						anchors.left: appName.right
						target: timeSep
					}
				}
				transitions: Transition {
					AnchorAnim {
					}
				}
			}

			CustomText {
				id: time

				anchors.left: timeSep.right
				anchors.leftMargin: Appearance.spacing.small
				anchors.top: parent.top
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				horizontalAlignment: Text.AlignLeft
				text: root.modelData.timeStr
			}

			Item {
				id: expandBtn

				anchors.right: parent.right
				anchors.top: parent.top
				anchors.topMargin: -Appearance.padding.extraSmall
				implicitHeight: expandIcon.implicitHeight
				implicitWidth: expandIcon.implicitHeight

				StateLayer {
					color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
					radius: Appearance.rounding.full

					onClicked: root.expanded = !root.expanded
				}

				MaterialIcon {
					id: expandIcon

					anchors.centerIn: parent
					anchors.verticalCenterOffset: root.expanded ? -1 : 1
					rotation: root.expanded ? 180 : 0
					text: "expand_more"

					Behavior on anchors.verticalCenterOffset {
						Anim {
						}
					}
					Behavior on rotation {
						Anim {
						}
					}
				}
			}

			CustomText {
				id: bodyPreview

				anchors.left: summary.left
				anchors.right: expandBtn.left
				anchors.rightMargin: Appearance.spacing.small
				anchors.top: summary.bottom
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				opacity: root.expanded ? 0 : 1
				text: bodyPreviewMetrics.elidedText
				textFormat: root.bodyTextFormat

				Behavior on opacity {
					Anim {
						type: Anim.DefaultEffects
					}
				}
			}

			TextMetrics {
				id: bodyPreviewMetrics

				elide: Text.ElideRight
				elideWidth: bodyPreview.width
				font: bodyPreview.font
				text: root.modelData.body
			}

			CustomText {
				id: body

				anchors.left: summary.left
				anchors.right: expandBtn.left
				anchors.rightMargin: Appearance.spacing.small
				anchors.top: summary.bottom
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				height: text ? implicitHeight : 0
				opacity: root.expanded ? 1 : 0
				text: root.modelData.body
				textFormat: root.bodyTextFormat
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere

				Behavior on opacity {
					Anim {
						type: Anim.DefaultEffects
					}
				}

				onLinkActivated: link => {
					if (!root.expanded)
						return;

					Quickshell.execDetached(["app2unit", "-O", "--", link]);
					root.modelData.popup = false;
				}
			}

			ButtonRow {
				id: actions

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: body.bottom
				anchors.topMargin: Appearance.spacing.small
				opacity: root.expanded ? 1 : 0
				spacing: Appearance.spacing.extraSmall

				Behavior on opacity {
					Anim {
						type: Anim.DefaultEffects
					}
				}

				IconButton {
					fillWidth: root.modelData.actions.length === 0
					icon: "close"
					inactiveColor: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
					inactiveOnColor: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurfaceVariant
					isRound: true
					padding: Appearance.padding.extraSmall
					shapeMorph: true

					onClicked: root.modelData.close()
				}

				Repeater {
					model: root.modelData.actions

					TextButton {
						required property var modelData

						fillWidth: true
						implicitWidth: label.implicitWidth
						inactiveColor: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
						inactiveOnColor: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurfaceVariant
						isRound: true
						label.anchors.centerIn: undefined
						label.anchors.left: left
						label.anchors.margins: Appearance.padding.normal
						label.anchors.right: right
						label.anchors.verticalCenter: verticalCenter
						label.elide: Text.ElideRight
						label.horizontalAlignment: Text.AlignHCenter
						shapeMorph: true
						text: modelData.text

						onClicked: modelData.invoke()
					}
				}

				IconButton {
					fillWidth: root.modelData.actions.length === 0
					icon: copyTimer.running ? "inventory" : "content_copy"
					inactiveColor: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
					inactiveOnColor: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurfaceVariant
					isRound: true
					label.animate: true
					padding: Appearance.padding.extraSmall
					shapeMorph: true

					onClicked: {
						Quickshell.clipboardText = root.modelData.body;
						copyTimer.restart();
					}

					Timer {
						id: copyTimer

						interval: 3000
					}
				}
			}
		}
	}
}
