// FetchPresets.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property var parsedPresets: ({})
	readonly property var presets: parsedPresets
	property bool ready: false

	function accents(presetName, variantName) {
		const variant = parsedPresets[presetName]?.variants?.[variantName];

		return variant?.accents ?? [];
	}

	function defaultAccent(presetName, variantName) {
		const variant = parsedPresets[presetName]?.variants?.[variantName];

		return variant?.default_accent ?? "";
	}

	function modes(presetName, variantName) {
		const variant = parsedPresets[presetName]?.variants?.[variantName];

		return variant?.modes ?? [];
	}

	function presetNames() {
		return Object.keys(parsedPresets);
	}

	function variantNames(presetName) {
		const preset = parsedPresets[presetName];

		if (!preset || !preset.variants)
			return [];

		return Object.keys(preset.variants);
	}

	Process {
		command: ["zshell-cli", "scheme", "list-presets", "--json"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				try {
					const parsed = JSON.parse(text);

					root.parsedPresets = parsed.presets ?? {};
					root.ready = true;
				} catch (e) {
					console.error("Failed to parse presets JSON:", e);
				}
			}
		}
	}
}
