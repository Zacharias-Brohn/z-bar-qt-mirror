import os
import json
import subprocess
import time
from pathlib import Path
from typing import Optional

import typer

app = typer.Typer()

RECORDER = "gpu-screen-recorder"
HOME = str(os.getenv("HOME", str(Path.home())))
CONFIG = Path(HOME) / ".config/zshell/config.json"

STATE_DIR = Path(HOME) / ".local/state/zshell/record"
TEMP_RECORDING = STATE_DIR / "recording.mp4"
REPLAY_RECORDING = STATE_DIR / "replay.mp4"
NOTIF_ID_FILE = STATE_DIR / "notifid.txt"

RECORDINGS_DIR = os.getenv("ZSHELL_RECORDINGS_DIR",
                           str(Path(HOME) / "Videos/Recordings"))


def _read_extra_args() -> list[str]:
    try:
        if CONFIG.is_file():
            data = json.loads(CONFIG.read_text())
            return data.get("record", {}).get("extraArgs", [])
    except Exception:
        pass
    return []


def _is_recording() -> bool:
    return subprocess.run(["pidof", RECORDER], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0


def _notify(summary: str, body: str = "", actions: list = None, timeout: int = 5000) -> Optional[int]:
    args = ["notify-send", summary, body, "-t", str(timeout), "-p"]
    if actions:
        for action in actions:
            args.extend(["-A", action])
    try:
        proc = subprocess.run(args, capture_output=True, text=True)
        return int(proc.stdout.strip()) if proc.stdout.strip().isdigit() else None
    except Exception:
        return None


def _close_notification(notif_id: int):
    subprocess.run(["notify-send", "--close", str(notif_id)],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def _get_monitors() -> list[dict]:
    try:
        res = subprocess.run(["hyprctl", "monitors", "-j"],
                             capture_output=True, text=True)
        return json.loads(res.stdout)
    except Exception:
        return []


def _focused_monitor_name() -> Optional[str]:
    for m in _get_monitors():
        if m.get("focused"):
            return m["name"]
    return None


def _monitors_intersecting_region(x: int, y: int, w: int, h: int) -> list[dict]:
    region = (x, y, x + w, y + h)
    intersecting = []
    for m in _get_monitors():
        mx, my, mw, mh = m["x"], m["y"], m["width"], m["height"]
        if not (region[2] <= mx or region[0] >= mx + mw or region[3] <= my or region[1] >= my + mh):
            intersecting.append(m)
    return intersecting


def _highest_refresh(monitors: list[dict]) -> float:
    return max((m["refreshRate"] for m in monitors), default=60.0)


def _slurp_region() -> Optional[str]:
    try:
        return subprocess.check_output(["slurp", "-f", "%wx%h+%x+%y"], text=True).strip()
    except subprocess.CalledProcessError:
        return None


def _parse_geometry(geometry: str) -> Optional[tuple[int, int, int, int]]:
    import re
    match = re.match(r"(\d+)x(\d+)\+(\d+)\+(\d+)", geometry)
    if match:
        return int(match.group(3)), int(match.group(4)), int(match.group(1)), int(match.group(2))
    return None


def start_recording(region: Optional[str], sound: bool):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    cmd = [RECORDER]
    extra_args = _read_extra_args()

    if region:
        if region.lower() == "slurp" or not region:
            geometry = _slurp_region()
            if not geometry:
                typer.echo("Region selection cancelled.")
                raise typer.Abort()
        else:
            geometry = region

        parsed = _parse_geometry(geometry)
        if not parsed:
            typer.echo("Invalid geometry format.")
            raise typer.Abort()
        x, y, w, h = parsed

        monitors = _monitors_intersecting_region(x, y, w, h)
        framerate = _highest_refresh(monitors)
        cmd.extend(["-w", "region", "-region", geometry, "-f", str(int(framerate))])

    else:
        monitor_name = _focused_monitor_name()
        if not monitor_name:
            typer.echo("No focused monitor found.")
            raise typer.Abort()

        monitors = _get_monitors()
        mon = next((m for m in monitors if m["name"] == monitor_name), None)
        rate = int(mon["refreshRate"]) if mon else 60
        cmd.extend(["-w", monitor_name, "-f", str(rate)])

    if sound:
        cmd.extend(["-a", "default_output"])

    cmd.extend(extra_args)
    cmd.extend(["-o", str(TEMP_RECORDING)])

    subprocess.Popen(cmd, start_new_session=True,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    notif_id = _notify("Recording started", f"Saving to {TEMP_RECORDING}")
    if notif_id is not None:
        NOTIF_ID_FILE.write_text(str(notif_id))

    time.sleep(1)
    if not _is_recording():
        _notify("Recording failed",
                "Check gpu-screen-recorder output.", timeout=5000)
        raise typer.Exit(code=1)


def stop_recording(clipboard: bool):
    subprocess.run(["pkill", "-f", RECORDER],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    for _ in range(50):
        if not _is_recording():
            break
        time.sleep(0.1)

    dest_dir = Path(RECORDINGS_DIR)
    dest_dir.mkdir(parents=True, exist_ok=True)
    timestamp = time.strftime("%Y-%m-%d_%H-%M-%S")
    final_path = dest_dir / f"recording_{timestamp}.mp4"

    if TEMP_RECORDING.exists():
        TEMP_RECORDING.rename(final_path)

    if NOTIF_ID_FILE.is_file():
        try:
            _close_notification(int(NOTIF_ID_FILE.read_text().strip()))
        except Exception:
            pass
        NOTIF_ID_FILE.unlink()

    if clipboard:
        subprocess.run(["wl-copy", "--type", "text/uri-list", f"file://{final_path}"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    _notify("Recording stopped", f"Saved to {final_path}", timeout=5000)


def toggle_pause():
    subprocess.run(["pkill", "-USR2", "-f", RECORDER],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    typer.echo("Toggled pause.")


@app.command()
def record(
    region: Optional[str] = typer.Option(
        None, "--region", "-r",
        help="Record a region. Use 'slurp' (or omit value) to select interactively, or give 'WxH+X+Y'.",
    ),
    sound: bool = typer.Option(
        False, "--sound", "-s", help="Record audio from default output."),
    pause: bool = typer.Option(
        False, "--pause", "-p", help="Toggle pause/resume."),
    clipboard: bool = typer.Option(
        False, "--clipboard", "-c", help="Copy the final recording path to clipboard."),
):
    """Start or stop a screen recording with gpu-screen-recorder."""
    if pause:
        toggle_pause()
        raise typer.Exit()

    if _is_recording():
        stop_recording(clipboard)
    else:
        start_recording(region, sound)
