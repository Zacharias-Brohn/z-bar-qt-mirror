pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import ZShell
import qs.Config

Singleton {
	id: root

	property alias enabled: props.enabled

	function setHyprConf(): void {
		Hypr.extras.applyOptions({
			"animations.enabled": 0,
			"decoration.shadow.enabled": 0,
			"decoration.blur.enabled": 0,
			"general.border_size": 0,
			"decoration.rounding": 0
		});
	}

	onEnabledChanged: {
		if (enabled) {
			setHyprConf();
			if (Config.utilities.toasts.gameModeChanged)
				Toaster.toast(qsTr("Game mode enabled"), qsTr("Disabled Hyprland animations, blur, shadows and corner radius"), "gamepad");
		} else {
			Hypr.extras.message("reload");
			if (Config.utilities.toasts.gameModeChanged)
				Toaster.toast(qsTr("Game mode disabled"), qsTr("Hyprland settings restored"), "gamepad");
		}
	}

	PersistentProperties {
		id: props

		property bool enabled: Hypr.options["animations:enabled"] === 0

		reloadableId: "gamemode"
	}

	Connections {
		function onConfigReloaded(): void {
			if (props.enabled)
				root.setHyprConf();
		}

		target: Hypr
	}

	IpcHandler {
		function disable(): void {
			props.enabled = false;
		}

		function enable(): void {
			props.enabled = true;
		}

		function isEnabled(): bool {
			return props.enabled;
		}

		function toggle(): void {
			props.enabled = !props.enabled;
		}

		target: "gameMode"
	}
}
