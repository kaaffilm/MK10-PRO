#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

ROOT="$(pwd)"
SEAL_OUT="${OUT:-$(mktemp -d /tmp/mk10-pro-public-release-seal.XXXXXX)}"
mkdir -p "$SEAL_OUT"

printf "\n[MK10-PRO v1.0.3 PUBLIC RELEASE SEAL]\n"

node - <<'NODE'
const fs = require("fs");
const path = require("path");

function read(rel) {
  return fs.readFileSync(path.join(process.cwd(), rel), "utf8");
}
function parse(rel) {
  return JSON.parse(read(rel));
}
const seal = parse("PUBLIC_RELEASE_SEAL.json");
const index = parse("RELEASE_INDEX.json");
const pkg = parse("packages/npm/package.json");
if (seal.package_version !== "1.0.3") throw new Error("public release seal version drift");
if (index.package_version !== "1.0.3") throw new Error("release index version drift");
if (pkg.version !== "1.0.3") throw new Error("npm package version drift");
if (seal.package_mutation !== "forbidden") throw new Error("seal must forbid package mutation");
if (seal.feature_surface_mutation !== "forbidden") throw new Error("seal must forbid feature surface mutation");
if (!seal.requires_release_gate) throw new Error("seal must require release gate");
if (!index.required_verifiers.some((v) => v.name === "airgap audit release gate")) throw new Error("release index missing release gate");
if (!index.required_verifiers.some((v) => v.name === "public release seal")) throw new Error("release index missing public release seal");
for (const rel of seal.required_files) {
  if (!fs.existsSync(path.join(process.cwd(), rel))) throw new Error(`required file missing: ${rel}`);
}
for (const rel of index.required_files) {
  if (!fs.existsSync(path.join(process.cwd(), rel))) throw new Error(`index file missing: ${rel}`);
}
console.log("PUBLIC_RELEASE_SEAL_CONTRACT_SHAPE: PASS");
NODE

GATE_OUT="$SEAL_OUT/airgap-release-gate"
mkdir -p "$GATE_OUT"
OUT="$GATE_OUT" bash scripts/airgap-audit-release-gate.sh

GATE_RECEIPT="$(find "$GATE_OUT" -name MK10_PRO_AIRGAP_AUDIT_RELEASE_GATE_RECEIPT.json -print -quit)"
test -n "$GATE_RECEIPT"
test -f "$GATE_RECEIPT"

OUT="$SEAL_OUT" GATE_RECEIPT="$GATE_RECEIPT" node - <<'NODE'
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const root = process.cwd();
const out = process.env.OUT;
const gateReceipt = process.env.GATE_RECEIPT;

function disk(rel) {
  return fs.readFileSync(path.join(root, rel), "utf8");
}
function read(rel, overrides = {}) {
  if (Object.prototype.hasOwnProperty.call(overrides, rel)) {
    const value = overrides[rel];
    if (value === null) throw new Error(`required file missing: ${rel}`);
    return value;
  }
  return disk(rel);
}
function parse(rel, overrides = {}) {
  return JSON.parse(read(rel, overrides));
}
function sha256Text(text) {
  return crypto.createHash("sha256").update(text).digest("hex");
}
function sha256File(abs) {
  return crypto.createHash("sha256").update(fs.readFileSync(abs)).digest("hex");
}
function requireIncludes(rel, needle, overrides = {}) {
  const text = read(rel, overrides);
  if (!text.includes(needle)) throw new Error(`${rel} missing required text: ${needle}`);
}
function assertTree(overrides = {}) {
  const seal = parse("PUBLIC_RELEASE_SEAL.json", overrides);
  const index = parse("RELEASE_INDEX.json", overrides);
  const pkg = parse("packages/npm/package.json", overrides);
  const py = read("pyproject.toml", overrides);
  const manifest = read("MANIFEST.in", overrides);
  const readme = read("README.md", overrides);

  if (pkg.version !== "1.0.3") throw new Error(`npm package version drift: ${pkg.version}`);
  if (!/version\s*=\s*"1\.0\.3"/.test(py)) throw new Error("pyproject version drift");
  if (seal.package_version !== "1.0.3") throw new Error("public release seal version drift");
  if (index.package_version !== "1.0.3") throw new Error("release index version drift");
  if (seal.release !== "v1.0.3") throw new Error("seal release drift");
  if (index.release !== "v1.0.3") throw new Error("index release drift");
  if (seal.package_mutation !== "forbidden") throw new Error("package mutation must be forbidden");
  if (seal.feature_surface_mutation !== "forbidden") throw new Error("feature surface mutation must be forbidden");
  if (seal.network_after_checkout !== "forbidden") throw new Error("network-after-checkout must be forbidden");
  if (!seal.requires_release_gate) throw new Error("release gate must be required");
  if (!seal.requires_airgap_digest_lock) throw new Error("digest lock must be required");
  if (!seal.requires_airgap_negative_controls) throw new Error("negative controls must be required");
  if (!seal.requires_airgap_bundle) throw new Error("bundle must be required");
  if (!seal.requires_offline_audit_lock) throw new Error("offline lock must be required");

  const verifierNames = new Set(index.required_verifiers.map((v) => v.name));
  for (const name of [
    "offline audit lock",
    "airgap audit bundle",
    "airgap audit negative controls",
    "airgap audit digest lock",
    "airgap audit release gate",
    "public release seal"
  ]) {
    if (!verifierNames.has(name)) throw new Error(`release index missing verifier: ${name}`);
  }

  for (const rel of seal.required_files) read(rel, overrides);
  for (const rel of index.required_files) read(rel, overrides);

  requireIncludes(".github/workflows/public-release-seal.yml", "bash scripts/public-release-seal.sh", overrides);
  requireIncludes(".github/workflows/airgap-audit-release-gate.yml", "bash scripts/airgap-audit-release-gate.sh", overrides);

  for (const rel of [
    "PUBLIC_RELEASE_SEAL.json",
    "RELEASE_INDEX.json",
    "docs/PUBLIC_RELEASE_SEAL.md",
    "docs/RELEASE_INDEX.md",
    "scripts/public-release-seal.sh"
  ]) {
    if (!manifest.includes(rel)) throw new Error(`MANIFEST missing ${rel}`);
  }

  if (!readme.toLowerCase().includes("public release seal")) throw new Error("README missing public release seal");
  if (!readme.includes("RELEASE_INDEX.json")) throw new Error("README missing RELEASE_INDEX.json");

  return { seal, index };
}

