#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash scripts/public-surface-proof.sh

node - <<'NODE'
const fs = require("fs");

const surface = JSON.parse(fs.readFileSync("PACKAGE_SURFACES.json", "utf8"));
const npmPkg = JSON.parse(fs.readFileSync("packages/npm/package.json", "utf8"));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(surface.name === "MK10-PRO", "surface name drift");
assert(surface.version === "1.0.3", "surface version drift");
assert(surface.version_lock.locked_version === "1.0.3", "version lock drift");
assert(surface.version_lock.canonical_runtime_witness === "pypi", "canonical witness drift");

assert(surface.package_surfaces.pypi.package === "mk10-pro", "PyPI package drift");
assert(surface.package_surfaces.npm.package === "@kaaffilm/mk10-pro", "NPM package drift");
assert(surface.package_surfaces.pkg.package === "@kaaffilm/mk10-pro", "PKG package drift");

assert(npmPkg.name === "@kaaffilm/mk10-pro", "npm name drift");
assert(npmPkg.version === "1.0.3", "npm version drift");

const docs = [
  "README.md",
  "PUBLIC_SURFACE.md",
  "docs/PUBLIC_SURFACE_LOCK.md",
  "docs/PUBLIC_REPLAY_PERIMETER.md",
].map((path) => fs.readFileSync(path, "utf8")).join("\n");

assert(docs.includes("1.0.3"), "docs missing 1.0.3");
assert(docs.includes("PyPI"), "docs missing PyPI");
assert(docs.includes("NPM"), "docs missing NPM");
assert(docs.includes("PKG"), "docs missing PKG");
assert(docs.toLowerCase().includes("do not raise"), "docs missing no-version-raise rule");
assert(docs.includes("canonical runtime witness"), "docs missing canonical runtime witness boundary");

console.log("PUBLIC_REPLAY_PERIMETER_NODE_ASSERT: PASS");
NODE

printf "\nMK10-PRO PUBLIC REPLAY PERIMETER: PASS\n"
