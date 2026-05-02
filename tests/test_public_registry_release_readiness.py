import json
import pathlib
import subprocess

ROOT = pathlib.Path.cwd().resolve()


def test_public_registry_release_readiness_files_exist():
    for rel in [
        "PUBLIC_REGISTRY_RELEASE_READINESS.json",
        "docs/PUBLIC_REGISTRY_RELEASE_READINESS.md",
        "scripts/public-registry-release-readiness.sh",
        ".github/workflows/public-registry-release-readiness.yml",
    ]:
        assert (ROOT / rel).exists(), rel


def test_public_registry_release_readiness_contract_shape():
    data = json.loads((ROOT / "PUBLIC_REGISTRY_RELEASE_READINESS.json").read_text())
    assert data["schema_version"] == 1
    assert data["boundary"] == "PUBLIC_REGISTRY_RELEASE_READINESS"
    assert data["project"] == "MK10-PRO"
    assert data["version"] == "1.0.3"
    assert data["package"]["name"] == "@kaaffilm/mk10-pro"
    assert data["package"]["version"] == "1.0.3"
    assert data["package"]["registry_write_allowed"] is False
    assert "PUBLIC_PACKAGE_INSTALL_REPLAY.json" in data["depends_on"]
    assert "PUBLIC_RELEASE_SEAL.json" in data["depends_on"]


def test_public_registry_release_readiness_script_passes():
    result = subprocess.run(
        ["bash", "scripts/public-registry-release-readiness.sh"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert result.returncode == 0, result.stdout
    assert "MK10-PRO v1.0.3 PUBLIC REGISTRY RELEASE READINESS: PASS" in result.stdout
