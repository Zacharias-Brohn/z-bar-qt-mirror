from __future__ import annotations

from subprocess import CompletedProcess
from unittest.mock import patch, call

from typer.testing import CliRunner
from zshell.subcommands.shell import app

runner = CliRunner()


def invoke(*args: str):
    result = runner.invoke(app, args)
    if result.exit_code != 0:
        raise RuntimeError(result.output)
    return result


class TestKill:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_kill_runs_qs_kill_success(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"", b"Killed abc\n")
        invoke("kill")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "kill"], capture_output=True)

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_kill_no_instance_errors(self, mock_run):
        mock_run.return_value = CompletedProcess([], 255, b"", b"No running instances\n")
        result = runner.invoke(app, ["kill"])
        assert result.exit_code != 0
        assert "No running instance to kill" in result.output


class TestStart:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_start_default_daemon(self, mock_run):
        mock_run.side_effect = [
            CompletedProcess([], 1, b"", b""),  # ipc show → no instance
            CompletedProcess([], 0, b"", b"Launching config\n"),  # launch ok
        ]
        invoke("start")
        assert mock_run.call_args_list == [
            call(["qs", "-c", "zshell", "ipc", "show"], capture_output=True),
            call(["qs", "-c", "zshell", "-n", "-d"], capture_output=True),
        ]

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_start_no_daemon(self, mock_run):
        mock_run.side_effect = [
            CompletedProcess([], 1, b"", b""),
            CompletedProcess([], 0, b"", b"Launching config\n"),
        ]
        invoke("start", "--no-daemon")
        assert mock_run.call_args_list == [
            call(["qs", "-c", "zshell", "ipc", "show"], capture_output=True),
            call(["qs", "-c", "zshell", "-n"], capture_output=True),
        ]

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_start_already_running_errors(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"", b"target visibilities\n")
        result = runner.invoke(app, ["start"])
        assert result.exit_code != 0
        assert "already running" in result.output


class TestShow:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_show_runs_ipc_show(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"", b"target visibilities\n")
        invoke("show")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "ipc", "show"], capture_output=True)


class TestLog:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_log_runs_qs_log(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"log output\n", b"")
        invoke("log")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "log"], capture_output=True)


class TestLock:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_lock_runs_ipc_call_lock(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"", b"")
        invoke("lock")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "ipc", "call", "lock", "lock"], capture_output=True)


class TestCall:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_call_no_args(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"", b"")
        invoke("call", "target", "method")
        mock_run.assert_called_once_with(["qs", "-c", "zshell", "ipc", "call", "target", "method"], capture_output=True)

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_call_with_args(self, mock_run):
        mock_run.return_value = CompletedProcess([], 0, b"", b"")
        invoke("call", "target", "method", "arg1", "arg2")
        mock_run.assert_called_once_with(
            ["qs", "-c", "zshell", "ipc", "call", "target", "method", "arg1", "arg2"],
            capture_output=True,
        )


class TestRestart:
    @patch("zshell.subcommands.shell.subprocess.run")
    def test_restart_kills_then_starts(self, mock_run):
        mock_run.side_effect = [
            CompletedProcess([], 0, b"", b"Killed abc\n"),  # first kill (no capture)
            CompletedProcess([], 255, b"", b""),  # poll → no instance
            CompletedProcess([], 0, b"", b"Launching config\n"),  # launch ok
        ]
        invoke("restart")
        assert mock_run.call_args_list == [
            call(["qs", "-c", "zshell", "kill"]),  # no capture_output
            call(["qs", "-c", "zshell", "kill"], capture_output=True),
            call(["qs", "-c", "zshell", "-n", "-d"], capture_output=True),
        ]

    @patch("zshell.subcommands.shell.subprocess.run")
    def test_restart_no_daemon(self, mock_run):
        mock_run.side_effect = [
            CompletedProcess([], 0, b"", b"Killed abc\n"),
            CompletedProcess([], 255, b"", b""),
            CompletedProcess([], 0, b"", b"Launching config\n"),
        ]
        invoke("restart", "--no-daemon")
        assert mock_run.call_args_list == [
            call(["qs", "-c", "zshell", "kill"]),
            call(["qs", "-c", "zshell", "kill"], capture_output=True),
            call(["qs", "-c", "zshell", "-n"], capture_output=True),
        ]
