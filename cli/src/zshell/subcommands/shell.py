import subprocess
import sys
import time

import typer

args = ["qs", "-c", "zshell"]

app = typer.Typer()


@app.command()
def kill():
    result = subprocess.run(args + ["kill"], capture_output=True)
    if result.returncode != 0:
        sys.stderr.write("No running instance to kill.\n")
        sys.exit(1)
    sys.stderr.write(result.stderr.decode())


def start_instance(no_daemon: bool = False) -> None:
    result = subprocess.run(args + ["-n"] + ([] if no_daemon else ["-d"]), capture_output=True)
    stdout = result.stdout.decode().strip()
    if stdout:
        if "already running" in stdout.lower():
            sys.stderr.write(stdout + "\n")
            sys.exit(1)
    if result.returncode != 0:
        stderr = result.stderr.decode().strip()
        sys.stderr.write(stderr + "\n")
        sys.exit(1)


@app.command()
def start(no_daemon: bool = False):
    start_instance(no_daemon)


@app.command()
def restart(no_daemon: bool = False):
    subprocess.run(args + ["kill"], capture_output=True)
    deadline = time.monotonic() + 2.5
    while time.monotonic() < deadline:
        result = subprocess.run(args + ["kill"], capture_output=True)
        if result.returncode == 255:
            break
        time.sleep(0.25)
    start_instance(no_daemon=no_daemon)


@app.command()
def show():
    result = subprocess.run(args + ["ipc"] + ["show"], capture_output=True)
    if result.returncode != 0:
        sys.stderr.write(result.stderr.decode())
        sys.exit(1)
    sys.stdout.write(result.stdout.decode())
    sys.stderr.write(result.stderr.decode())


@app.command()
def log():
    result = subprocess.run(args + ["log"], capture_output=True)
    if result.returncode != 0:
        sys.stderr.write(result.stderr.decode())
        sys.exit(1)
    sys.stdout.write(result.stdout.decode())
    sys.stderr.write(result.stderr.decode())


@app.command()
def lock():
    result = subprocess.run(args + ["ipc"] + ["call"] + ["lock"] + ["lock"], capture_output=True)
    if result.returncode != 0:
        sys.stderr.write(result.stderr.decode())
        sys.exit(1)
    sys.stderr.write(result.stderr.decode())


@app.command()
def call(target: str, method: str, method_args: list[str] = typer.Argument(None)):
    result = subprocess.run(args + ["ipc"] + ["call"] + [target] + [method] + (method_args or []), capture_output=True)
    if result.returncode != 0:
        sys.stderr.write(result.stderr.decode())
        sys.exit(1)
    sys.stderr.write(result.stderr.decode())
