import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property int animOff
	property Item currentItem
	property int lastPageIdx
	required property SettingsState sState

	function loadPage(idx: int): void {
		if (currentItem)
			currentItem.destroy();

		const comp = PageCompRegistry.pageComps[idx] ?? PageCompRegistry.placeholderComp;
		const incubator = comp.incubateObject(container, {
			sState
		});

		const attach = () => {
			incubator.object.anchors.fill = container;
			currentItem = incubator.object;
		};

		if (incubator.status === Component.Ready)
			attach();
		else
			incubator.onStatusChanged = status => {
				if (status === Component.Ready)
					attach();
			};
	}

	Item {
		id: container

		anchors.fill: parent
		layer.enabled: opacity < 1
		objectName: "PageContainer"

		Component.onCompleted: root.loadPage(root.sState.currentPageIdx)
	}

	Connections {
		function onCurrentPageIdxChanged(): void {
			switchAnim.complete();
			root.animOff = Appearance.padding.normal * (root.sState.currentPageIdx > root.lastPageIdx ? 1 : -1);
			switchAnim.start();
			root.lastPageIdx = root.sState.currentPageIdx;
		}

		target: root.sState
	}

	SequentialAnimation {
		id: switchAnim

		Anim {
			property: "opacity"
			target: container
			to: 0
			type: Anim.DefaultEffects
		}

		ScriptAction {
			script: root.loadPage(root.sState.currentPageIdx)
		}

		PropertyAction {
			property: "topMargin"
			target: container.anchors
			value: root.animOff
		}

		PropertyAction {
			property: "bottomMargin"
			target: container.anchors
			value: -root.animOff
		}

		ParallelAnimation {
			Anim {
				from: 0
				property: "opacity"
				target: container
				to: 1
				type: Anim.SlowEffects
			}

			Anim {
				properties: "topMargin,bottomMargin"
				target: container.anchors
				to: 0
				type: Anim.SlowEffects
			}
		}
	}
}
