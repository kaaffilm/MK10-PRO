import json
import os
import pathlib
import subprocess

ROOT = pathlib.Path.cwd().resolve()


def read_json(rel):
    return json.loads((ROOT / rel).read_text())


def test_airgap_audit_release_gate_files_exist():
    for rel in [
        "AIRGAP_AUDIT_RELEASE_GATE.json",
        "docs/AIRGAP_AUDIT_RELEASE_GATE.md",
        "scripts/airgap-audit-release-gate.sh",
        ".github/workflows/airgap-audit-release-gate.yml",
    ]:
        assert (ROOT / rel).exists(), rel

    assert os.access(ROOT / "scripts/airgap-audit-release-gate.sh", os.X_OK)


def test_airgap_audit_release_gate_contract_lock():
    data = read_json("AIRGAP_AUDIT_RELEASE_GATE.json")

    assert data["version"] == "1.0.3"
    assert data["lock"] == "AIRGAP_AUDIT_RELEASE_GATE"
    assert data["network_after_checkout"] == "forbidden"
    assert data["registry_lookup_required"] is False
    assert data["package_install_required"] is False
    assert data["offline_replay_required"] is True
    assert data["no_version_raise"] is True
    assert data["digest_algorithm"] == "sha256"
    assert data["version_boundary"]["locked_version"] == "1.0.3"
    assert data["version_boundary"]["version_raise_allowed"] is False

    for lock in [
        "OFFLINE_AUDIT_LOCK",
        "AIRGAP_AUDIT_BUNDLE",
        "AIRGAP_AUDIT_NEGATIVE_CONTROLS",
        "AIRGAP_AUDIT_DIGEST_LOCK",
    ]:
        assert lock in data["inherited_locks"]

    for rel in data["required_files"]:
        assert (ROOT / rel).exists(), rel


def test_airgap_audit_release_gate_script_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/airgap-audit-release-gate.sh"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
        env={**os.environ, "OUT": str(tmp_path)},
    )

    assert "AIRGAP_AUDIT_RELEASE_GATE_NODE_ASSERT: PASS" in result.stdout
    assert "MK10-PRO v1.0.3 AIRGAP AUDIT RELEASE GATE: PASS" in result.stdout

    receipt = tmp_path / "MK10_PRO_AIRGAP_AUDIT_RELEASE_GATE_RECEIPT.json"
    assert receipt.exists()
    assert isinstance(json.loads(receipt.read_text()), dict)
