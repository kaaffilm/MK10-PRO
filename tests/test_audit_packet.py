import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_audit_packet_files_exist():
    required = [
        "AUDIT_PACKET.md",
        "docs/AUDIT_PACKET.md",
        "AUDITOR_START_HERE.md",
        "docs/AUDITOR_REPLAY.md",
        "PUBLIC_SURFACE.md",
        "docs/PUBLIC_SURFACE_LOCK.md",
        "docs/PUBLIC_REPLAY_PERIMETER.md",
        "scripts/audit-packet-proof.sh",
    ]
    for rel in required:
        assert (ROOT / rel).exists(), rel


def test_audit_packet_version_lock():
    surface = json.loads((ROOT / "PACKAGE_SURFACES.json").read_text())
    pkg = json.loads((ROOT / "packages/npm/package.json").read_text())

    assert surface["version"] == "1.0.3"
    assert surface["version_lock"]["locked_version"] == "1.0.3"
    assert surface["version_lock"]["canonical_runtime_witness"] == "pypi"
    assert pkg["version"] == "1.0.3"


def test_audit_packet_boundary_text():
    text = (ROOT / "AUDIT_PACKET.md").read_text()
    assert "Do not raise the public package version" in text
    assert "Canonical runtime witness: PyPI" in text
    assert "NPM package page" in text
    assert "PKG" in text
    assert "does not verify" in text.lower()


def test_audit_packet_script_passes():
    result = subprocess.run(
        ["bash", "scripts/audit-packet-proof.sh"],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "MK10-PRO v1.0.3 EXTERNAL AUDIT PACKET: PASS" in result.stdout
