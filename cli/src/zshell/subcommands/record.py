import typer
import subprocess

from typing import Optional

app = typer.Typer()

RECORDER = "gpu-screen-recorder"
HOME = str(os.getenv("HOME"))
CONFIG = Path(HOME + "/.config/zshell/config.json")


@app.command()
def start():
