#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT="${OUT:-$(mktemp -d)}"
mkdir -p "$OUT"

printf "\n[MK10-PRO v1.0.3 AIRGAP AUDIT DIGEST LOCK]\n"

OUT="$OUT/offline-lock" bash scripts/offline-audit-lock.sh
OUT="$OUT/airgap-bundle" bash scripts/airgap-audit-bundle.sh
OUT="$OUT/airgap-negative-controls" bash scripts/airgap-audit-negative-controls.sh

node - <<'NODE'
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const child = require("child_process");

const ROOT = process.cwd();
const OUT = process.env.OUT || fs.mkdtempSync(path.join(require("os").tmpdir(), "mk10-pro-airgap-digest-"));
fs.mkdirSync(OUT, { recursive: true });

function fail(message) {
throw new Error(message);
}

function assert(condition, message) {
if (!condition) fail(message);
}

function readText(rel) {
return fs.readFileSync(path.join(ROOT, rel), "utf8");
}

function readJson(rel) {
return JSON.parse(readText(rel));
}

function sha256(rel) {
return crypto.createHash("sha256").update(fs.readFileSync(path.join(ROOT, rel))).digest("hex");
}

function bytes(rel) {
return fs.statSync(path.join(ROOT, rel)).size;
}

const contract = readJson("AIRGAP_AUDIT_DIGEST_LOCK.json");
assert(contract.version === "1.0.3", "contract version drift");
assert(contract.lock === "AIRGAP_AUDIT_DIGEST_LOCK", "contract lock drift");
assert(contract.digest_algorithm === "sha256", "digest algorithm drift");
assert(contract.network_after_checkout === "forbidden", "network boundary drift");
assert(contract.registry_lookup_required === false, "registry lookup enabled");
assert(contract.package_install_required === false, "package install enabled");
assert(contract.offline_replay_required === true, "offline replay disabled");
assert(contract.no_version_raise === true, "version raise allowed");
assert(contract.version_boundary.locked_version === "1.0.3", "locked version drift");
assert(contract.version_boundary.version_raise_allowed === false, "version raise boundary drift");

for (const lock of ["OFFLINE_AUDIT_LOCK", "AIRGAP_AUDIT_BUNDLE", "AIRGAP_AUDIT_NEGATIVE_CONTROLS"]) {
assert(contract.inherited_locks.includes(lock), `missing inherited lock ${lock}`);
}

const pkg = readJson(contract.npm_package_json);
assert(pkg.version === "1.0.3", `npm package version drift: ${pkg.version}`);
assert(readText("pyproject.toml").includes('version = "1.0.3"'), "pyproject version drift");

const requiredFiles = [...contract.required_files].sort();
for (const rel of requiredFiles) {
assert(fs.existsSync(path.join(ROOT, rel)), `missing required file ${rel}`);
assert(fs.statSync(path.join(ROOT, rel)).isFile(), `required path is not file ${rel}`);
}

function makeReceipt() {
return {
artifact: "MK10-PRO airgap audit digest lock",
version: "1.0.3",
lock: "AIRGAP_AUDIT_DIGEST_LOCK",
pass: true,
canonical_source: "repository checkout",
inherited_locks: [...contract.inherited_locks].sort(),
digest_algorithm: "sha256",
head: child.execSync("git rev-parse HEAD", { encoding: "utf8" }).trim(),
files: requiredFiles.map((rel) => ({
path: rel,
bytes: bytes(rel),
sha256: sha256(rel)
}))
};
}

function validateReceipt(receipt) {
assert(receipt && typeof receipt === "object", "receipt is not object");
assert(receipt.version === "1.0.3", "receipt version drift");
assert(receipt.lock === "AIRGAP_AUDIT_DIGEST_LOCK", "receipt lock drift");
assert(receipt.pass === true, "receipt pass flag drift");
assert(receipt.digest_algorithm === "sha256", "receipt digest algorithm drift");
assert(Array.isArray(receipt.files), "receipt files missing");

const map = new Map();
for (const entry of receipt.files) {
assert(entry && typeof entry === "object", "bad receipt file entry");
assert(typeof entry.path === "string", "receipt file path missing");
assert(typeof entry.sha256 === "string", `receipt sha missing ${entry.path}`);
assert(/^[0-9a-f]{64}$/.test(entry.sha256), `bad sha256 format ${entry.path}`);
map.set(entry.path, entry);
}

for (const rel of requiredFiles) {
const entry = map.get(rel);
assert(entry, `receipt missing ${rel}`);
assert(entry.bytes === bytes(rel), `receipt byte drift ${rel}`);
assert(entry.sha256 === sha256(rel), `receipt digest drift ${rel}`);
}

assert(map.size === requiredFiles.length, "receipt file cardinality drift");
}

const receipt = makeReceipt();
validateReceipt(receipt);

function clone(value) {
return JSON.parse(JSON.stringify(value));
}

function expectReject(name, mutate) {
const candidate = clone(receipt);
mutate(candidate);
let rejected = false;
try {
validateReceipt(candidate);
} catch {
rejected = true;
}
assert(rejected, `negative control failed open: ${name}`);
console.log(`negative_rejected ${name}`);
}

expectReject("receipt_version_raised", (r) => { r.version = "1.0.4"; });
expectReject("receipt_lock_changed", (r) => { r.lock = "AIRGAP_AUDIT_BUNDLE"; });
expectReject("receipt_digest_tampered", (r) => { r.files[0].sha256 = "0".repeat(64); });
expectReject("receipt_file_removed", (r) => { r.files.pop(); });

const receiptPath = path.join(OUT, contract.receipt_filename);
fs.writeFileSync(receiptPath, JSON.stringify(receipt, null, 2) + "\n");

console.log(`AIRGAP_AUDIT_DIGEST_LOCK_NODE_ASSERT: PASS files=${receipt.files.length}`);
console.log(`RECEIPT=${receiptPath}`);
NODE

printf "\nMK10-PRO v1.0.3 AIRGAP AUDIT DIGEST LOCK: PASS\n"
