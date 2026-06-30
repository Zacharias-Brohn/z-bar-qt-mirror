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

		SearchBar {
			id: searchField

			anchors.bottom: parent.bottom
			anchors.left: parent.left
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
		implicitWidth: ClipHistory.previewIsImage ? Math.max(Math.min(imagePreview.sourceSize.width + Appearance.padding.large * 2, Config.clipboard.sizes.previewWidth), Config.clipboard.sizes.minPreviewWidth) : Math.max(Math.min(textPreviewColumn.width + textPreviewColumn.anchors.margins * 2, Config.clipboard.sizes.previewWidth), Config.clipboard.sizes.minPreviewWidth)
		radius: 25

		Behavior on implicitWidth {
			Anim {
			}
		}

		Column {
			id: textPreviewColumn

			anchors.left: parent.left
			anchors.leftMargin: 0
			anchors.margins: Appearance.padding.normal
			anchors.top: parent.top
			visible: !ClipHistory.previewIsImage

			Repeater {
				id: processedLines

				model: ClipHistory.previewText

				Row {
					id: lineRow

					required property int index
					required property var modelData

					spacing: Appearance.spacing.normal

					CustomRect {
						color: lineRow.index % 2 ? DynamicColors.tPalette.m3surfaceContainer : "transparent"
						implicitHeight: lineText.paintedHeight + Appearance.padding.extraSmall * 2
						implicitWidth: 50

						CustomText {
							id: number

							anchors.margins: Appearance.padding.large
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							color: DynamicColors.palette.m3onSurfaceVariant
							font.pointSize: Appearance.font.size.small
							text: lineRow.modelData.line
						}
					}

					Repeater {
						model: lineRow.modelData.text.split("\t").slice(1)

						RowLayout {
							height: lineText.height
							width: lineText.height + Appearance.spacing.extraSmall

							Item {
								Layout.fillHeight: true
								Layout.fillWidth: true

								CustomRect {
									anchors.centerIn: parent
									color: DynamicColors.tPalette.m3surfaceContainer
									implicitHeight: parent.height / 8
									implicitWidth: parent.height / 8
									radius: Appearance.rounding.full
								}
							}

							Item {
								Layout.fillHeight: true
								Layout.fillWidth: true

								CustomRect {
									anchors.centerIn: parent
									color: DynamicColors.tPalette.m3surfaceContainer
									implicitHeight: parent.height / 8
									implicitWidth: parent.height / 8
									radius: Appearance.rounding.full
								}
							}

							Item {
								Layout.fillHeight: true
								Layout.fillWidth: true

								CustomRect {
									anchors.centerIn: parent
									color: DynamicColors.tPalette.m3surfaceContainer
									implicitHeight: parent.height / 8
									implicitWidth: parent.height / 8
									radius: Appearance.rounding.full
								}
							}
						}
					}

					CustomText {
						id: lineText

						color: DynamicColors.palette.m3onSurface
						height: lineText.paintedHeight + Appearance.padding.extraSmall * 2
						text: lineRow.modelData.text.trim()
						verticalAlignment: Text.AlignVCenter
						wrapMode: Text.Wrap
					}
				}
			}
		}

		Image {
			id: imagePreview

			anchors.centerIn: parent
			asynchronous: true
			cache: false
			fillMode: Image.PreserveAspectFit
			mipmap: true
			retainWhileLoading: true
			smooth: true
			source: ClipHistory.previewImageSource
			visible: ClipHistory.previewIsImage && ClipHistory.previewImageSource !== ""
			width: Math.min(sourceSize.width, Config.clipboard.sizes.previewWidth)
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
			delegate: CustomRect {
				id: clipItem

				readonly property bool isImage: ClipHistory.entryIsImage(modelData)
				required property string modelData

				implicitHeight: root.itemHeight
				implicitWidth: view.width
				radius: textLayer.pressed ? (Appearance.rounding.small / 2) : Appearance.rounding.small

				Behavior on radius {
					Anim {
						type: Anim.FastEffects
					}
				}

				RowLayout {
					anchors.fill: parent
					spacing: Appearance.spacing.small

					CustomClippingRect {
						id: textRect

						Layout.fillHeight: true
						Layout.fillWidth: true

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
					}

					IconButton {
						Layout.fillHeight: true
						Layout.margins: Appearance.padding.normal
						Layout.preferredWidth: height
						icon: "delete"
						inactiveColor: Qt.alpha(DynamicColors.palette.m3error, 0.8)
						inactiveOnColor: DynamicColors.palette.m3onError
						isToggle: false

						onClicked: ClipHistory.deleteEntry(clipItem.modelData)
					}
				}

				StateLayer {
					id: textLayer

					onClicked: ClipHistory.copy(clipItem.modelData)
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

				onValuesChanged: view.currentIndex = 0
			}

			onCurrentItemChanged: {
				if (!currentItem)
					return;

				ClipHistory.currentEntry = currentItem.modelData;
				ClipHistory.refreshPreview();
			}
			onVisibleChanged: currentIndex = 0

			CustomClippingWrapperRect {
				anchors.fill: parent
				child: view.contentItem
				radius: Appearance.rounding.small
			}
		}
	}
}
