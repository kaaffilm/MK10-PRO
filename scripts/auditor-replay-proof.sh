#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

TMP="${TMPDIR:-/tmp}/mk10-auditor-replay-$$"
trap 'rm -rf "$TMP" build dist mk10_pro.egg-info .pytest_cache' EXIT
mkdir -p "$TMP"

python3 -m venv "$TMP/venv"
. "$TMP/venv/bin/activate"

python -m pip install --upgrade pip >/dev/null
python -m pip install pytest pyyaml build >/dev/null
python -m pip install -e . >/dev/null

python - <<'PY'
import json
from pathlib import Path

root = Path(".")
surface = json.loads((root / "PACKAGE_SURFACES.json").read_text())
pkg = json.loads((root / "packages/npm/package.json").read_text())

assert (root / "AUDITOR_START_HERE.md").is_file()
assert (root / "docs/AUDITOR_REPLAY.md").is_file()
assert (root / "docs/PUBLIC_REPLAY_PERIMETER.md").is_file()
assert (root / "PUBLIC_SURFACE.md").is_file()

assert (root / "VERSION").read_text().strip() == "1.0.3"
assert surface["version"] == "1.0.3"
assert surface["version_lock"]["locked_version"] == "1.0.3"
assert surface["version_lock"]["canonical_runtime_witness"] == "pypi"
assert pkg["name"] == "@kaaffilm/mk10-pro"
assert pkg["version"] == "1.0.3"

readme = (root / "README.md").read_text()
assert "Do not raise the public package version" in readme
assert "public replay perimeter" in readme.lower()

print("AUDITOR_REPLAY_STATIC_ASSERT: PASS")
PY

python -m cli.surface >/dev/null
mk10 proof >/dev/null
mk10 boundary >/dev/null

python -m pytest -q \
  tests/test_public_surface_lock.py \
  tests/test_public_replay_perimeter.py \
  tests/test_auditor_entrypoint.py

bash scripts/public-surface-proof.sh
bash scripts/public-replay-proof.sh

python -m build >/dev/null

if command -v npm >/dev/null 2>&1; then
  (
    cd packages/npm
    npm test
    npm pack --dry-run >/dev/null
  )
  echo "AUDITOR_REPLAY_NPM_ASSERT: PASS"
else
  echo "AUDITOR_REPLAY_NPM_ASSERT: SKIP_NO_NPM"
fi

if [ "${MK10_AUDITOR_LIVE:-0}" = "1" ]; then
  NPM_REGISTRY="https://registry.npmjs.org/"
  NPM_VERSION="$(npm view @kaaffilm/mk10-pro@1.0.3 version --registry "$NPM_REGISTRY" 2>/dev/null || true)"
  test "$NPM_VERSION" = "1.0.3"

  PYPI_INDEX="$(python -m pip index versions mk10-pro 2>/dev/null || true)"
  case "$PYPI_INDEX" in
    *"mk10-pro (1.0.3)"*) ;;
    *) echo "$PYPI_INDEX"; exit 1 ;;
  esac

  echo "AUDITOR_REPLAY_LIVE_ASSERT: PASS"
fi

echo
echo "MK10-PRO v1.0.3 AUDITOR REPLAY: PASS"
