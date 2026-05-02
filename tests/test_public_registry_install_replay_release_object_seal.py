import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.json"
DOC = ROOT / "docs" / "PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.md"
SCRIPT = ROOT / "scripts" / "public-registry-install-replay-release-object-seal.sh"
WORKFLOW = ROOT / ".github" / "workflows" / "public-registry-install-replay-release-object-seal.yml"

EXPECTED_HEAD = "3174f958c45944b9c929f5a945532cac9f772edb"
EXPECTED_VERSION_TAG = "v1.0.3"
EXPECTED_RELEASE_TAG = "mk10-pro-v1.0.3-public-registry-install-replay-seal"
EXPECTED_PACKAGE = "@kaaffilm/mk10-pro"
EXPECTED_VERSION = "1.0.3"
EXPECTED_INTEGRITY = "sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ=="


def test_public_registry_install_replay_release_object_seal_files_exist():
    for path in (CONTRACT, DOC, SCRIPT, WORKFLOW):
        assert path.exists(), path
    assert os.access(SCRIPT, os.X_OK)


def test_public_registry_install_replay_release_object_seal_contract_shape():
    data = json.loads(CONTRACT.read_text())
    encoded = json.dumps(data, sort_keys=True)

    for token in (
        EXPECTED_HEAD,
        EXPECTED_VERSION_TAG,
        EXPECTED_RELEASE_TAG,
        EXPECTED_PACKAGE,
        EXPECTED_VERSION,
        EXPECTED_INTEGRITY,
    ):
        assert token in encoded


def test_public_registry_install_replay_release_object_seal_script_syntax():
    subprocess.run(["bash", "-n", str(SCRIPT)], cwd=ROOT, check=True)


def test_public_registry_install_replay_release_object_seal_live_optional():
    if os.environ.get("MK10_PRO_LIVE_WITNESS_ASSERT") != "1":
        return

    subprocess.run(["bash", str(SCRIPT)], cwd=ROOT, check=True)
