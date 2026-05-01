#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${1:-/tmp/mk10-pro-audit-receipt}"
mkdir -p "$OUT_DIR"
RECEIPT="$OUT_DIR/MK10_PRO_AUDIT_RECEIPT.json"

printf "\n[MK10-PRO AUDIT RECEIPT PROOF]\n"

test "$(cat VERSION)" = "1.0.3"
test -f AUDIT_RECEIPT_CONTRACT.json
test -f AUDIT_PACKET.md
test -f docs/AUDIT_RECEIPT.md
test -f scripts/public-surface-proof.sh
test -f scripts/public-replay-proof.sh
test -f scripts/auditor-replay-proof.sh
test -f scripts/audit-packet-proof.sh

bash scripts/public-surface-proof.sh
bash scripts/public-replay-proof.sh
bash scripts/auditor-replay-proof.sh
bash scripts/audit-packet-proof.sh

node - "$RECEIPT" <<'NODE'
const fs = require("fs");
const crypto = require("crypto");

const receiptPath = process.argv[2];

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

function sha256(path) {
  return crypto.createHash("sha256").update(fs.readFileSync(path)).digest("hex");
}

const contract = readJson("AUDIT_RECEIPT_CONTRACT.json");
const surface = readJson("PACKAGE_SURFACES.json");
const pkg = readJson("packages/npm/package.json");

if (contract.version !== "1.0.3") throw new Error("contract version drift");
if (contract.locked_version !== "1.0.3") throw new Error("contract lock drift");
if (contract.canonical_runtime_witness !== "pypi") throw new Error("contract canonical witness drift");
if (surface.version !== "1.0.3") throw new Error("surface version drift");
if (surface.version_lock.locked_version !== "1.0.3") throw new Error("surface lock drift");
if (surface.version_lock.canonical_runtime_witness !== "pypi") throw new Error("surface canonical witness drift");
if (pkg.version !== "1.0.3") throw new Error("npm package version drift");

const receipt = {
  receipt_type: contract.receipt_type,
  status: "PASS",
  version: "1.0.3",
  locked_version: "1.0.3",
  canonical_runtime_witness: "pypi",
  no_version_raise: true,
  source_truth: contract.source_truth,
  package_surfaces: contract.package_surfaces,
  proof_chain: {
    public_surface_proof: "PASS",
    public_replay_perimeter: "PASS",
    auditor_replay_entrypoint: "PASS",
    external_audit_packet: "PASS"
  },
  files: {
    audit_receipt_contract_sha256: sha256("AUDIT_RECEIPT_CONTRACT.json"),
    package_surfaces_sha256: sha256("PACKAGE_SURFACES.json"),
    audit_packet_sha256: sha256("AUDIT_PACKET.md"),
    public_surface_sha256: sha256("PUBLIC_SURFACE.md"),
    auditor_start_here_sha256: sha256("AUDITOR_START_HERE.md")
  },
  claim_boundary: contract.claim_boundary
};

fs.writeFileSync(receiptPath, JSON.stringify(receipt, null, 2) + "\n");

const reread = readJson(receiptPath);
if (reread.status !== "PASS") throw new Error("receipt status drift");
if (reread.version !== "1.0.3") throw new Error("receipt version drift");
if (reread.locked_version !== "1.0.3") throw new Error("receipt lock drift");
if (reread.canonical_runtime_witness !== "pypi") throw new Error("receipt canonical witness drift");
if (reread.no_version_raise !== true) throw new Error("receipt no-version-raise drift");
if (reread.package_surfaces.npm.runtime_boundary !== "not_canonical_runtime_witness") throw new Error("npm runtime boundary drift");
if (reread.package_surfaces.pkg.runtime_boundary !== "not_canonical_runtime_witness") throw new Error("pkg runtime boundary drift");

console.log("AUDIT_RECEIPT_NODE_ASSERT: PASS");
console.log(`AUDIT_RECEIPT=${receiptPath}`);
NODE

printf "\nMK10-PRO v1.0.3 AUDIT RECEIPT: PASS\n"
