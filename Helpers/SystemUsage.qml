pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.Config

Singleton {
	id: root

	property string autoGpuType: "NONE"
	property real gpuMemTotal: 0
	property real gpuMemUsed
	property string gpuName
	property real gpuPerc
	property real gpuTemp
	readonly property string gpuType: Config.services.gpuType.toUpperCase() || autoGpuType
	property int refCount

	function cleanCpuName(name: string): string {
		return name.replace(/\(R\)/gi, "").replace(/\(TM\)/gi, "").replace(/CPU/gi, "").replace(/\d+th Gen /gi, "").replace(/\d+nd Gen /gi, "").replace(/\d+rd Gen /gi, "").replace(/\d+st Gen /gi, "").replace(/Core /gi, "").replace(/Processor/gi, "").replace(/\s+/g, " ").trim();
	}

	function cleanGpuName(name: string): string {
		return name.replace(/NVIDIA GeForce /gi, "").replace(/NVIDIA /gi, "").replace(/AMD Radeon /gi, "").replace(/AMD /gi, "").replace(/Intel /gi, "").replace(/\(R\)/gi, "").replace(/\(TM\)/gi, "").replace(/Graphics/gi, "").replace(/\s+/g, " ").trim();
	}

	function formatKib(kib: real): var {
		const mib = 1024;
		const gib = 1024 ** 2;
		const tib = 1024 ** 3;

		if (kib >= tib)
			return {
				value: kib / tib,
				unit: "TiB"
			};
		if (kib >= gib)
			return {
				value: kib / gib,
				unit: "GiB"
			};
		if (kib >= mib)
			return {
				value: kib / mib,
				unit: "MiB"
			};
		return {
			value: kib,
			unit: "KiB"
		};
	}

	Timer {
		interval: Config.dashboard.resourceUpdateInterval
		repeat: true
		running: root.refCount > 0
		triggeredOnStart: true

		onTriggered: {
			if (root.gpuType === "GENERIC")
				gpuUsage.running = true;

			if (root.gpuType === "GENERIC" && root.gpuMemTotal === 0)
				oneshotMemAmd.running = true;
		}
	}

	Process {
		id: gpuNameDetect

		command: ["sh", "-c", "nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || lspci 2>/dev/null | grep -i 'vga\\|3d\\|display' | head -1"]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				const output = text.trim();
				if (!output)
					return;

				// Check if it's from nvidia-smi (clean GPU name)
				if (output.toLowerCase().includes("nvidia") || output.toLowerCase().includes("geforce") || output.toLowerCase().includes("rtx") || output.toLowerCase().includes("gtx")) {
					root.gpuName = root.cleanGpuName(output);
				} else {
					// Parse lspci output: extract name from brackets or after colon
					const bracketMatch = output.match(/\[([^\]]+)\]/);
					if (bracketMatch) {
						root.gpuName = root.cleanGpuName(bracketMatch[1]);
					} else {
						const colonMatch = output.match(/:\s*(.+)/);
						if (colonMatch)
							root.gpuName = root.cleanGpuName(colonMatch[1]);
					}
				}
			}
		}
	}

	Process {
		id: gpuTypeCheck

		command: ["sh", "-c", "if command -v nvidia-smi &>/dev/null && nvidia-smi -L &>/dev/null; then echo NVIDIA; elif ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | grep -q .; then echo GENERIC; else echo NONE; fi"]
		running: !Config.services.gpuType

		stdout: StdioCollector {
			onStreamFinished: root.autoGpuType = text.trim()
		}
	}

	Process {
		id: oneshotMem

		command: ["nvidia-smi", "--query-gpu=memory.total", "--format=csv,noheader,nounits"]
		running: root.gpuType === "NVIDIA" && root.gpuMemTotal === 0

		stdout: StdioCollector {
			onStreamFinished: {
				root.gpuMemTotal = Number(this.text.trim());
				oneshotMem.running = false;
			}
		}
	}

	Process {
		id: oneshotMemAmd

		command: ["sh", "-c", "cat /sys/class/drm/card*/device/mem_info_vram_total"]
		running: root.gpuType === "GENERIC" && root.gpuMemTotal === 0

		stdout: StdioCollector {
			onStreamFinished: {
				const values = text.trim().split("\n").map(v => parseInt(v, 10)).filter(v => Number.isFinite(v));

				if (values.length > 0) {
					const totalBytes = values.reduce((a, b) => a + b, 0);
					root.gpuMemTotal = totalBytes / (1024 * 1024);
				}

				oneshotMemAmd.running = false;
			}
		}
	}

	Process {
		id: gpuUsageNvidia

		command: ["/usr/bin/nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,memory.used", "--format=csv,noheader,nounits", "-lms", "1000"]
		running: root.refCount > 0 && root.gpuType === "NVIDIA"

		stdout: SplitParser {
			onRead: data => {
				const parts = String(data).trim().split(/\s*,\s*/);
				if (parts.length < 3)
					return;

				const usageRaw = parseInt(parts[0], 10);
				const tempRaw = parseInt(parts[1], 10);
				const memRaw = parseInt(parts[2], 10);

				if (!Number.isFinite(usageRaw) || !Number.isFinite(tempRaw) || !Number.isFinite(memRaw))
					return;

				const newGpuPerc = Math.max(0, Math.min(1, usageRaw / 100));
				const newGpuTemp = tempRaw;
				const newGpuMemUsed = root.gpuMemTotal > 0 ? Math.max(0, Math.min(1, memRaw / root.gpuMemTotal)) : 0;

				// Only publish meaningful changes to avoid needless binding churn / repaints
				if (Math.abs(root.gpuPerc - newGpuPerc) >= 0.01)
					root.gpuPerc = newGpuPerc;

				if (Math.abs(root.gpuTemp - newGpuTemp) >= 1)
					root.gpuTemp = newGpuTemp;

				if (Math.abs(root.gpuMemUsed - newGpuMemUsed) >= 0.01)
					root.gpuMemUsed = newGpuMemUsed;
			}
		}
	}

	Process {
		id: gpuUsage

		command: root.gpuType === "GENERIC" ? ["sh", "-c", "paste -d ' ' /sys/class/drm/card*/device/gpu_busy_percent /sys/class/drm/card*/device/mem_info_vram_used"] : ["echo"]

		stdout: StdioCollector {
			onStreamFinished: {
				if (root.gpuType === "GENERIC") {
					const lines = text.trim().split("\n");

					let percSum = 0;
					let memSum = 0;
					let count = 0;

					for (const line of lines) {
						const parts = line.trim().split(/\s+/);
						if (parts.length < 2)
							continue;

						const gpuBusy = parseInt(parts[0], 10);
						const memUsed = parseInt(parts[1], 10);

						if (!Number.isFinite(gpuBusy) || !Number.isFinite(memUsed))
							continue;

						percSum += gpuBusy;
						memSum += memUsed;
						count++;
					}

					if (count > 0) {
						// GPU usage %
						root.gpuPerc = (percSum / count) / 100;

						// VRAM usage (bytes → MiB → normalized)
						const memUsedMiB = memSum / (1024 * 1024);

						const newGpuMemUsed = root.gpuMemTotal > 0 ? Math.max(0, Math.min(1, memUsedMiB / root.gpuMemTotal)) : 0;

						if (Math.abs(root.gpuMemUsed - newGpuMemUsed) >= 0.01)
							root.gpuMemUsed = newGpuMemUsed;
					}
				} else {
					root.gpuPerc = 0;
					root.gpuTemp = 0;
				}
			}
		}
	}
}
