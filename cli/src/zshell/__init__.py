from __future__ import annotations
import os
import sys
from pathlib import Path

import typer
from typer._completion_shared import install, _get_shell_name
from typer._completion_classes import completion_init
from zshell.subcommands import shell, scheme, screenshot, wallpaper, record

app = typer.Typer(name="zshell-cli", add_completion=False)

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


def _install_completion() -> None:
    if _completion_installed():
        print("zshell-cli: Shell completion already installed.")
        raise typer.Exit()
    shell = _get_shell_name()
    if shell is None:
        print("zshell-cli: Unable to detect shell type.", file=sys.stderr)
        raise typer.Exit(code=1)
    try:
        _, path = install(prog_name="zshell-cli")
        print(f"zshell-cli: Shell completion installed ({shell}: {path})")
        print("zshell-cli: Restart your shell or source the file to enable tab-completion.")
    except Exception as e:
        print(f"zshell-cli: Failed to install shell completion: {e}", file=sys.stderr)
        raise typer.Exit(code=1)


def main() -> None:
    if "--install-autocomplete" in sys.argv:
        _install_completion()
        return
    if "_ZSHELL_CLI_COMPLETE" in os.environ:
        completion_init()
    if sys.stdout.isatty() and not _completion_installed():
        print("zshell-cli: Tip: run with --install-autocomplete for tab completion.", file=sys.stderr)
    app()
