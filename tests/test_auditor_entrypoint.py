import json
import subprocess
from pathlib import Path

ROOT = Path.cwd().resolve()


def test_auditor_entrypoint_files_exist():
    required = [
        "AUDITOR_START_HERE.md",
        "docs/AUDITOR_REPLAY.md",
        "scripts/auditor-replay-proof.sh",
        "docs/PUBLIC_REPLAY_PERIMETER.md",
        "PUBLIC_SURFACE.md",
        "PACKAGE_SURFACES.json",
    ]
    for rel in required:
        assert (ROOT / rel).is_file(), rel


def test_auditor_entrypoint_version_lock():
    surface = json.loads((ROOT / "PACKAGE_SURFACES.json").read_text())
    npm = json.loads((ROOT / "packages/npm/package.json").read_text())

    assert (ROOT / "VERSION").read_text().strip() == "1.0.3"
    assert surface["version"] == "1.0.3"
    assert surface["version_lock"]["locked_version"] == "1.0.3"
    assert surface["version_lock"]["canonical_runtime_witness"] == "pypi"
    assert npm["version"] == "1.0.3"


def test_auditor_docs_are_bounded():
    text = "\n".join(
        [
            (ROOT / "AUDITOR_START_HERE.md").read_text(),
            (ROOT / "docs/AUDITOR_REPLAY.md").read_text(),
        ]
    )

    assert "do not raise the public package version" in text.lower()
    assert "mk10-pro==1.0.3" in text
    assert "@kaaffilm/mk10-pro@1.0.3" in text
    assert "does not verify playback" in text.lower()


def test_auditor_replay_script_syntax():
    subprocess.run(
        ["bash", "-n", str(ROOT / "scripts/auditor-replay-proof.sh")],
        check=True,
        cwd=ROOT,
    )
