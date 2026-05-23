import subprocess
import time
import typer

args = ["qs", "-c", "zshell"]

app = typer.Typer()


@app.command()
def kill():
    subprocess.run(args + ["kill"], check=False)


@app.command()
def start(no_daemon: bool = False):
    subprocess.run(args + ["-n"] + ([] if no_daemon else ["-d"]), check=True)


@app.command()
def restart(no_daemon: bool = False):
    subprocess.run(args + ["kill"], check=False)
    for _ in range(50):
        result = subprocess.run(args + ["kill"], capture_output=True)
        if result.returncode == 255:
            break
        time.sleep(0.05)
    subprocess.run(args + ["-n"] + ([] if no_daemon else ["-d"]), check=True)


@app.command()
def show():
    subprocess.run(args + ["ipc"] + ["show"], check=True)


@app.command()
def log():
    subprocess.run(args + ["log"], check=True)


@app.command()
def lock():
    subprocess.run(args + ["ipc"] + ["call"] + ["lock"] + ["lock"], check=True)


@app.command()
def call(target: str, method: str, method_args: list[str] = typer.Argument(None)):
    subprocess.run(args + ["ipc"] + ["call"] + [target] + [method] + (method_args or []), check=True)
