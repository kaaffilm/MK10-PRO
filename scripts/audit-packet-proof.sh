#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

printf "\n[MK10-PRO AUDIT PACKET PROOF]\n"

test "$(cat VERSION)" = "1.0.3"
test -f AUDIT_PACKET.md
test -f docs/AUDIT_PACKET.md
test -f AUDITOR_START_HERE.md
test -f docs/AUDITOR_REPLAY.md
test -f PUBLIC_SURFACE.md
test -f docs/PUBLIC_SURFACE_LOCK.md
test -f docs/PUBLIC_REPLAY_PERIMETER.md
test -f PACKAGE_SURFACES.json
test -f packages/npm/package.json
test -f scripts/public-surface-proof.sh
test -f scripts/public-replay-proof.sh
test -f scripts/auditor-replay-proof.sh

node - <<'NODE'
const fs = require("fs");

const surface = JSON.parse(fs.readFileSync("PACKAGE_SURFACES.json", "utf8"));
const pkg = JSON.parse(fs.readFileSync("packages/npm/package.json", "utf8"));

if (surface.version !== "1.0.3") throw new Error("surface version drift");
if (!surface.version_lock) throw new Error("missing version_lock");
if (surface.version_lock.locked_version !== "1.0.3") throw new Error("version lock drift");
if (surface.version_lock.canonical_runtime_witness !== "pypi") throw new Error("canonical witness drift");
if (surface.package_surfaces.pypi.role !== "canonical runtime witness") throw new Error("pypi role drift");
if (surface.package_surfaces.npm.runtime_boundary !== "not_canonical_runtime_witness") throw new Error("npm boundary drift");
if (surface.package_surfaces.pkg.runtime_boundary !== "not_canonical_runtime_witness") throw new Error("pkg boundary drift");
if (pkg.version !== "1.0.3") throw new Error("npm version drift");

const audit = fs.readFileSync("AUDIT_PACKET.md", "utf8");
for (const needle of [
  "MK10-PRO v1.0.3 External Audit Packet",
  "Do not raise the public package version",
  "PyPI",
  "NPM",
  "PKG",
  "scripts/audit-packet-proof.sh"
]) {
  if (!audit.includes(needle)) throw new Error(`missing audit packet text: ${needle}`);
}

console.log("AUDIT_PACKET_NODE_ASSERT: PASS");
NODE

bash scripts/public-surface-proof.sh
bash scripts/public-replay-proof.sh
bash scripts/auditor-replay-proof.sh

printf "\nMK10-PRO v1.0.3 EXTERNAL AUDIT PACKET: PASS\n"
