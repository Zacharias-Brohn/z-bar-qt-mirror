pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Paths

Singleton {
	id: root

	property string boardName
	property string boardVendor
	readonly property string device: {
		if (!boardName)
			return boardVendor;
		if (!boardVendor || boardName.toLowerCase().startsWith(boardVendor.toLowerCase()))
			return boardName;
		return `${boardVendor} ${boardName}`;
	}
	property string firmware
	property string hostname
	property bool isDefaultLogo: true
	property string kernel
	property string osId
	property list<string> osIdLike
	property string osLogo: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/logo.svg`)
	property string osName
	property string osPrettyName
	readonly property string shell: Quickshell.env("SHELL").split("/").pop()
	property string uptime
	readonly property string user: Quickshell.env("USER")
	readonly property string wm: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP")

	function sanitiseDmi(s: string): string {
		const t = s.trim();
		const junk = ["to be filled by o.e.m.", "system product name", "system manufacturer", "system version", "default string", "o.e.m.", "not specified", "not applicable", "unknown", "none", ""];
		return junk.includes(t.toLowerCase()) ? "" : t;
	}

	FileView {
		id: osRelease

		path: "/etc/os-release"

		onLoaded: {
			const lines = text().split("\n");

			const fd = key => lines.find(l => l.startsWith(`${key}=`))?.split("=")[1].replace(/"/g, "") ?? "";

			root.osName = fd("NAME");
			root.osPrettyName = fd("PRETTY_NAME");
			root.osId = fd("ID");
			root.osIdLike = fd("ID_LIKE").split(" ");

			const logo = Quickshell.iconPath(fd("LOGO"), true);
			if (Config.general.logo === "zshell") {
				root.osLogo = Qt.resolvedUrl(`${Quickshell.shellDir}/assets/logo.svg`);
				root.isDefaultLogo = true;
			} else if (Config.general.logo) {
				root.osLogo = Quickshell.iconPath(Config.general.logo, true) || "file://" + Paths.absolutePath(Config.general.logo);
				root.isDefaultLogo = false;
			} else if (logo) {
				root.osLogo = logo;
				root.isDefaultLogo = false;
			}
		}
	}

	Connections {
		function onLogoChanged(): void {
			osRelease.reload();
		}

		target: Config.general
	}

	FileView {
		path: "/proc/sys/kernel/osrelease"

		onLoaded: root.kernel = text().trim()
	}

	FileView {
		path: "/proc/sys/kernel/hostname"

		onLoaded: root.hostname = text().trim()
	}

	FileView {
		path: "/sys/class/dmi/id/sys_vendor"
		printErrors: false

		onLoaded: root.boardVendor = root.sanitiseDmi(text())
	}

	FileView {
		path: "/sys/class/dmi/id/product_name"
		printErrors: false

		onLoaded: root.boardName = root.sanitiseDmi(text())
	}

	FileView {
		path: "/sys/class/dmi/id/bios_version"
		printErrors: false

		onLoaded: root.firmware = root.sanitiseDmi(text())
	}

	Timer {
		interval: 15000
		repeat: true
		running: true

		onTriggered: fileUptime.reload()
	}

	FileView {
		id: fileUptime

		path: "/proc/uptime"

		onLoaded: {
			const up = parseInt(text().split(" ")[0] ?? 0);

			const days = Math.floor(up / 86400);
			const hours = Math.floor((up % 86400) / 3600);
			const minutes = Math.floor((up % 3600) / 60);

			let str = "";
			if (days > 0)
				str += `${days} day${days === 1 ? "" : "s"}`;
			if (hours > 0)
				str += `${str ? ", " : ""}${hours} hour${hours === 1 ? "" : "s"}`;
			if (minutes > 0 || !str)
				str += `${str ? ", " : ""}${minutes} minute${minutes === 1 ? "" : "s"}`;
			root.uptime = str;
		}
	}
}
