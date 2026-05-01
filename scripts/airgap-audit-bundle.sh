#!/usr/bin/env bash
set -euo pipefail

printf "\n[MK10-PRO v1.0.3 AIRGAP AUDIT BUNDLE]\n"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="${OUT:-/tmp/mk10-pro-airgap-audit-bundle}"
mkdir -p "$OUT"

node - <<'NODE'
const fs = require("fs");
const crypto = require("crypto");

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}
function must(cond, msg) {
  if (!cond) throw new Error(msg);
}
function exists(path) {
  must(fs.existsSync(path), `missing ${path}`);
}
function sha256(path) {
  return crypto.createHash("sha256").update(fs.readFileSync(path)).digest("hex");
}

const bundle = readJson("AIRGAP_AUDIT_BUNDLE.json");

must(bundle.version === "1.0.3", "bundle version drift");
must(bundle.no_version_raise === true, "bundle allows version raise");
must(bundle.network_after_checkout === "forbidden", "network not forbidden");
must(bundle.registry_lookup_required === false, "registry lookup required");
must(bundle.package_install_required === false, "package install required");
must(bundle.offline_replay_required === true, "offline replay not required");

const pkg = readJson("packages/npm/package.json");
must(pkg.version === "1.0.3", "npm package version drift");

const pyproject = fs.readFileSync("pyproject.toml", "utf8");
must(/version\s*=\s*"1\.0\.3"/.test(pyproject), "pyproject version drift");

for (const path of bundle.required_local_contracts) exists(path);
for (const path of bundle.required_entrypoints) exists(path);
for (const path of bundle.required_docs) exists(path);

const offline = readJson("OFFLINE_AUDIT_LOCK.json");
must(offline.version === "1.0.3", "offline lock version drift");
must(offline.no_version_raise === true, "offline lock weakened");
must(offline.network_after_checkout === "forbidden", "offline network boundary weakened");
must(offline.registry_lookup_required === false, "offline registry boundary weakened");
must(offline.package_install_required === false, "offline package boundary weakened");

const gate = readJson("EXTERNAL_AUDIT_GATE.json");
must(gate.version === "1.0.3", "external audit gate version drift");

const schema = readJson("AUDIT_RECEIPT_SCHEMA.json");
must(JSON.stringify(schema).includes("1.0.3"), "audit receipt schema not bound to 1.0.3");

const negative = readJson("AUDIT_RECEIPT_NEGATIVE_CASES.json");
must(JSON.stringify(negative).includes("version_raised"), "negative controls missing version raise rejection");
must(JSON.stringify(negative).includes("npm_promoted_to_canonical"), "negative controls missing npm canonical rejection");

const airgapScript = fs.readFileSync("scripts/airgap-audit-bundle.sh", "utf8");
for (const forbidden of bundle.forbidden_after_checkout) {
  if (airgapScript.includes(forbidden)) {
    throw new Error(`airgap verifier contains forbidden post-checkout verb: ${forbidden}`);
  }
}

const manifestPaths = [
  "AIRGAP_AUDIT_BUNDLE.json",
  "OFFLINE_AUDIT_LOCK.json",
  "EXTERNAL_AUDIT_GATE.json",
  "AUDIT_RECEIPT_SCHEMA.json",
  "AUDIT_RECEIPT_NEGATIVE_CASES.json",
  "pyproject.toml",
  "packages/npm/package.json",
  "README.md",
  "MANIFEST.in",
  ...bundle.required_entrypoints,
  ...bundle.required_docs,
  "docs/AIRGAP_AUDIT_BUNDLE.md"
];

const files = [...new Set(manifestPaths)].sort().map(path => ({
  path,
  sha256: sha256(path),
  bytes: fs.statSync(path).size
}));

const receipt = {
  artifact: "MK10-PRO airgap audit bundle receipt",
  version: "1.0.3",
  lock: "AIRGAP_AUDIT_BUNDLE_RECEIPT",
  canonical_source: "repository checkout",
  network_after_checkout: "forbidden",
  registry_lookup_required: false,
  package_install_required: false,
  files
};

const out = process.env.OUT || "/tmp/mk10-pro-airgap-audit-bundle";
fs.mkdirSync(out, { recursive: true });
fs.writeFileSync(`${out}/MK10_PRO_AIRGAP_AUDIT_BUNDLE_RECEIPT.json`, JSON.stringify(receipt, null, 2) + "\n");

console.log(`AIRGAP_AUDIT_BUNDLE_NODE_ASSERT: PASS files=${files.length}`);
NODE

bash scripts/offline-audit-lock.sh

printf "\nMK10-PRO v1.0.3 AIRGAP AUDIT BUNDLE: PASS\n"
printf "RECEIPT=%s\n" "$OUT/MK10_PRO_AIRGAP_AUDIT_BUNDLE_RECEIPT.json"
