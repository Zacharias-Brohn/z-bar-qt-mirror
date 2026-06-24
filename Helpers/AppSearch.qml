pragma Singleton

import Quickshell
import qs.Helpers
import "../scripts/fuzzysort.js" as Fuzzy

Singleton {
	id: root

	readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values)
	readonly property var preppedNames: list.map(a => ({
				name: Fuzzy.prepare(`${a.name} `),
				entry: a
			}))
	property var regexSubstitutions: [
		{
			"regex": /^steam_app_(\d+)$/,
			"replace": "steam_icon_$1"
		},
		{
			"regex": /Minecraft.*/,
			"replace": "minecraft"
		},
		{
			"regex": /.*polkit.*/,
			"replace": "system-lock-screen"
		},
		{
			"regex": /gcr.prompter/,
			"replace": "system-lock-screen"
		}
	]
	property real scoreThreshold: 0.2
	property var substitutions: ({
			"code-url-handler": "visual-studio-code",
			"Code": "visual-studio-code",
			"gnome-tweaks": "org.gnome.tweaks",
			"pavucontrol-qt": "pavucontrol",
			"wps": "wps-office2019-kprometheus",
			"wpsoffice": "wps-office2019-kprometheus",
			"footclient": "foot",
			"zen": "zen-browser"
		})

	signal reload

	function fuzzyQuery(search: string): var {
		return Fuzzy.go(search, preppedNames, {
			all: true,
			key: "name"
		}).map(r => {
			return r.obj.entry;
		});
	}

	function guessIcon(str) {
		if (!str || str.length == 0)
			return "image-missing";

		if (substitutions[str])
			return substitutions[str];

		for (let i = 0; i < regexSubstitutions.length; i++) {
			const substitution = regexSubstitutions[i];
			const replacedName = str.replace(substitution.regex, substitution.replace);
			if (replacedName != str)
				return replacedName;
		}

		if (iconExists(str))
			return str;

		let guessStr = str;
		guessStr = str.split('.').slice(-1)[0].toLowerCase();
		if (iconExists(guessStr))
			return guessStr;
		guessStr = str.toLowerCase().replace(/\s+/g, "-");
		if (iconExists(guessStr))
			return guessStr;
		const searchResults = root.fuzzyQuery(str);
		if (searchResults.length > 0) {
			const firstEntry = searchResults[0];
			guessStr = firstEntry.icon;
			if (iconExists(guessStr))
				return guessStr;
		}

		return str;
	}

	function iconExists(iconName) {
		if (!iconName || iconName.length == 0)
			return false;
		return (Quickshell.iconPath(iconName, true).length > 0) && !iconName.includes("image-missing");
	}
}
