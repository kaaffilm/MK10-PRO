import json
import os
import pathlib
import subprocess

ROOT = pathlib.Path.cwd().resolve()


def test_airgap_audit_digest_lock_files_exist():
    for rel in [
        "AIRGAP_AUDIT_DIGEST_LOCK.json",
        "docs/AIRGAP_AUDIT_DIGEST_LOCK.md",
        "scripts/airgap-audit-digest-lock.sh",
        ".github/workflows/airgap-audit-digest-lock.yml",
    ]:
        assert (ROOT / rel).is_file(), rel


def test_airgap_audit_digest_lock_contract():
    data = json.loads((ROOT / "AIRGAP_AUDIT_DIGEST_LOCK.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["lock"] == "AIRGAP_AUDIT_DIGEST_LOCK"
    assert data["digest_algorithm"] == "sha256"
    assert data["network_after_checkout"] == "forbidden"
    assert data["registry_lookup_required"] is False
    assert data["package_install_required"] is False
    assert data["offline_replay_required"] is True
    assert data["no_version_raise"] is True
    assert data["version_boundary"]["locked_version"] == "1.0.3"
    assert data["version_boundary"]["version_raise_allowed"] is False
    assert "OFFLINE_AUDIT_LOCK" in data["inherited_locks"]
    assert "AIRGAP_AUDIT_BUNDLE" in data["inherited_locks"]
    assert "AIRGAP_AUDIT_NEGATIVE_CONTROLS" in data["inherited_locks"]
    assert "scripts/airgap-audit-digest-lock.sh" in data["required_files"]
    assert "tests/test_airgap_audit_digest_lock.py" in data["required_files"]


def test_airgap_audit_digest_lock_script_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/airgap-audit-digest-lock.sh"],
        cwd=ROOT,
        env={**os.environ, "OUT": str(tmp_path)},
        text=True,
        capture_output=True,
        check=True,
    )

    assert "AIRGAP_AUDIT_DIGEST_LOCK_NODE_ASSERT: PASS" in result.stdout
    assert "MK10-PRO v1.0.3 AIRGAP AUDIT DIGEST LOCK: PASS" in result.stdout

    receipt = tmp_path / "MK10_PRO_AIRGAP_AUDIT_DIGEST_LOCK_RECEIPT.json"
    assert receipt.is_file()

    data = json.loads(receipt.read_text())
    assert data["version"] == "1.0.3"
    assert data["lock"] == "AIRGAP_AUDIT_DIGEST_LOCK"
    assert data["pass"] is True
    assert data["digest_algorithm"] == "sha256"
    assert any(f["path"] == "AIRGAP_AUDIT_DIGEST_LOCK.json" for f in data["files"])
