pragma Singleton

import "../../scripts/fzf.js" as Fzf
import QtQuick
import Quickshell
import ZShell
import qs.Config

Singleton {
	id: root

	property var fzfFinder: null
	property var inverted: ({})
	property var ranking: ({})

	function highlight(text: string, search: string, colour: color): string {
		const escaped = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
		const tokens = tokenize(search);
		if (tokens.length === 0)
			return escaped;
		const escapedTokens = tokens.map(t => t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
		const pattern = new RegExp("\\b(" + escapedTokens.join("|") + ")", "gi");
		return escaped.replace(pattern, `<font color="${colour}">$1</font>`);
	}

	function lookup(token: string): var {
		const result = ({});
		const exact = root.inverted[token] !== undefined;
		const keys = exact ? [token] : Object.keys(root.inverted).filter(k => k.startsWith(token));
		for (const key of keys) {
			const rank = root.ranking[key] ?? ({});
			for (const id of root.inverted[key]) {
				const w = rank[id] ?? 0.1;
				if (result[id] === undefined || w > result[id])
					result[id] = w;
			}
		}

		return result;
	}

	function query(search: string): list<QtObject> {
		const tokens = root.tokenize(search);
		if (tokens.length === 0)
			return [];

		const scores = ({});
		const hitCounts = ({});
		for (const token of tokens) {
			const matches = root.lookup(token);
			for (const id in matches) {
				scores[id] = (scores[id] ?? 0) + matches[id];
				hitCounts[id] = (hitCounts[id] ?? 0) + 1;
			}
		}

		const ranked = Object.keys(scores).filter(id => hitCounts[id] === tokens.length).sort((a, b) => scores[b] - scores[a] || (parseInt(a) - parseInt(b))).slice(0, 25);

		const all = entries.instances;
		const out = ranked.map(id => all[parseInt(id)]).filter(e => e !== undefined);

		if (out.length < 5 && root.fzfFinder) {
			const seen = ({});
			for (const id of ranked)
				seen[id] = true;
			const fuzzy = root.fzfFinder.find(search);
			for (const r of fuzzy) {
				const idx = r.item.idx;
				if (seen[idx])
					continue;
				seen[idx] = true;
				const entry = all[idx];
				if (entry !== undefined)
					out.push(entry);
				if (out.length >= 25)
					break;
			}
		}

		return out;
	}

	function tokenize(text: string): var {
		return text.toLowerCase().split(/[^a-z0-9]+/).filter(t => t.length > 0);
	}

	Component.onCompleted: {
		try {
			const data = JSON.parse(ZUtils.settingsIndex());
			entries.model = data.entries;
			root.inverted = data.inverted ?? {};
			root.ranking = data.ranking ?? {};
			const docs = data.entries.map((e, i) => ({
						idx: i,
						text: e.title
					}));
			root.fzfFinder = new Fzf.Finder(docs, {
				selector: d => d.text,
				limit: 25
			});
		} catch (e) {
			entries.model = [];
			root.inverted = {};
			root.ranking = {};
			root.fzfFinder = null;
		}
	}

	Variants {
		id: entries

		SettingEntry {
		}
	}

	component SettingEntry: QtObject {
		readonly property string anchor: modelData.anchor ?? ""
		readonly property var crumbIcons: modelData.crumbIcons
		readonly property var crumbLabels: modelData.crumbLabels
		readonly property bool isToggle: togglePath.length > 0
		required property var modelData
		readonly property int pageIdx: modelData.pageIdx
		readonly property string section: modelData.section ?? ""
		readonly property var subPath: modelData.subPath
		readonly property string subtext: modelData.subtext ?? ""
		readonly property string title: modelData.title
		readonly property string togglePath: modelData.togglePath ?? ""
		readonly property bool toggleValue: {
			if (!isToggle)
				return false;
			let obj = Config;
			const parts = togglePath.split(".");
			for (const part of parts) {
				if (obj === undefined || obj === null)
					return false;
				obj = obj[part];
			}
			return obj ?? false;
		}

		function setToggle(value: bool): void {
			if (!isToggle)
				return;
			const parts = togglePath.split(".");
			let obj = Config;
			for (let k = 0; k < parts.length - 1; k++) {
				if (obj === undefined || obj === null)
					return;
				obj = obj[parts[k]];
			}
			if (obj !== undefined && obj !== null)
				obj[parts[parts.length - 1]] = value;
		}
	}
}
