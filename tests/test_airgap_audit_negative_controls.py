import json
import os
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]


def test_airgap_audit_negative_controls_files_exist():
    for rel in [
        "AIRGAP_AUDIT_NEGATIVE_CONTROLS.json",
        "docs/AIRGAP_AUDIT_NEGATIVE_CONTROLS.md",
        "scripts/airgap-audit-negative-controls.sh",
        ".github/workflows/airgap-audit-negative-controls.yml",
    ]:
        assert (ROOT / rel).exists(), rel


def test_airgap_audit_negative_controls_contract_lock():
    data = json.loads((ROOT / "AIRGAP_AUDIT_NEGATIVE_CONTROLS.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["lock"] == "AIRGAP_AUDIT_NEGATIVE_CONTROLS"
    assert data["version_boundary"]["locked_version"] == "1.0.3"
    assert data["version_boundary"]["version_raise_allowed"] is False
    assert data["network_after_checkout"] == "forbidden"
    assert data["registry_lookup_required"] is False
    assert data["package_install_required"] is False

    required = set(data["required_negative_controls"])
    assert {
        "airgap_contract_version_raised",
        "npm_package_version_raised",
        "pyproject_version_raised",
        "airgap_contract_removed",
        "airgap_script_removed",
        "offline_lock_script_removed",
        "workflow_run_removed",
        "forbidden_curl_added",
        "forbidden_git_fetch_added",
        "forbidden_package_install_added",
    }.issubset(required)


def test_airgap_audit_negative_controls_script_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/airgap-audit-negative-controls.sh"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env={**os.environ, "OUT": str(tmp_path)},
        check=True,
    )
    assert "AIRGAP_AUDIT_NEGATIVE_CONTROLS_NODE_ASSERT: PASS" in result.stdout
    assert "MK10-PRO v1.0.3 AIRGAP AUDIT NEGATIVE CONTROLS: PASS" in result.stdout
