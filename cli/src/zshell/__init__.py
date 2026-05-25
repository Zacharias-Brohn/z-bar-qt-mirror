from __future__ import annotations
import sys
from pathlib import Path

import click
import typer
from typer._completion_shared import install, _get_shell_name
from zshell.subcommands import shell, scheme, screenshot, wallpaper, record

app = typer.Typer(name="zshell-cli")

app.add_typer(shell.app, name="shell")
app.add_typer(scheme.app, name="scheme")
app.add_typer(screenshot.app, name="screenshot")
app.add_typer(wallpaper.app, name="wallpaper")
app.add_typer(record.app, name="record")


def _completion_installed() -> bool:
    shell = _get_shell_name()
    match shell:
        case "zsh":
            return (Path.home() / ".zfunc" / "_zshell-cli").exists()
        case "bash":
            return (Path.home() / ".bash_completions" / "zshell-cli.sh").exists()
        case "fish":
            return (Path.home() / ".config" / "fish" / "completions" / "zshell-cli.fish").exists()
    return False


def _auto_install_completion() -> None:
    if not sys.stdout.isatty():
        return
    if _completion_installed():
        return
    shell = _get_shell_name()
    if shell is None:
        return
    try:
        _, path = install(prog_name="zshell-cli")
        click.secho(f"zshell-cli: Shell completion installed ({shell}: {path})", fg="green")
        click.echo("zshell-cli: Restart your shell or source the file to enable tab-completion.")
    except Exception:
        pass


def main() -> None:
    _auto_install_completion()
    app()
