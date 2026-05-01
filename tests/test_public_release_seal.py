import json
import os
import pathlib
import subprocess

ROOT = pathlib.Path.cwd().resolve()


def test_public_release_seal_files_exist():
    required = [
        "PUBLIC_RELEASE_SEAL.json",
        "RELEASE_INDEX.json",
        "docs/PUBLIC_RELEASE_SEAL.md",
        "docs/RELEASE_INDEX.md",
        "scripts/public-release-seal.sh",
        ".github/workflows/public-release-seal.yml",
    ]
    for rel in required:
        assert (ROOT / rel).exists(), rel


def test_public_release_seal_contract_shape():
    seal = json.loads((ROOT / "PUBLIC_RELEASE_SEAL.json").read_text())
    index = json.loads((ROOT / "RELEASE_INDEX.json").read_text())

    assert seal["package"] == "@kaaffilm/mk10-pro"
    assert seal["package_version"] == "1.0.3"
    assert seal["release"] == "v1.0.3"
    assert seal["package_mutation"] == "forbidden"
    assert seal["feature_surface_mutation"] == "forbidden"
    assert seal["network_after_checkout"] == "forbidden"
    assert seal["requires_release_gate"] is True

    verifier_names = {v["name"] for v in index["required_verifiers"]}
    assert "offline audit lock" in verifier_names
    assert "airgap audit bundle" in verifier_names
    assert "airgap audit negative controls" in verifier_names
    assert "airgap audit digest lock" in verifier_names
    assert "airgap audit release gate" in verifier_names
    assert "public release seal" in verifier_names


def test_public_release_seal_script_passes(tmp_path):
    result = subprocess.run(
        ["bash", "scripts/public-release-seal.sh"],
        cwd=ROOT,
        env={**os.environ, "OUT": str(tmp_path)},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    assert "MK10-PRO v1.0.3 PUBLIC RELEASE SEAL: PASS" in result.stdout
    receipt = tmp_path / "MK10_PRO_PUBLIC_RELEASE_SEAL_RECEIPT.json"
    assert receipt.exists()
    data = json.loads(receipt.read_text())
    assert data["pass"] is True
    assert data["package_version"] == "1.0.3"
    assert data["upstream_release_gate_receipt_sha256"]
