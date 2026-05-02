import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read_text(rel: str) -> str:
    return (ROOT / rel).read_text()


def read_json(rel: str):
    return json.loads(read_text(rel))


def test_public_registry_install_replay_contract_files_exist():
    required = [
        "PUBLIC_REGISTRY_INSTALL_REPLAY.json",
        "PUBLIC_REGISTRY_ARTIFACT_LOCK.json",
        "PUBLIC_REGISTRY_RELEASE_READINESS.json",
        "PUBLIC_PACKAGE_INSTALL_REPLAY.json",
        "PUBLIC_RELEASE_SEAL.json",
        "docs/PUBLIC_REGISTRY_INSTALL_REPLAY.md",
        "scripts/public-registry-install-replay.sh",
        ".github/workflows/public-registry-install-replay.yml",
    ]

    for rel in required:
        assert (ROOT / rel).exists(), rel

    manifest = read_text("MANIFEST.in")
    assert "include PUBLIC_REGISTRY_INSTALL_REPLAY.json" in manifest
    assert "include PUBLIC_REGISTRY_ARTIFACT_LOCK.json" in manifest


def test_public_registry_install_replay_contract_shape():
    data = read_json("PUBLIC_REGISTRY_INSTALL_REPLAY.json")
    encoded = json.dumps(data, sort_keys=True)

    assert data["version"] == "1.0.3"
    assert "@kaaffilm/mk10-pro" in encoded
    assert "PUBLIC_REGISTRY_ARTIFACT_LOCK.json" in encoded
    assert "PUBLIC_REGISTRY_RELEASE_READINESS.json" in encoded
    assert "public registry" in encoded.lower()
    assert "registry.npmjs.org" in encoded
    assert "local tarball" in encoded.lower()


def test_public_registry_install_replay_script_contract_shape_passes():
    script = ROOT / "scripts/public-registry-install-replay.sh"
    assert os.access(script, os.X_OK)

    result = subprocess.run(
        [str(script)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )

    assert "PUBLIC_REGISTRY_INSTALL_REPLAY_CONTRACT_SHAPE: PASS" in result.stdout
    assert "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY: PASS" in result.stdout
