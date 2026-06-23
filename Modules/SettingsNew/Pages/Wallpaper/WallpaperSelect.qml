pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ZShell.Models
import qs.Paths
import qs.Helpers
import qs.Components
import qs.Config
import qs.Modules.SettingsNew.Common

PageBase {
	id: root

	isSubPage: true
	title: qsTr("Wallpapers")

	ColumnLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: Appearance.spacing.small
		width: root.cappedWidth

		CustomText {
			Layout.topMargin: Appearance.spacing.large
			font.pointSize: Appearance.font.size.large
			text: qsTr("Wallpapers")
		}

		GridLayout {
			Layout.fillWidth: true
			columnSpacing: Appearance.spacing.extraSmall
			columns: 4
			rowSpacing: Appearance.spacing.extraSmall
			visible: localWalls.count > 0

			Repeater {
				id: localWalls

				model: {
					const walls = Wallpapers.list;
					var baseDir = Paths.wallsdir;
					const categories = {};
					const list = [];
					for (const w of walls) {
						var parentDir = w.parentDir;
						if (!parentDir.endsWith("/"))
							parentDir = parentDir + "/";

						if (!baseDir.endsWith("/"))
							baseDir = baseDir + "/";

						if (parentDir !== baseDir) {
							const category = Wallpapers.getCategoryFor(w);
							if (category && (!(category in categories) || categories[category].name.localeCompare(w.name) > 0))
								categories[category] = w;
						} else {
							list.push(w);
						}
					}
					list.push(...Object.values(categories));
					list.sort((a, b) => ((a.parentDir === baseDir) - (b.parentDir === baseDir)) || a.name.localeCompare(b.name));
					while (list.length < 4)
						list.push(null);

					return list;
				}

				WallItem {
					required property FileSystemEntry modelData

					enabled: modelData

					// Empty placeholders for sizing
					opacity: modelData ? 1 : 0
					source: String(modelData?.path ?? "")

					onClicked: {
						Wallpapers.setWallpaper(modelData.path);
						root.sState.closeSubPage();
					}
				}
			}
		}

		Loader {
			Layout.fillWidth: true
			active: localWalls.count === 0
			asynchronous: true
			visible: active

			sourceComponent: CustomRect {
				color: DynamicColors.tPalette.m3surfaceContainer
				implicitHeight: noWallsLayout.implicitHeight + Appearance.padding.extraLarge * 3
				radius: Appearance.rounding.large

				ColumnLayout {
					id: noWallsLayout

					anchors.centerIn: parent
					spacing: Appearance.spacing.extraSmall

					MaterialIcon {
						Layout.alignment: Qt.AlignHCenter
						color: DynamicColors.palette.m3outline
						text: "hide_image"
					}

					CustomText {
						Layout.alignment: Qt.AlignHCenter
						color: DynamicColors.palette.m3outline
						text: qsTr("No local wallpapers found")
					}
				}
			}
		}
	}
}
