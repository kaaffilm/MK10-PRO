import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_REMOTE_OUTSIDER_FINAL_REPLAY_WITNESS.json"
SCRIPT = ROOT / "scripts/public-registry-install-replay-remote-outsider-final-replay-witness.sh"


def test_remote_outsider_contract_shape():
    data = json.loads(CONTRACT.read_text())
    assert data["package"] == "@kaaffilm/mk10-pro"
    assert data["version"] == "1.0.3"
    assert data["public_registry_package"] == "@kaaffilm/mk10-pro@1.0.3"
    assert data["finality_tag"] == "mk10-pro-v1.0.3-public-registry-install-replay-finality-index-seal"
    assert data["finality_target"] == "420dce9d3c0b144117bfc8c0eee0b02a257939fd"
    assert data["base_replay_seal_target"] == "3174f958c45944b9c929f5a945532cac9f772edb"
    assert data["release_object_git_witness_target"] == "f5a5f1a31482f165267520d4f4ba19423c00cd3b"
    assert data["version_target"] == "d914996fc84c5370cfba57ee578ea0a06f74d7f3"
    assert data["mutation_boundary"]["repository_mutation"] is False
    assert data["mutation_boundary"]["package_registry_mutation"] is False
    assert data["mutation_boundary"]["release_mutation"] is False
    assert data["mutation_boundary"]["tag_rewrite"] is False


def test_script_static_surface():
    text = SCRIPT.read_text()
    forbidden = [
        "npm publish",
        "git push",
        "gh release create",
        "gh pr merge",
        "gh api repos/kaaffilm/MK10-PRO/statuses",
        "[https://",
        "](https://",
    ]
    for item in forbidden:
        assert item not in text


def test_script_static_replay(tmp_path):
    receipt = tmp_path / "receipt.json"
    env = os.environ.copy()
    env["RECEIPT_PATH"] = str(receipt)
    env.pop("REMOTE_OUTSIDER_LIVE_REPLAY", None)
    subprocess.run(["bash", str(SCRIPT)], cwd=ROOT, env=env, check=True)
    data = json.loads(receipt.read_text())
    assert data["pass"] is True
    assert data["witness"] == "remote_outsider_final_replay"
    assert data["finality_target"] == "420dce9d3c0b144117bfc8c0eee0b02a257939fd"
