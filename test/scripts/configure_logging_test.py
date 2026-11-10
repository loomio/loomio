#!/usr/bin/env python3
"""Exercise host-policy staging and recovery without changing the local host."""

import contextlib
import importlib.util
import io
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


sys.dont_write_bytecode = True
REPOSITORY = Path(__file__).resolve().parents[2]
SCRIPT = REPOSITORY / "deploy/configure_logging.py"
spec = importlib.util.spec_from_file_location("configure_logging", SCRIPT)
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class ConfigureLoggingTest(unittest.TestCase):
    def invoke(self, root, *arguments):
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(root), "--profile", "private", *arguments],
            capture_output=True, text=True, check=True,
        )

    def test_preview_does_not_create_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "stage"
            result = self.invoke(root)
            self.assertIn("Preview only", result.stdout)
            self.assertFalse(root.exists())

    def test_staging_preserves_previous_configuration_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            target = root / "etc/rsyslog.d/20-loomio-access.conf"
            target.parent.mkdir(parents=True)
            target.write_text("original access rules\n")
            self.invoke(root, "--apply")
            backups = list((root / "var/lib/loomio/logging").iterdir())
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / target.relative_to(root)).read_text(), "original access rules\n")
            self.assertIn("loomio_access_json", target.read_text())
            result = self.invoke(root, "--apply")
            self.assertIn("0 files changed", result.stdout)
            self.assertEqual(list((root / "var/lib/loomio/logging").iterdir()), backups)

    def test_production_rotation_size_and_retention(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.invoke(root, "--profile", "production", "--apply")
            rotation = (root / "etc/loomio/access-logrotate.conf").read_text()
            self.assertIn("maxsize 128M", rotation)
            self.assertIn("rotate 30", rotation)
            self.assertIn("maxage 30", rotation)
            self.assertIn("create 0600 syslog adm", rotation)

    def test_failure_restores_original_files_and_removes_new_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            original = root / "etc/rsyslog.d/20-loomio-access.conf"
            original.parent.mkdir(parents=True)
            original.write_text("original access rules\n")
            write = installer.atomic_write
            failed = False

            def fail_once(path, content, mode=0o644):
                nonlocal failed
                if path == root / "etc/systemd/system/loomio-access-log-rotation.service" and not failed:
                    failed = True
                    raise OSError("simulated failed install")
                write(path, content, mode)

            with patch.object(sys, "argv", [str(SCRIPT), "--profile", "private", "--root", str(root), "--apply"]), \
                    patch.object(installer, "atomic_write", side_effect=fail_once), \
                    patch.object(installer.subprocess, "run", side_effect=AssertionError("staging must not run services")), \
                    contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(OSError, "simulated failed install"):
                    installer.main()
            self.assertEqual(original.read_text(), "original access rules\n")
            self.assertFalse((root / "etc/loomio/access-logrotate.conf").exists())
            self.assertFalse((root / "etc/systemd/system/loomio-access-log-rotation.service").exists())

    def test_refuses_symlinked_target_directories_before_writing(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "stage"
            outside = Path(temporary) / "outside"
            root.mkdir()
            outside.mkdir()
            (root / "etc").symlink_to(outside, target_is_directory=True)
            with self.assertRaises(subprocess.CalledProcessError):
                self.invoke(root, "--apply")
            self.assertEqual(list(outside.iterdir()), [])
            self.assertFalse((root / "var").exists())


if __name__ == "__main__":
    unittest.main()
