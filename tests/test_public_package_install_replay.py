import json
import pathlib
import subprocess

ROOT = pathlib.Path.cwd().resolve()


def test_public_package_install_replay_files_exist():
    for rel in [
        "PUBLIC_PACKAGE_INSTALL_REPLAY.json",
        "docs/PUBLIC_PACKAGE_INSTALL_REPLAY.md",
        "scripts/public-package-install-replay.sh",
        ".github/workflows/public-package-install-replay.yml",
    ]:
        assert (ROOT / rel).exists(), rel


def test_public_package_install_replay_contract_shape():
    data = json.loads((ROOT / "PUBLIC_PACKAGE_INSTALL_REPLAY.json").read_text())
    assert data["artifact"] == "PUBLIC_PACKAGE_INSTALL_REPLAY"
    assert data["version"] == "1.0.3"
    assert data["status"] == "sealed"
    assert data["package"]["name"] == "@kaaffilm/mk10-pro"
    assert data["package"]["version"] == "1.0.3"
    assert data["network_boundary"]["package_replay_after_checkout"] == "forbidden"
    assert "PUBLIC_RELEASE_SEAL.json" in data["requires"]


def test_public_package_install_replay_script_passes():
    result = subprocess.run(
        ["bash", "scripts/public-package-install-replay.sh"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    assert "PUBLIC_PACKAGE_INSTALL_REPLAY_NODE_ASSERT: PASS" in result.stdout
    assert "MK10-PRO v1.0.3 PUBLIC PACKAGE INSTALL REPLAY: PASS" in result.stdout
    assert "negative_rejected npm_package_version_raised" in result.stdout
