#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

printf "\n[MK10-PRO PUBLIC SURFACE PROOF]\n"

test "$(cat VERSION)" = "1.0.3"
test -f PACKAGE_SURFACES.json
test -f PUBLIC_SURFACE.md
test -f docs/PUBLIC_SURFACE_LOCK.md
test -f docs/PACKAGE_SURFACES.md
test -f docs/NPM_BOUNDARY.md
test -f docs/PKG_BOUNDARY.md
test -f PYPI_RELEASE_POLICY.md
test ! -f PYPI_DISABLED

python3 tests/test_public_surface_lock.py

node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("packages/npm/package.json", "utf8"));
const surfaces = JSON.parse(fs.readFileSync("PACKAGE_SURFACES.json", "utf8"));

if (pkg.version !== "1.0.3") throw new Error("npm version drift");
if (surfaces.version !== "1.0.3") throw new Error("surface version drift");
if (surfaces.version_lock.locked_version !== "1.0.3") throw new Error("version lock drift");
if (surfaces.version_lock.canonical_runtime_witness !== "pypi") throw new Error("canonical witness drift");

console.log("NODE_PACKAGE_SURFACE_LOCK: PASS");
NODE

if [ "${MK10_PRO_SKIP_LIVE:-0}" != "1" ]; then
  npm view @kaaffilm/mk10-pro@1.0.3 version --registry https://registry.npmjs.org/
  python3 -m pip index versions mk10-pro | grep -q "mk10-pro (1.0.3)"
fi

printf "\nMK10-PRO PUBLIC SURFACE PROOF: PASS\n"
