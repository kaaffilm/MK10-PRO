import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def test_public_registry_install_replay_finality_index_files_exist():
    assert (ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.json").is_file()
    assert (ROOT / "docs/PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.md").is_file()
    assert (ROOT / "scripts/public-registry-install-replay-finality-index.sh").is_file()

def test_public_registry_install_replay_finality_index_contract_shape():
    data = json.loads((ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.json").read_text())
    assert data["version"] == "1.0.3"
    assert data["package"] == "@kaaffilm/mk10-pro"
    assert data["repository"] == "kaaffilm/MK10-PRO"
    assert data["version_tag"] == "v1.0.3"
    assert data["version_tag_target"] == "d914996fc84c5370cfba57ee578ea0a06f74d7f3"
    assert data["base_seal_target"] == "3174f958c45944b9c929f5a945532cac9f772edb"
    assert data["release_object_git_witness_target"] == "f5a5f1a31482f165267520d4f4ba19423c00cd3b"
    assert data["npm_integrity"].startswith("sha512-")
    assert data["npm_shasum"] == "6a07a514bfcd91bb434314798334e5fb19959dfb"
    encoded = json.dumps(data, sort_keys=True).lower()
    assert "npm publish" in encoded
    assert "registry write" in encoded
    assert "tag mutation" in encoded
    assert "release mutation" in encoded

def test_public_registry_install_replay_finality_index_script_static_boundary():
    script = (ROOT / "scripts/public-registry-install-replay-finality-index.sh").read_text()
    assert "npm view" in script
    assert "gh release view" in script
    assert "gh pr view 33" in script
    assert "gh pr view 34" in script
    assert "npm publish" not in script.replace('"npm publish"', "")
    assert "gh release create" not in script
    assert "git tag -a" not in script
    assert "git push origin" not in script

def test_public_registry_install_replay_finality_index_live_only_when_explicit():
    if os.environ.get("LIVE_PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX") != "1":
        return
    subprocess.run(
        ["bash", "scripts/public-registry-install-replay-finality-index.sh"],
        cwd=ROOT,
        check=True,
    )
