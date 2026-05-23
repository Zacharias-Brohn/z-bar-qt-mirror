from __future__ import annotations

from unittest.mock import patch, call
from zshell.subcommands.shell import app


def invoke(*args: str) -> None:
    from typer.testing import CliRunner

    runner = CliRunner()
    result = runner.invoke(app, args)
    if result.exit_code != 0:
        raise RuntimeError(result.output)
    return result


class TestKill:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_kill_runs_qs_kill(self, mock_run):
        invoke("kill")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "kill"], check=True)


class TestStart:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_start_default_daemon(self, mock_run):
        invoke("start")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "-n", "-d"], check=True)

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_start_no_daemon(self, mock_run):
        invoke("start", "--no-daemon")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "-n"], check=True)


class TestShow:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_show_runs_ipc_show(self, mock_run):
        invoke("show")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "ipc", "show"], check=True)


class TestLog:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_log_runs_qs_log(self, mock_run):
        invoke("log")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "log"], check=True)


class TestLock:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_lock_runs_ipc_call_lock(self, mock_run):
        invoke("lock")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "ipc", "call", "lock", "lock"], check=True)


class TestCall:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_call_no_args(self, mock_run):
        invoke("call", "target", "method")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "ipc", "call", "target", "method"], check=True)

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_call_with_args(self, mock_run):
        invoke("call", "target", "method", "arg1", "arg2")
        mock_run.assert_called_once_with(
            ["qs", "-c", "zshell", "ipc", "call", "target", "method", "arg1", "arg2"],
            check=True,
        )


class TestRestart:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_restart_kills_then_starts_daemon(self, mock_run):
        invoke("restart")
        assert mock_run.call_args_list == [
            call(["qs", "-c", "zshell", "kill"], check=False),
            call(["qs", "-c", "zshell", "-n", "-d"], check=True),
        ]

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_restart_no_daemon(self, mock_run):
        invoke("restart", "--no-daemon")
        assert mock_run.call_args_list == [
            call(["qs", "-c", "zshell", "kill"], check=False),
            call(["qs", "-c", "zshell", "-n"], check=True),
        ]
