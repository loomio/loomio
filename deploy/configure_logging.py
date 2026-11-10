#!/usr/bin/env python3
"""Preview or install Loomio's web access log policy; never recreate containers."""

import argparse
import datetime
import difflib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


PROFILES = {"private": "32M", "production": "128M"}


def policy_files(profile):
    """Retain selected request metadata without changing host journal policy."""
    return {
        "etc/rsyslog.d/20-loomio-access.conf": r'''# imuxsock is loaded by Ubuntu's /etc/rsyslog.conf.
# Keep only request metadata; omit queries, bodies, cookies and extra headers.
template(name="loomio_access_json" type="list" option.jsonf="on") {
    property(outname="time" name="timegenerated" dateFormat="rfc3339" format="jsonf")
    property(outname="host" name="hostname" format="jsonf")
    property(outname="method" name="$!access!method" format="jsonf" position.to="20")
    property(outname="path" name="$.path" format="jsonf" position.to="1000")
    property(outname="status" name="$!access!status" format="jsonf")
    property(outname="peer" name="$!access!remote_addr" format="jsonf" position.to="100")
    property(outname="reported_client" name="$!access!client_addr" format="jsonf" position.to="100")
    property(outname="request_id" name="$!access!request_id" format="jsonf" position.to="200")
    property(outname="user_agent" name="$!access!user_agent" format="jsonf" position.to="500")
}
ruleset(name="loomio_access") {
    # nginx-proxy's supervisor prefixes stdout; Kamal emits JSON directly.
    set $.json = re_extract($msg, "(\\{.*\\})\$", 0, 1, "");
    set $.parsed = parse_json($.json, "\$!access");
    if $.parsed != 0 then stop
    if ($!access!method == "" or cnum($!access!status) < 100 or cnum($!access!status) > 599) then stop
    set $.path = re_extract($!access!path, "^([^?]*)", 0, 1, "");
    # Token-bearing links must not leave a reusable credential in the archive.
    if re_match($.path, "^/(login_tokens|invitations|join)/") then set $.path = "/[authentication-link]";
    if re_match($.path, "^/email_actions/mark_(discussion|notification)_as_read/") then set $.path = "/email_actions/[read-link]";
    action(type="omfile" file="/var/log/loomio-access/access.jsonl"
        template="loomio_access_json" fileOwner="syslog" fileGroup="adm"
        fileCreateMode="0600" dirCreateMode="0700")
    stop
}
input(type="imuxsock" Socket="/var/spool/rsyslog/loomio-access.sock"
    CreatePath="on" RateLimit.Interval="0" ruleset="loomio_access")
''',
        "etc/loomio/access-logrotate.conf": f"""/var/log/loomio-access/access.jsonl {{
    daily
    maxsize {PROFILES[profile]}
    rotate 30
    maxage 30
    missingok
    # Rotate empty files too, so a quiet site still expires old archives.
    ifempty
    compress
    delaycompress
    create 0600 syslog adm
    su syslog adm
    sharedscripts
    postrotate
        /usr/bin/systemctl kill --kill-whom=main --signal=HUP rsyslog.service
    endscript
}}
""",
        "etc/systemd/system/loomio-access-log-rotation.service": """[Unit]
Description=Rotate retained Loomio web access metadata
After=rsyslog.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/logrotate --state /var/lib/loomio/access-logrotate.status /etc/loomio/access-logrotate.conf
""",
        "etc/systemd/system/loomio-access-log-rotation.timer": """[Unit]
Description=Check Loomio access log rotation every five minutes

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
""",
    }


