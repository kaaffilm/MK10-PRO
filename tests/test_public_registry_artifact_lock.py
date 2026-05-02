import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]

def test_public_registry_artifact_lock_files_exist():
    for rel in [
        "PUBLIC_REGISTRY_ARTIFACT_LOCK.json",
        "docs/PUBLIC_REGISTRY_ARTIFACT_LOCK.md",
        "scripts/public-registry-artifact-lock.sh",
        ".github/workflows/public-registry-artifact-lock.yml",
    ]:
        assert (ROOT / rel).exists(), rel

def test_public_registry_artifact_lock_contract_shape():
    data = json.loads((ROOT / "PUBLIC_REGISTRY_ARTIFACT_LOCK.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["registry_package"] == "@kaaffilm/mk10-pro"
    assert data["registry_version"] == "1.0.3"
    assert data["registry_integrity"].startswith("sha512-")
    assert data["registry_shasum"]
    assert "mk10-pro-1.0.3.tgz" in data["registry_tarball"]
    assert "scripts/public-registry-artifact-lock.sh" in data["required_files"]

def test_public_registry_artifact_lock_script_passes():
    result = subprocess.run(
        ["bash", "scripts/public-registry-artifact-lock.sh"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
    )
    assert "MK10-PRO v1.0.3 PUBLIC REGISTRY ARTIFACT LOCK: PASS" in result.stdout
