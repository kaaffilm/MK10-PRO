#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

printf "\n[MK10-PRO PUBLIC SURFACE PROOF]\n"

node - <<'NODE'
const fs = require("fs");

function read(path) {
  return fs.readFileSync(path, "utf8");
}

function json(path) {
  return JSON.parse(read(path));
}

const surface = json("PACKAGE_SURFACES.json");
const pkg = json("packages/npm/package.json");

if (surface.name !== "MK10-PRO") throw new Error("wrong surface name");
if (surface.version !== "1.0.3") throw new Error("wrong public surface version");
if (surface.version_lock.locked_version !== "1.0.3") throw new Error("wrong locked version");
if (surface.version_lock.canonical_runtime_witness !== "pypi") throw new Error("wrong canonical runtime witness");

if (surface.package_surfaces.pypi.package !== "mk10-pro") throw new Error("wrong PyPI package");
if (surface.package_surfaces.pypi.role !== "canonical runtime witness") throw new Error("PyPI must remain canonical runtime witness");
if (surface.package_surfaces.npm.package !== "@kaaffilm/mk10-pro") throw new Error("wrong NPM package");
if (surface.package_surfaces.npm.runtime_boundary !== "not_canonical_runtime_witness") throw new Error("NPM runtime boundary drift");
if (surface.package_surfaces.pkg.package !== "@kaaffilm/mk10-pro") throw new Error("wrong PKG package");
if (surface.package_surfaces.pkg.runtime_boundary !== "not_canonical_runtime_witness") throw new Error("PKG runtime boundary drift");

if (pkg.name !== "@kaaffilm/mk10-pro") throw new Error("wrong npm package name");
if (pkg.version !== "1.0.3") throw new Error("wrong npm package version");
if (!pkg.bin || pkg.bin["mk10-pro"] !== "bin/mk10-pro.js") throw new Error("wrong npm bin");
if (pkg.private !== false) throw new Error("npm package must be public");
if (!pkg.publishConfig || pkg.publishConfig.access !== "public") throw new Error("wrong npm access");

const required = [
  "README.md",
  "PUBLIC_SURFACE.md",
  "docs/PUBLIC_SURFACE_LOCK.md",
  "docs/PUBLIC_REPLAY_PERIMETER.md",
  "packages/npm/README.md"
];

for (const path of required) {
  if (!fs.existsSync(path)) throw new Error(`missing ${path}`);
  const text = read(path);
  if (!text.includes("1.0.3")) throw new Error(`${path} missing 1.0.3`);
  if (text.includes("1.0.4")) throw new Error(`${path} contains forbidden 1.0.4`);
}

console.log("MK10-PRO PUBLIC SURFACE LOCK TEST: PASS");
console.log("NODE_PACKAGE_SURFACE_LOCK: PASS");
NODE

printf "\nMK10-PRO PUBLIC SURFACE PROOF: PASS\n"
