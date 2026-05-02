from pathlib import Path
import json
import os
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.json"
DOC = ROOT / "docs" / "PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.md"
SCRIPT = ROOT / "scripts" / "public-registry-install-replay-finality-index.sh"
WORKFLOW = ROOT / ".github" / "workflows" / "public-registry-install-replay-finality-index.yml"


def test_public_registry_install_replay_finality_index_files_exist():
    for path in (CONTRACT, DOC, SCRIPT, WORKFLOW):
        assert path.exists(), path


def test_public_registry_install_replay_finality_index_contract_shape_static():
    data = json.loads(CONTRACT.read_text())

    assert data.get("package") == "@kaaffilm/mk10-pro"
    assert data.get("version") == "1.0.3"
    assert data.get("version_tag") == "v1.0.3"
    assert data.get("public_registry_package") == "@kaaffilm/mk10-pro@1.0.3"

    assert data.get("base_seal_tag") == "mk10-pro-v1.0.3-public-registry-install-replay-seal"
    assert data.get("release_object_git_witness_tag") == (
        "mk10-pro-v1.0.3-public-registry-install-replay-release-object-git-witness-seal"
    )

    assert data.get("npm_integrity") == (
        "sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ=="
    )
    assert data.get("npm_shasum") == "6a07a514bfcd91bb434314798334e5fb19959dfb"
    assert data.get("npm_tarball") == "https://registry.npmjs.org/@kaaffilm/mk10-pro/-/mk10-pro-1.0.3.tgz"

    forbidden = set(data.get("forbidden_behaviors") or data.get("forbidden_boundary") or [])
    assert {"npm publish", "registry write", "tag mutation", "release mutation"} <= forbidden


def test_public_registry_install_replay_finality_index_script_static_surface():
    text = SCRIPT.read_text()

    assert "PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX_CONTRACT_SHAPE: PASS" in text
    assert "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY FINALITY INDEX: PASS" in text

    executable_forbidden_patterns = [
        r"(?m)^\s*npm\s+publish\b",
        r"(?m)^\s*twine\s+upload\b",
        r"(?m)^\s*git\s+push\b",
        r"(?m)^\s*git\s+tag\b",
        r"(?m)^\s*gh\s+release\s+(create|edit|delete|upload)\b",
    ]
    for pattern in executable_forbidden_patterns:
        assert re.search(pattern, text) is None, pattern


def test_public_registry_install_replay_finality_index_workflow_static_surface():
    text = WORKFLOW.read_text()
    assert "MK10_PRO_LIVE_FINALITY_INDEX: \"1\"" in text
    assert "bash scripts/public-registry-install-replay-finality-index.sh" in text
    assert "MK10_PRO_PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX_RECEIPT.json" in text


def test_public_registry_install_replay_finality_index_live_only_when_explicit():
    if os.environ.get("MK10_PRO_LIVE_FINALITY_INDEX") != "1":
        return

    result = subprocess.run(
        ["bash", str(SCRIPT)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    assert "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY FINALITY INDEX: PASS" in result.stdout