function assertReject(name, overrides) {
  let rejected = false;
  try {
    assertTree(overrides);
  } catch {
    rejected = true;
  }
  if (!rejected) throw new Error(`negative control did not reject: ${name}`);
  console.log(`negative_rejected ${name}`);
}

const current = assertTree();

const pkgRaised = JSON.parse(disk("packages/npm/package.json"));
pkgRaised.version = "1.0.4";

const sealRaised = JSON.parse(disk("PUBLIC_RELEASE_SEAL.json"));
sealRaised.package_version = "1.0.4";

const indexMissingGate = JSON.parse(disk("RELEASE_INDEX.json"));
indexMissingGate.required_verifiers = indexMissingGate.required_verifiers.filter((v) => v.name !== "airgap audit release gate");

const manifestMissingSeal = disk("MANIFEST.in")
  .split(/\r?\n/)
  .filter((line) => !line.includes("PUBLIC_RELEASE_SEAL.json"))
  .join("\n");

assertReject("public_release_seal_removed", { "PUBLIC_RELEASE_SEAL.json": null });
assertReject("release_index_removed", { "RELEASE_INDEX.json": null });
assertReject("npm_package_version_raised", { "packages/npm/package.json": JSON.stringify(pkgRaised, null, 2) });
assertReject("public_release_seal_version_raised", { "PUBLIC_RELEASE_SEAL.json": JSON.stringify(sealRaised, null, 2) });
assertReject("release_gate_contract_removed", { "AIRGAP_AUDIT_RELEASE_GATE.json": null });
assertReject("release_gate_script_removed", { "scripts/airgap-audit-release-gate.sh": null });
assertReject("public_release_seal_workflow_removed", { ".github/workflows/public-release-seal.yml": null });
assertReject("index_missing_release_gate", { "RELEASE_INDEX.json": JSON.stringify(indexMissingGate, null, 2) });
assertReject("manifest_missing_public_release_seal", { "MANIFEST.in": manifestMissingSeal });

const files = Array.from(new Set([
  ...current.seal.required_files,
  ...current.index.required_files
])).sort();

const file_digests = {};
for (const rel of files) {
  file_digests[rel] = sha256Text(disk(rel));
}

const receipt = {
  receipt: "MK10_PRO_PUBLIC_RELEASE_SEAL_RECEIPT",
  pass: true,
  package: "@kaaffilm/mk10-pro",
  package_version: "1.0.3",
  release: "v1.0.3",
  generated_at: new Date().toISOString(),
  upstream_release_gate_receipt: path.basename(gateReceipt),
  upstream_release_gate_receipt_sha256: sha256File(gateReceipt),
  file_count: files.length,
  file_digests
};

const jsonPath = path.join(out, "MK10_PRO_PUBLIC_RELEASE_SEAL_RECEIPT.json");
fs.writeFileSync(jsonPath, JSON.stringify(receipt, null, 2) + "\n");
console.log(`PUBLIC_RELEASE_SEAL_NODE_ASSERT: PASS files=${files.length}`);
console.log(`RECEIPT=${jsonPath}`);
NODE

printf "\nMK10-PRO v1.0.3 PUBLIC RELEASE SEAL: PASS\n"
