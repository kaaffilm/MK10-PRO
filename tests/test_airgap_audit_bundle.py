import json
import os
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]


def test_airgap_audit_bundle_files_exist():
    for rel in [
        "AIRGAP_AUDIT_BUNDLE.json",
        "docs/AIRGAP_AUDIT_BUNDLE.md",
        "scripts/airgap-audit-bundle.sh",
        ".github/workflows/airgap-audit-bundle.yml",
    ]:
        assert (ROOT / rel).exists(), rel


def test_airgap_audit_bundle_contract_lock():
    data = json.loads((ROOT / "AIRGAP_AUDIT_BUNDLE.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["no_version_raise"] is True
    assert data["network_after_checkout"] == "forbidden"
    assert data["registry_lookup_required"] is False
    assert data["package_install_required"] is False
    assert data["offline_replay_required"] is True


def test_airgap_audit_bundle_script_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/airgap-audit-bundle.sh"],
        cwd=ROOT,
        env={**os.environ, "OUT": str(tmp_path)},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    assert "MK10-PRO v1.0.3 AIRGAP AUDIT BUNDLE: PASS" in result.stdout
    assert (tmp_path / "MK10_PRO_AIRGAP_AUDIT_BUNDLE_RECEIPT.json").exists()
