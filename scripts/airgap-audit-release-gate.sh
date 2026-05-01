#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
OUT="${OUT:-$(mktemp -d)}"
mkdir -p "$OUT"

printf "\n[MK10-PRO v1.0.3 AIRGAP AUDIT RELEASE GATE]\n"

node - <<'NODE'
const fs = require("fs");

function fail(msg) { throw new Error(msg); }
function readJSON(path) { return JSON.parse(fs.readFileSync(path, "utf8")); }

const contract = readJSON("AIRGAP_AUDIT_RELEASE_GATE.json");
const pkg = readJSON("packages/npm/package.json");
const pyproject = fs.readFileSync("pyproject.toml", "utf8");

if (contract.version !== "1.0.3") fail("release gate version drift");
if (contract.lock !== "AIRGAP_AUDIT_RELEASE_GATE") fail("release gate lock drift");
if (contract.network_after_checkout !== "forbidden") fail("network boundary drift");
if (contract.registry_lookup_required !== false) fail("registry boundary drift");
if (contract.package_install_required !== false) fail("package install boundary drift");
if (contract.offline_replay_required !== true) fail("offline replay boundary drift");
if (contract.no_version_raise !== true) fail("version raise boundary drift");
if (contract.digest_algorithm !== "sha256") fail("digest algorithm drift");
if (contract.version_boundary.locked_version !== "1.0.3") fail("locked version drift");
if (contract.version_boundary.version_raise_allowed !== false) fail("version raise permission drift");
if (pkg.version !== "1.0.3") fail(`npm package version drift: ${pkg.version}`);
if (!pyproject.includes('version = "1.0.3"')) fail("pyproject version drift");

for (const lock of [
"OFFLINE_AUDIT_LOCK",
"AIRGAP_AUDIT_BUNDLE",
"AIRGAP_AUDIT_NEGATIVE_CONTROLS",
"AIRGAP_AUDIT_DIGEST_LOCK"
]) {
if (!contract.inherited_locks.includes(lock)) fail(`missing inherited lock: ${lock}`);
}

for (const path of contract.required_files) {
if (!fs.existsSync(path)) fail(`missing required file: ${path}`);
}

console.log("AIRGAP_AUDIT_RELEASE_GATE_CONTRACT_SHAPE: PASS");
NODE

OUT="$OUT/offline-lock" bash scripts/offline-audit-lock.sh
OUT="$OUT/airgap-bundle" bash scripts/airgap-audit-bundle.sh
OUT="$OUT/airgap-negative-controls" bash scripts/airgap-audit-negative-controls.sh
OUT="$OUT/airgap-digest-lock" bash scripts/airgap-audit-digest-lock.sh

OUT="$OUT" node - <<'NODE'
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

function fail(msg) { throw new Error(msg); }
function readJSON(p) { return JSON.parse(fs.readFileSync(p, "utf8")); }
function sha256(p) { return crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex"); }

const out = process.env.OUT;
const contract = readJSON("AIRGAP_AUDIT_RELEASE_GATE.json");

const nestedReceipts = [
"airgap-bundle/MK10_PRO_AIRGAP_AUDIT_BUNDLE_RECEIPT.json",
"airgap-digest-lock/MK10_PRO_AIRGAP_AUDIT_DIGEST_LOCK_RECEIPT.json"
];

for (const rel of nestedReceipts) {
const p = path.join(out, rel);
if (!fs.existsSync(p)) fail(`missing nested receipt: ${rel}`);
}

const files = contract.required_files.map((p) => ({
path: p,
bytes: fs.statSync(p).size,
sha256: sha256(p)
}));

const receipt = {
artifact: "MK10-PRO airgap audit release gate receipt",
version: "1.0.3",
lock: "AIRGAP_AUDIT_RELEASE_GATE",
pass: true,
digest_algorithm: "sha256",
network_after_checkout: "forbidden",
registry_lookup_required: false,
package_install_required: false,
offline_replay_required: true,
inherited_locks: contract.inherited_locks,
nested_receipts: nestedReceipts,
files
};

fs.writeFileSync(
path.join(out, "MK10_PRO_AIRGAP_AUDIT_RELEASE_GATE_RECEIPT.json"),
JSON.stringify(receipt, null, 2) + "\n"
);

console.log(`AIRGAP_AUDIT_RELEASE_GATE_NODE_ASSERT: PASS files=${files.length}`);
console.log(`RECEIPT=${path.join(out, "MK10_PRO_AIRGAP_AUDIT_RELEASE_GATE_RECEIPT.json")}`);
NODE

printf "\nMK10-PRO v1.0.3 AIRGAP AUDIT RELEASE GATE: PASS\n"
