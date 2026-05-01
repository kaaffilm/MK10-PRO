import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]


def run(cmd):
    return subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    ).stdout


def test_offline_audit_lock_files_exist():
    for rel in [
        "OFFLINE_AUDIT_LOCK.json",
        "docs/OFFLINE_AUDIT_LOCK.md",
        "scripts/offline-audit-lock.sh",
        ".github/workflows/offline-audit-lock.yml",
    ]:
        assert (ROOT / rel).exists(), rel


def test_offline_audit_lock_version_lock():
    data = json.loads((ROOT / "OFFLINE_AUDIT_LOCK.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["no_version_raise"] is True
    assert data["network_after_checkout"] == "forbidden"
    assert data["registry_lookup_required"] is False
    assert data["package_install_required"] is False


def test_offline_audit_lock_script_passes():
    out = run(["bash", "scripts/offline-audit-lock.sh"])
    assert "OFFLINE_AUDIT_LOCK_NODE_ASSERT: PASS" in out
    assert "MK10-PRO v1.0.3 OFFLINE AUDIT LOCK: PASS" in out
