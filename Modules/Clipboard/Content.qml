pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	readonly property int itemHeight: Config.clipboard.sizes.itemHeight
	required property ShellScreen screen
	required property PersistentProperties visibilities

	implicitHeight: search.implicitHeight + entries.anchors.topMargin + ((view.spacing + itemHeight) * Config.clipboard.maxEntriesShown) - view.spacing
	implicitWidth: Config.clipboard.sizes.width + preview.width + preview.anchors.leftMargin

	Component.onCompleted: {
		if (ClipHistory.entries.length === 0)
			ClipHistory.refresh();
		searchField.forceActiveFocus();
	}

	CustomClippingRect {
		id: search

		anchors.left: parent.left
		anchors.right: entries.right
		anchors.top: parent.top
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 50
		radius: Appearance.rounding.full

		MaterialIcon {
			id: searchIcon

			anchors.left: parent.left
			anchors.margins: Appearance.padding.large
			anchors.verticalCenter: parent.verticalCenter
			text: "search"
		}

		CustomTextField {
			id: searchField

			anchors.bottom: parent.bottom
			anchors.left: searchIcon.right
			anchors.leftMargin: Appearance.spacing.small
			anchors.right: parent.right
			anchors.top: parent.top
			color: DynamicColors.palette.m3onSurface
			placeholderText: "Search clipboard history..."

			Keys.onDownPressed: view.incrementCurrentIndex()
			Keys.onUpPressed: view.decrementCurrentIndex()
			onAccepted: {
				ClipHistory.copy(view.currentItem.modelData);
				root.visibilities.clipboard = false;
			}
		}
	}

	CustomClippingRect {
		id: preview

		anchors.bottom: parent.bottom
		anchors.left: entries.right
		anchors.leftMargin: Appearance.spacing.normal
		anchors.top: parent.top
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitWidth: ClipHistory.previewIsImage ? Math.max(Math.min(imagePreview.sourceSize.width + imagePreview.anchors.margins * 2, Config.clipboard.sizes.previewWidth), Config.clipboard.sizes.minPreviewWidth) : Math.max(Math.min(textPreview.paintedWidth + textPreview.anchors.margins * 2, Config.clipboard.sizes.previewWidth), Config.clipboard.sizes.minPreviewWidth)
		radius: 25

		Behavior on implicitWidth {
			Anim {
			}
		}

		CustomText {
			id: textPreview

			anchors.left: parent.left
			anchors.margins: Appearance.padding.large
			anchors.top: parent.top
			font.family: ClipHistory.previewIsCode ? Appearance.font.family.mono : Appearance.font.family.sans
			text: ClipHistory.previewMarkup
			textFormat: ClipHistory.previewIsCode ? Text.RichText : Text.PlainText
			visible: !ClipHistory.previewIsImage
			width: Config.clipboard.sizes.previewWidth - anchors.margins * 2
			wrapMode: Text.Wrap
		}

		Image {
			id: imagePreview

			anchors.fill: parent
			anchors.margins: Appearance.padding.large
			asynchronous: true
			cache: false
			fillMode: Image.PreserveAspectFit
			mipmap: true
			retainWhileLoading: true
			smooth: true
			source: ClipHistory.previewImageSource
			visible: ClipHistory.previewIsImage && ClipHistory.previewImageSource !== ""
		}
	}

	Item {
		id: entries

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.top: search.bottom
		anchors.topMargin: Appearance.spacing.normal
		implicitWidth: Config.clipboard.sizes.width

		CustomListView {
			id: view

			anchors.fill: parent
			cacheBuffer: (root.itemHeight + spacing) * 2
			highlightFollowsCurrentItem: false
			highlightRangeMode: ListView.ApplyRange
			preferredHighlightBegin: 0
			preferredHighlightEnd: height
			spacing: Appearance.spacing.normal

			CustomScrollBar.vertical: CustomScrollBar {
				flickable: view
				minimumSize: 0.1
			}
			delegate: RowLayout {
				id: clipItem

				readonly property bool isImage: ClipHistory.entryIsImage(modelData)
				required property string modelData

				height: root.itemHeight
				spacing: Appearance.spacing.small
				width: view.width

				CustomClippingRect {
					id: textRect

					Layout.fillHeight: true
					Layout.fillWidth: true
					radius: textLayer.pressed ? (Appearance.rounding.small / 2) : Appearance.rounding.small

					Behavior on Layout.preferredWidth {
						Anim {
							type: Anim.FastEffects
						}
					}
					Behavior on radius {
						Anim {
							type: Anim.FastEffects
						}
					}

					Item {
						id: textWrapper

						anchors.fill: parent
						layer.enabled: true

						layer.effect: OpacityMask {
							maskSource: fadeMask
						}

						MaterialIcon {
							id: icon

							anchors.left: parent.left
							anchors.margins: Appearance.padding.normal
							anchors.verticalCenter: parent.verticalCenter
							font.pointSize: Appearance.font.size.large
							text: clipItem.isImage ? "image" : "text_fields"
						}

						CustomText {
							id: text

							anchors.left: icon.right
							anchors.margins: Appearance.spacing.normal
							anchors.verticalCenter: parent.verticalCenter
							elide: Text.ElideRight
							text: clipItem.isImage ? qsTr("Image") : ClipHistory.displayText(clipItem.modelData)
						}
					}

					CustomRect {
						id: fadeMask

						anchors.fill: parent
						layer.enabled: true
						visible: false

						gradient: Gradient {
							orientation: Gradient.Horizontal

							GradientStop {
								color: Qt.rgba(1, 1, 1, 1.0)
								position: 0.85
							}

							GradientStop {
								color: Qt.rgba(1, 1, 1, 0)
								position: 1.0
							}
						}
					}

					StateLayer {
						id: textLayer

						onClicked: ClipHistory.copy(clipItem.modelData)
					}
				}

				IconButton {
					Layout.bottomMargin: Appearance.padding.normal
					Layout.fillHeight: true
					Layout.preferredWidth: height
					Layout.topMargin: Appearance.padding.normal
					icon: "content_copy"
					isToggle: false
				}

				IconButton {
					Layout.fillHeight: true
					Layout.margins: Appearance.padding.normal
					Layout.preferredWidth: height
					icon: "delete"
					inactiveColor: Qt.alpha(DynamicColors.palette.m3error, 0.8)
					inactiveOnColor: DynamicColors.palette.m3onError
					isToggle: false
				}
			}
			highlight: CustomRect {
				color: DynamicColors.palette.m3onSurface
				implicitHeight: view.currentItem?.height ?? 0
				implicitWidth: view.width
				opacity: 0.08
				radius: Appearance.rounding.small
				y: view.currentItem?.y ?? 0

				Behavior on y {
					Anim {
						duration: Appearance.anim.durations.small
						easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					}
				}
			}
			model: ScriptModel {
				values: ClipHistory.fuzzyQuery(searchField.text)
			}

			onCurrentItemChanged: {
				if (!currentItem)
					return;

				ClipHistory.currentEntry = currentItem.modelData;
				ClipHistory.refreshPreview();
			}

			CustomClippingWrapperRect {
				anchors.fill: parent
				child: view.contentItem
				radius: Appearance.rounding.small
			}
		}
	}
}
