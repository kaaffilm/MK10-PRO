import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_external_audit_gate_files_exist():
    required = [
        "EXTERNAL_AUDIT_GATE.json",
        "docs/EXTERNAL_AUDIT_GATE.md",
        "scripts/external-audit-gate.sh",
    ]
    for rel in required:
        assert (ROOT / rel).exists(), rel


def test_external_audit_gate_lock():
    gate = json.loads((ROOT / "EXTERNAL_AUDIT_GATE.json").read_text())
    assert gate["version"] == "1.0.3"
    assert gate["locked_version"] == "1.0.3"
    assert gate["canonical_runtime_witness"] == "pypi"
    assert gate["no_version_raise"] is True
    assert len(gate["required_layers"]) == 7
    assert "audit_receipt_negative_controls" in gate["required_layers"]


def test_external_audit_gate_script_syntax():
    result = subprocess.run(
        ["bash", "-n", "scripts/external-audit-gate.sh"],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
