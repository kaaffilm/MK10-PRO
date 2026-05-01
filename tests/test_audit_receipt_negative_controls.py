import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_audit_receipt_negative_control_files_exist():
    required = [
        "AUDIT_RECEIPT_NEGATIVE_CASES.json",
        "docs/AUDIT_RECEIPT_NEGATIVE_CONTROLS.md",
        "scripts/audit-receipt-negative-proof.sh",
    ]
    for rel in required:
        assert (ROOT / rel).exists(), rel


def test_audit_receipt_negative_case_count():
    data = json.loads((ROOT / "AUDIT_RECEIPT_NEGATIVE_CASES.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["locked_version"] == "1.0.3"
    assert len(data["negative_cases"]) == 10
    assert "version_raised" in data["negative_cases"]
    assert "npm_promoted_to_canonical" in data["negative_cases"]
    assert "claim_boundary_expanded" in data["negative_cases"]


def test_audit_receipt_negative_proof_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/audit-receipt-negative-proof.sh", str(tmp_path)],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "AUDIT_RECEIPT_SCHEMA_VERIFY: PASS" in result.stdout
    assert "negative_rejected version_raised.json" in result.stdout
    assert "negative_rejected npm_promoted_to_canonical.json" in result.stdout
    assert "MK10-PRO v1.0.3 AUDIT RECEIPT NEGATIVE CONTROLS: PASS" in result.stdout
