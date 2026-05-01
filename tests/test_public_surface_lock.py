from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCK = "1.0.3"


def read(path: str) -> str:
    return (ROOT / path).read_text()


def load_json(path: str) -> dict:
    return json.loads(read(path))


def assert_public_surface_lock() -> None:
    assert read("VERSION").strip() == LOCK

    package = load_json("packages/npm/package.json")
    surfaces = load_json("PACKAGE_SURFACES.json")

    assert package["name"] == "@kaaffilm/mk10-pro"
    assert package["version"] == LOCK
    assert package["private"] is False

    assert surfaces["name"] == "MK10-PRO"
    assert surfaces["version"] == LOCK
    assert surfaces["version_lock"]["locked_version"] == LOCK
    assert surfaces["version_lock"]["canonical_runtime_witness"] == "pypi"
    assert surfaces["version_lock"]["rule"] == "do_not_raise_public_package_version_to_repair_an_immutable_registry_artifact"

    assert surfaces["package_surfaces"]["pypi"]["package"] == "mk10-pro"
    assert surfaces["package_surfaces"]["pypi"]["role"] == "canonical runtime witness"
    assert surfaces["package_surfaces"]["npm"]["package"] == "@kaaffilm/mk10-pro"
    assert surfaces["package_surfaces"]["npm"]["runtime_boundary"] == "not_canonical_runtime_witness"
    assert surfaces["package_surfaces"]["pkg"]["package"] == "@kaaffilm/mk10-pro"
    assert surfaces["package_surfaces"]["pkg"]["runtime_boundary"] == "not_canonical_runtime_witness"

    readme = read("README.md")
    assert "No-version-raise package lock" in readme
    assert "MK10-PRO public package surfaces are locked at `1.0.3`." in readme
    assert "Do not raise the public package version" in readme
    assert "NPM and PKG remain public package surfaces" in readme

    public_surface = read("PUBLIC_SURFACE.md")
    public_lock = read("docs/PUBLIC_SURFACE_LOCK.md")

    assert "completion lock" in public_surface
    assert "completion lock" in public_lock
    assert "1.0.3" in public_surface
    assert "1.0.3" in public_lock
    assert "PyPI remains the canonical runtime witness" in public_surface
    assert "NPM and PKG are not canonical runtime witnesses" in public_lock


def test_public_surface_lock() -> None:
    assert_public_surface_lock()


if __name__ == "__main__":
    assert_public_surface_lock()
    print("MK10-PRO PUBLIC SURFACE LOCK TEST: PASS")
