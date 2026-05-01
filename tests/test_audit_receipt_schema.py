import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_audit_receipt_schema_files_exist():
    required = [
        "AUDIT_RECEIPT_SCHEMA.json",
        "docs/AUDIT_RECEIPT_SCHEMA.md",
        "scripts/verify-audit-receipt.cjs",
        "scripts/audit-receipt-schema-proof.sh",
    ]
    for rel in required:
        assert (ROOT / rel).exists(), rel


def test_audit_receipt_schema_constants():
    schema = json.loads((ROOT / "AUDIT_RECEIPT_SCHEMA.json").read_text())
    assert schema["title"] == "MK10-PRO v1.0.3 Audit Receipt"
    assert schema["properties"]["version"]["const"] == "1.0.3"
    assert schema["properties"]["locked_version"]["const"] == "1.0.3"
    assert schema["properties"]["canonical_runtime_witness"]["const"] == "pypi"
    assert schema["properties"]["no_version_raise"]["const"] is True


def test_audit_receipt_schema_proof_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/audit-receipt-schema-proof.sh", str(tmp_path)],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "AUDIT_RECEIPT_SCHEMA_VERIFY: PASS" in result.stdout
    assert "MK10-PRO v1.0.3 AUDIT RECEIPT SCHEMA: PASS" in result.stdout