def atomic_write(path, content, mode=0o644):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as output:
        temporary = Path(output.name)
        try:
            os.fchmod(output.fileno(), mode)
            output.write(content)
            output.flush()
            os.fsync(output.fileno())
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", required=True, choices=PROFILES)
    parser.add_argument("--apply", action="store_true", help="install files and activate the policy")
    parser.add_argument("--root", type=Path, default=Path("/"), help="stage files under another root without running host commands")
    args = parser.parse_args()
    root = args.root.resolve()
    live = root == Path("/")
    files = policy_files(args.profile)
    previous = {}
    timer_enabled = False
    timer_active = False
    rsyslog_active = False

    # Read and validate every target before writing any of them.
    for relative, content in files.items():
        path = root / relative
        if path.is_symlink() or any(parent.is_symlink() for parent in path.parents):
            parser.error(f"refusing a symlink in target path: {path}")
        original = path.read_bytes() if path.exists() else None
        if original != content.encode():
            previous[relative] = original
            print("".join(difflib.unified_diff(
                (original or b"").decode().splitlines(True), content.splitlines(True),
                fromfile=str(path), tofile=str(path) + " (proposed)")), end="")

    if not args.apply:
        print("Preview only. --apply installs the policy; existing history may expire under the new limits.")
        return
    if live:
        if os.geteuid() != 0:
            parser.error("--apply on the host requires root")
        if not Path("/run/systemd/system").is_dir():
            parser.error("the host must be running systemd")
        for command in ["systemctl", "rsyslogd", "logrotate"]:
            if shutil.which(command) is None:
                parser.error(f"required command missing: {command}")
        if subprocess.run(["systemctl", "is-active", "--quiet", "rsyslog"]).returncode != 0:
            parser.error("rsyslog must already be running")
        timer_enabled = subprocess.run(["systemctl", "is-enabled", "--quiet", "loomio-access-log-rotation.timer"]).returncode == 0
        timer_active = subprocess.run(["systemctl", "is-active", "--quiet", "loomio-access-log-rotation.timer"]).returncode == 0
        rsyslog_active = subprocess.run(["systemctl", "is-active", "--quiet", "rsyslog"]).returncode == 0

    backup = None
    if previous:
        timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
        backup = root / "var/lib/loomio/logging" / timestamp
        backup.mkdir(parents=True, mode=0o700)
        for relative, original in previous.items():
            if original is not None:
                atomic_write(backup / relative, original, 0o600)
        atomic_write(backup / "previously-absent.txt", "".join(
            relative + "\n" for relative, original in previous.items() if original is None
        ).encode(), 0o600)

    try:
        for relative in previous:
            atomic_write(root / relative, files[relative].encode())
        if live:
            import pwd
            import grp
            syslog_uid = pwd.getpwnam("syslog").pw_uid
            adm_gid = grp.getgrnam("adm").gr_gid
            path = Path("/var/log/loomio-access")
            path.mkdir(parents=True, exist_ok=True)
            os.chown(path, syslog_uid, adm_gid)
            os.chmod(path, 0o700)
            Path("/var/spool/rsyslog").mkdir(parents=True, exist_ok=True)
            Path("/var/lib/loomio").mkdir(parents=True, exist_ok=True)
            subprocess.run(["rsyslogd", "-N1"], check=True)
            subprocess.run(["logrotate", "--debug", "/etc/loomio/access-logrotate.conf"], check=True)
            subprocess.run(["systemctl", "daemon-reload"], check=True)
            if previous:
                subprocess.run(["systemctl", "restart", "rsyslog"], check=True)
            subprocess.run(["systemctl", "enable", "--now", "loomio-access-log-rotation.timer"], check=True)
    except (OSError, subprocess.CalledProcessError):
        if live:
            if not timer_active:
                subprocess.run(["systemctl", "stop", "loomio-access-log-rotation.timer"], check=False)
            if not timer_enabled:
                subprocess.run(["systemctl", "disable", "loomio-access-log-rotation.timer"], check=False)
        for relative, original in previous.items():
            if original is None:
                (root / relative).unlink(missing_ok=True)
            else:
                atomic_write(root / relative, original)
        if live:
            subprocess.run(["systemctl", "daemon-reload"], check=False)
            if rsyslog_active:
                subprocess.run(["systemctl", "restart", "rsyslog"], check=False)
            if timer_active:
                subprocess.run(["systemctl", "restart", "loomio-access-log-rotation.timer"], check=False)
        raise

    print(f"{'Installed' if live else 'Staged'} {args.profile} policy; {len(previous)} files changed.")
    if backup:
        print(f"Previous files: {backup}")
    print("Container logging drivers are unchanged until containers are recreated.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
