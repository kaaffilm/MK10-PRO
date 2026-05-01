import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_public_replay_perimeter_files_exist():
    required = [
        "PACKAGE_SURFACES.json",
        "PUBLIC_SURFACE.md",
        "docs/PUBLIC_SURFACE_LOCK.md",
        "docs/PUBLIC_REPLAY_PERIMETER.md",
        "scripts/public-surface-proof.sh",
        "scripts/public-replay-proof.sh",
        "packages/npm/package.json",
        "packages/npm/PACKAGE_SURFACES.json",
    ]

    for path in required:
        assert (ROOT / path).exists(), path


def test_public_replay_perimeter_version_lock():
    surface = json.loads(read("PACKAGE_SURFACES.json"))
    npm_pkg = json.loads(read("packages/npm/package.json"))

    assert surface["name"] == "MK10-PRO"
    assert surface["version"] == "1.0.3"
    assert surface["version_lock"]["locked_version"] == "1.0.3"
    assert surface["version_lock"]["canonical_runtime_witness"] == "pypi"

    assert npm_pkg["name"] == "@kaaffilm/mk10-pro"
    assert npm_pkg["version"] == "1.0.3"

    assert surface["package_surfaces"]["pypi"]["package"] == "mk10-pro"
    assert surface["package_surfaces"]["npm"]["package"] == "@kaaffilm/mk10-pro"
    assert surface["package_surfaces"]["pkg"]["package"] == "@kaaffilm/mk10-pro"


def test_public_replay_perimeter_docs_state_boundary():
    combined = "\n".join(
        [
            read("README.md"),
            read("PUBLIC_SURFACE.md"),
            read("docs/PUBLIC_SURFACE_LOCK.md"),
            read("docs/PUBLIC_REPLAY_PERIMETER.md"),
        ]
    )

    assert "1.0.3" in combined
    assert "PyPI" in combined
    assert "NPM" in combined
    assert "PKG" in combined
    assert "canonical runtime witness" in combined
    assert "Do not raise" in combined or "do not raise" in combined
    assert "not canonical runtime witnesses" in combined or "not the canonical runtime witness" in combined


def test_public_replay_proof_script_passes():
    result = subprocess.run(
        ["bash", "scripts/public-replay-proof.sh"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )

    assert "MK10-PRO PUBLIC REPLAY PERIMETER: PASS" in result.stdout
