pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import ZShell.Services
import qs.Daemons
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	property real playerProgress: {
		const active = Players.active;
		return active?.length ? (active.position % active.length) / active.length : 0;
	}
	property int rowHeight: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: cover.height + rowHeight * 2

	Behavior on playerProgress {
		Anim {
			duration: Appearance.anim.durations.large
		}
	}

	Timer {
		interval: Config.dashboard.mediaUpdateInterval
		repeat: true
		running: Players.active?.isPlaying ?? false
		triggeredOnStart: true

		onTriggered: Players.active?.positionChanged()
	}

	ServiceRef {
		service: Audio.cava
	}

	Shape {
		id: visualizer

		readonly property int bars: Config.services.visualizerBars
		property color color: DynamicColors.palette.m3tertiary
		property color fillColor: Qt.alpha(color, 0.25)

		anchors.fill: layout
		anchors.leftMargin: -(shape.strokeWidth / 2)
		layer.enabled: true
		asynchronous: true
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			id: shape
			strokeColor: visualizer.color
			fillColor: visualizer.fillColor
			strokeWidth: 2

			PathSvg {
				path: shape.curvePath
			}

			property string curvePath: {
				const values = Audio.cava.values;
				const n = values.length;

				if (n < 2)
					return "";

				const h = layout.height + shape.strokeWidth / 2;
				const w = layout.width + shape.strokeWidth;

				function x(i) {
					return i * w / (n - 1);
				}

				function y(i) {
					return h - values[i] * Config.dashboard.sizes.mediaVisualizerSize;
				}

				let d = `M 0 ${h} `;
				d += `L ${x(0)} ${y(0)} `;

				for (let i = 0; i < n - 1; ++i) {
					const x0 = x(i);
					const y0 = y(i);

					const x1 = x(i + 1);
					const y1 = y(i + 1);

					const prev = Math.max(0, i - 1);
					const next = Math.min(n - 1, i + 2);

					const c1x = x0 + (x1 - x(prev)) / 6;
					const c1y = y0 + (y1 - y(prev)) / 6;

					const c2x = x1 - (x(next) - x0) / 6;
					const c2y = y1 - (y(next) - y0) / 6;

					d += `C ${c1x} ${c1y}, ${c2x} ${c2y}, ${x1} ${y1} `;
				}

				d += `L ${w} ${h} `;
				d += `L 0 ${h} Z`;

				return d;
			}
		}
	}

	CustomRect {
		anchors.fill: visualizer

		color: Qt.alpha(DynamicColors.palette.m3shadow, 0.2)
		layer.enabled: true
		layer.effect: MultiEffect {
			maskEnabled: true
			maskSource: visualizer
		}
	}

	Shape {
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
			fillColor: "transparent"
			strokeColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
			strokeWidth: Config.dashboard.sizes.mediaProgressThickness

			Behavior on strokeColor {
				CAnim {
				}
			}

			PathAngleArc {
				centerX: cover.x + cover.width / 2
				centerY: cover.y + cover.height / 2
				radiusX: (cover.width + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				radiusY: (cover.height + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				startAngle: -90 - Config.dashboard.sizes.mediaProgressSweep / 2
				sweepAngle: Config.dashboard.sizes.mediaProgressSweep
			}
		}

		ShapePath {
			capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
			fillColor: "transparent"
			strokeColor: DynamicColors.palette.m3primary
			strokeWidth: Config.dashboard.sizes.mediaProgressThickness

			Behavior on strokeColor {
				CAnim {
				}
			}

			PathAngleArc {
				centerX: cover.x + cover.width / 2
				centerY: cover.y + cover.height / 2
				radiusX: (cover.width + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				radiusY: (cover.height + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				startAngle: -90 - Config.dashboard.sizes.mediaProgressSweep / 2
				sweepAngle: Config.dashboard.sizes.mediaProgressSweep * root.playerProgress
			}
		}
	}

	RowLayout {
		id: layout

		anchors.left: parent.left
		anchors.right: parent.right
		implicitHeight: root.implicitHeight

		CustomClippingRect {
			id: cover

			Layout.alignment: Qt.AlignLeft
			Layout.bottomMargin: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
			Layout.leftMargin: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
			Layout.preferredHeight: Config.dashboard.sizes.mediaCoverArtSize
			Layout.preferredWidth: Config.dashboard.sizes.mediaCoverArtSize
			Layout.topMargin: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
			color: DynamicColors.tPalette.m3surfaceContainerHigh
			radius: Infinity

			MaterialIcon {
				anchors.centerIn: parent
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: (parent.width * 0.4) || 1
				grade: 200
				text: "art_track"
			}

			Image {
				id: image

				anchors.fill: parent
				asynchronous: true
				fillMode: Image.PreserveAspectCrop
				source: Players.active?.trackArtUrl ?? ""
				sourceSize.height: Math.floor(height)
				sourceSize.width: Math.floor(width)
			}
		}

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			MarqueeText {
				id: title

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				color: DynamicColors.palette.m3primary
				font.pointSize: Appearance.font.size.normal
				horizontalAlignment: Text.AlignHCenter
				pauseMs: 4000
				text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
				width: parent.width - Appearance.padding.large * 4
			}

			MarqueeText {
				id: album

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: title.bottom
				anchors.topMargin: Appearance.spacing.small
				color: DynamicColors.palette.m3outline
				font.pointSize: Appearance.font.size.small
				horizontalAlignment: Text.AlignHCenter
				pauseMs: 4000
				text: (Players.active?.trackAlbum ?? qsTr("No media")) || qsTr("Unknown album")
				width: parent.width - Appearance.padding.large * 4
			}

			MarqueeText {
				id: artist

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: album.bottom
				anchors.topMargin: Appearance.spacing.small
				color: DynamicColors.palette.m3secondary
				horizontalAlignment: Text.AlignHCenter
				pauseMs: 4000
				text: (Players.active?.trackArtist ?? qsTr("No media")) || qsTr("Unknown artist")
				width: parent.width - Appearance.padding.large * 4
			}

			RowLayout {
				id: controls

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: artist.bottom
				anchors.topMargin: Appearance.spacing.smaller
				spacing: Appearance.spacing.small

				Control {
					function onClicked(): void {
						Players.active?.previous();
					}

					canUse: Players.active?.canGoPrevious ?? false
					icon: "skip_previous"
				}

				Control {
					function onClicked(): void {
						Players.active?.togglePlaying();
					}

					canUse: Players.active?.canTogglePlaying ?? false
					icon: Players.active?.isPlaying ? "pause" : "play_arrow"
				}

				Control {
					function onClicked(): void {
						Players.active?.next();
					}

					canUse: Players.active?.canGoNext ?? false
					icon: "skip_next"
				}
			}
		}
	}

	component Control: CustomRect {
		id: control

		required property bool canUse
		required property string icon
		property int level: 1
		property string set_color: "Secondary"

		function onClicked(): void {
		}

		Layout.preferredWidth: implicitWidth + (controlState.pressed ? Appearance.padding.normal * 2 : 0)
		color: canUse ? DynamicColors.palette[`m3${set_color.toLowerCase()}`] : DynamicColors.palette[`m3${set_color.toLowerCase()}Container`]
		implicitHeight: implicitWidth
		implicitWidth: Math.max(icon.implicitHeight, icon.implicitHeight) + Appearance.padding.small
		radius: Appearance.rounding.full

		Behavior on Layout.preferredWidth {
			Anim {
				duration: Appearance.anim.durations.expressiveFastSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
			}
		}
		Behavior on radius {
			Anim {
				duration: Appearance.anim.durations.expressiveFastSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
			}
		}

		Elevation {
			anchors.fill: parent
			level: controlState.containsMouse && !controlState.pressed ? control.level + 1 : control.level
			radius: parent.radius
			z: -1
		}

		StateLayer {
			id: controlState

			color: control.canUse ? DynamicColors.palette[`m3on${control.set_color}`] : DynamicColors.palette[`m3on${control.set_color}Container`]
			enabled: control.canUse

			onClicked: {
				control.onClicked();
			}
			// radius: Appearance.rounding.full
		}

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			anchors.verticalCenterOffset: font.pointSize * 0.05
			animate: true
			color: control.canUse ? DynamicColors.palette[`m3on${control.set_color}`] : DynamicColors.palette[`m3on${control.set_color}Container`]
			fill: control.canUse ? 1 : 0
			font.pointSize: Appearance.font.size.large
			text: control.icon
		}
	}
}
