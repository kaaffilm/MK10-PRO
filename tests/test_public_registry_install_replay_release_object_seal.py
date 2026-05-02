import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_public_registry_install_replay_release_object_seal_files_exist():
    assert (ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.json").is_file()
    assert (ROOT / "docs/PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.md").is_file()
    assert (ROOT / "scripts/public-registry-install-replay-release-object-seal.sh").is_file()


def test_public_registry_install_replay_release_object_seal_shape():
    data = json.loads((ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.json").read_text())

    assert data["contract_version"] == "1.0.3"
    assert data["repo"] == "kaaffilm/MK10-PRO"
    assert data["package"] == "@kaaffilm/mk10-pro"
    assert data["package_version"] == "1.0.3"
    assert data["merged_main_head"] == "3174f958c45944b9c929f5a945532cac9f772edb"
    assert data["seal_tag"] == "mk10-pro-v1.0.3-public-registry-install-replay-seal"
    assert data["seal_tag_target"] == "3174f958c45944b9c929f5a945532cac9f772edb"
    assert data["version_tag"] == "v1.0.3"
    assert data["version_tag_target"] == "d914996fc84c5370cfba57ee578ea0a06f74d7f3"
    assert data["npm_integrity"] == "sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ=="
    assert data["npm_shasum"] == "6a07a514bfcd91bb434314798334e5fb19959dfb"


def test_public_registry_install_replay_release_object_seal_script_passes():
    subprocess.run(
        ["bash", "scripts/public-registry-install-replay-release-object-seal.sh"],
        cwd=ROOT,
        check=True,
    )
