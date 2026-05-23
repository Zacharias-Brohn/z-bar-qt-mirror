import subprocess
import sys
import time

import click
import typer

args = ["qs", "-c", "zshell"]

app = typer.Typer()


@app.command()
def kill():
    result = subprocess.run(args + ["kill"], capture_output=True)
    if result.returncode != 0:
        raise click.ClickException("No running instance to kill.")
    sys.stderr.write(result.stderr.decode())


@app.command()
def start(no_daemon: bool = False):
    check = subprocess.run(args + ["ipc"] + ["show"], capture_output=True)
    if check.returncode == 0:
        raise click.ClickException("An instance of this configuration is already running.")
    result = subprocess.run(args + ["-n"] + ([] if no_daemon else ["-d"]), capture_output=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.decode().strip())
    sys.stderr.write(result.stderr.decode())


@app.command()
def restart(no_daemon: bool = False):
    subprocess.run(args + ["kill"])
    for _ in range(50):
        result = subprocess.run(args + ["kill"], capture_output=True)
        if result.returncode == 255:
            break
        time.sleep(0.05)
    result = subprocess.run(args + ["-n"] + ([] if no_daemon else ["-d"]), capture_output=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.decode().strip())
    sys.stderr.write(result.stderr.decode())


@app.command()
def show():
    result = subprocess.run(args + ["ipc"] + ["show"], capture_output=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.decode().strip())
    sys.stderr.write(result.stderr.decode())


@app.command()
def log():
    result = subprocess.run(args + ["log"], capture_output=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.decode().strip())
    sys.stdout.write(result.stdout.decode())
    sys.stderr.write(result.stderr.decode())


@app.command()
def lock():
    result = subprocess.run(args + ["ipc"] + ["call"] + ["lock"] + ["lock"], capture_output=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.decode().strip())
    sys.stderr.write(result.stderr.decode())


@app.command()
def call(target: str, method: str, method_args: list[str] = typer.Argument(None)):
    result = subprocess.run(args + ["ipc"] + ["call"] + [target] + [method] + (method_args or []), capture_output=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.decode().strip())
    sys.stderr.write(result.stderr.decode())
