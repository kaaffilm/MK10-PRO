import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_TERMINAL_CLOSURE_INDEX.json"
SCRIPT = ROOT / "scripts/public-registry-install-replay-terminal-closure-index.sh"

EXPECTED = {
    "package": "@kaaffilm/mk10-pro",
    "version": "1.0.3",
    "public_registry_package": "@kaaffilm/mk10-pro@1.0.3",
    "version_tag": "v1.0.3",
    "version_target": "d914996fc84c5370cfba57ee578ea0a06f74d7f3",
    "base_replay_seal_tag": "mk10-pro-v1.0.3-public-registry-install-replay-seal",
    "base_replay_seal_target": "3174f958c45944b9c929f5a945532cac9f772edb",
    "release_object_git_witness_tag": "mk10-pro-v1.0.3-public-registry-install-replay-release-object-git-witness-seal",
    "release_object_git_witness_target": "f5a5f1a31482f165267520d4f4ba19423c00cd3b",
    "finality_tag": "mk10-pro-v1.0.3-public-registry-install-replay-finality-index-seal",
    "finality_target": "420dce9d3c0b144117bfc8c0eee0b02a257939fd",
    "remote_outsider_tag": "mk10-pro-v1.0.3-public-registry-install-replay-remote-outsider-final-replay-witness-seal",
    "remote_outsider_target": "d83fa319b82c902d06582eef73589f7c4c9350fd",
    "npm_integrity": "sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ==",
    "npm_shasum": "6a07a514bfcd91bb434314798334e5fb19959dfb",
    "npm_tarball": "https://registry.npmjs.org/@kaaffilm/mk10-pro/-/mk10-pro-1.0.3.tgz",
}

def test_terminal_closure_contract_shape():
    data = json.loads(CONTRACT.read_text())
    encoded = json.dumps(data, sort_keys=True)

    for key, expected in EXPECTED.items():
        if key in data:
            assert data[key] == expected
        else:
            assert expected in encoded

    mutation_boundary = data.get("mutation_boundary", {})
    for key in ("repository_mutation", "package_registry_mutation", "release_mutation", "tag_rewrite"):
        if key in mutation_boundary:
            assert mutation_boundary[key] is False

def test_terminal_closure_script_static_surface():
    text = SCRIPT.read_text()

    forbidden = [
        "npm publish",
        "git push",
        "gh release create",
        "gh pr merge",
        "gh api repos/kaaffilm/MK10-PRO/statuses",
        "[https://registry.npmjs.org",
    ]

    for item in forbidden:
        assert item not in text

    assert "https://registry.npmjs.org/@kaaffilm/mk10-pro/-/mk10-pro-1.0.3.tgz" in text

def test_terminal_closure_static_replay(tmp_path):
    receipt = tmp_path / "receipt.json"
    env = os.environ.copy()
    env["RECEIPT_PATH"] = str(receipt)
    env.pop("TERMINAL_CLOSURE_LIVE_REPLAY", None)
    env.pop("REMOTE_OUTSIDER_LIVE_REPLAY", None)

    subprocess.run(["bash", str(SCRIPT)], cwd=ROOT, env=env, check=True)

    data = json.loads(receipt.read_text())
    assert data["pass"] is True
    assert "terminal" in json.dumps(data).lower()
