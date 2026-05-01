import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_audit_receipt_contract_exists():
    assert (ROOT / "AUDIT_RECEIPT_CONTRACT.json").exists()
    assert (ROOT / "docs/AUDIT_RECEIPT.md").exists()
    assert (ROOT / "scripts/audit-receipt-proof.sh").exists()


def test_audit_receipt_contract_lock():
    contract = json.loads((ROOT / "AUDIT_RECEIPT_CONTRACT.json").read_text())
    surface = json.loads((ROOT / "PACKAGE_SURFACES.json").read_text())
    pkg = json.loads((ROOT / "packages/npm/package.json").read_text())

    assert contract["version"] == "1.0.3"
    assert contract["locked_version"] == "1.0.3"
    assert contract["canonical_runtime_witness"] == "pypi"
    assert contract["no_version_raise"] is True

    assert surface["version"] == "1.0.3"
    assert surface["version_lock"]["locked_version"] == "1.0.3"
    assert surface["version_lock"]["canonical_runtime_witness"] == "pypi"
    assert pkg["version"] == "1.0.3"


def test_audit_receipt_script_generates_receipt(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/audit-receipt-proof.sh", str(tmp_path)],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "MK10-PRO v1.0.3 AUDIT RECEIPT: PASS" in result.stdout

    receipt_path = tmp_path / "MK10_PRO_AUDIT_RECEIPT.json"
    assert receipt_path.exists()

    receipt = json.loads(receipt_path.read_text())
    assert receipt["status"] == "PASS"
    assert receipt["version"] == "1.0.3"
    assert receipt["locked_version"] == "1.0.3"
    assert receipt["canonical_runtime_witness"] == "pypi"
    assert receipt["no_version_raise"] is True
    assert receipt["proof_chain"]["external_audit_packet"] == "PASS"
    assert receipt["package_surfaces"]["npm"]["runtime_boundary"] == "not_canonical_runtime_witness"
    assert receipt["package_surfaces"]["pkg"]["runtime_boundary"] == "not_canonical_runtime_witness"
