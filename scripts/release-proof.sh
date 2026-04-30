#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${TMPDIR:-/tmp}/mk10-pro-release-proof-$STAMP"
VENV="$OUT/venv"

mkdir -p "$OUT"
cd "$ROOT"

printf "\n[MK10-PRO RELEASE PROOF]\n"
printf "ROOT=%s\n" "$ROOT"
printf "OUT=%s\n" "$OUT"

printf "\n[RELEASE POLICY]\n"
test -f PYPI_RELEASE_POLICY.md
test ! -f PYPI_DISABLED
test -f .github/workflows/publish.yml
! git grep -nE 'twine upload|password:|TWINE_PASSWORD|__token__' -- . ':!PYPI_RELEASE_POLICY.md'

printf "\n[METADATA]\n"
python3 - <<'PY'
from pathlib import Path
import json
import re

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib

project = tomllib.loads(Path("pyproject.toml").read_text())["project"]
facts = {
    "name": project["name"],
    "version": project["version"],
    "license": project.get("license"),
    "version_file": Path("VERSION").read_text().strip(),
    "engine_version": re.search(r'__version__\s*=\s*"([^"]+)"', Path("engine/__init__.py").read_text()).group(1),
    "cli_version": re.search(r'version="([^"]+)"', Path("cli/mk10.py").read_text()).group(1),
}
print(json.dumps(facts, indent=2, sort_keys=True))
assert facts["name"] == "mk10-pro"
assert facts["version"] == facts["version_file"] == facts["engine_version"] == facts["cli_version"]
assert facts["license"] == "Apache-2.0"
PY

printf "\n[CHECKSUM]\n"
python3 - <<'PY'
from pathlib import Path
import hashlib
import json

digest = hashlib.sha256(Path("FAILURE_CODES.json").read_bytes()).hexdigest()
declared = Path(".failure_codes_checksum").read_text().strip()
print("failure_codes_sha256", digest)
assert digest == declared
json.loads(Path("FAILURE_CODES.json").read_text())
PY

printf "\n[VERIFY ENV]\n"
python3 -m venv "$VENV"
. "$VENV/bin/activate"
python -m pip install --upgrade pip setuptools wheel build pytest tomli click pyyaml jsonschema cryptography xmlschema >/dev/null

printf "\n[SOURCE COMMANDS]\n"
python -m cli --version
python -m cli proof
python -m cli boundary
python -m cli witness --out "$OUT/source-witness"

printf "\n[TESTS]\n"
PYTHONDONTWRITEBYTECODE=1 python -m pytest -q

printf "\n[BUILD]\n"
mkdir -p "$OUT/dist"
python -m build --sdist --wheel --outdir "$OUT/dist" >/dev/null

printf "\n[PACKAGE CONTENT]\n"
python - <<PY
from pathlib import Path
import hashlib
import tarfile
import zipfile

dist = Path("$OUT/dist")
required_sdist = [
    "README.md",
    "USER_START_HERE.md",
    "QUICKSTART.md",
    "REPRODUCIBILITY.md",
    "PYPI_RELEASE_POLICY.md",
    "VERSION",
    "MANIFEST.in",
    "docs/WITNESS_RELEASE.md",
    "docs/PYPI_BOUNDARY.md",
    "mtb/schema/mtb.schema.json",
    "engine/policy/policy_pack.yaml",
]
required_wheel = [
    "cli/surface.py",
    "mtb/schema/mtb.schema.json",
    "engine/policy/policy_pack.yaml",
    "engine/formats/dcp/rules.yaml",
]

for p in sorted(dist.iterdir()):
    print(p.name, p.stat().st_size, hashlib.sha256(p.read_bytes()).hexdigest())
    if p.name.endswith(".tar.gz"):
        with tarfile.open(p) as t:
            names = t.getnames()
            for must in required_sdist:
                assert any(n.endswith(must) for n in names), must
    if p.name.endswith(".whl"):
        with zipfile.ZipFile(p) as z:
            names = z.namelist()
            for must in required_wheel:
                assert must in names, must
            metadata = [n for n in names if n.endswith(".dist-info/METADATA")][0]
            meta = z.read(metadata).decode()
            assert "Apache-2.0" in meta
PY

printf "\n[INSTALLED WHEEL]\n"
INSTALL="$OUT/install"
python3 -m venv "$INSTALL"
. "$INSTALL/bin/activate"
python -m pip install --upgrade pip >/dev/null
python -m pip install "$OUT/dist/"*.whl >/dev/null
mk10 proof
mk10 boundary
mk10 witness --out "$OUT/installed-witness"

printf "\n[JUNK CLEAN]\n"
cd "$ROOT"
rm -rf .pytest_cache build dist mk10_pro.egg-info .mypy_cache .ruff_cache .tox .nox htmlcov .coverage .coverage.*
find . -path ./.git -prune -o -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

find . -path ./.git -prune -o \( \
  -name "__pycache__" -o \
  -name ".pytest_cache" -o \
  -name ".mypy_cache" -o \
  -name ".ruff_cache" -o \
  -name ".tox" -o \
  -name ".nox" -o \
  -name "htmlcov" -o \
  -name "build" -o \
  -name "dist" -o \
  -name "*.egg-info" \
\) -print > "$OUT/junk.txt"

test ! -s "$OUT/junk.txt"

printf "\nMK10-PRO RELEASE PROOF: PASS\n"
printf "OUT=%s\n" "$OUT"
