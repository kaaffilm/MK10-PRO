#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${1:-/tmp/mk10-pro-audit-receipt-negative-controls}"
VALID_DIR="$OUT_DIR/valid"
BAD_DIR="$OUT_DIR/bad"
rm -rf "$OUT_DIR"
mkdir -p "$VALID_DIR" "$BAD_DIR"

printf "\n[MK10-PRO AUDIT RECEIPT NEGATIVE CONTROLS]\n"

test "$(cat VERSION)" = "1.0.3"
test -f AUDIT_RECEIPT_NEGATIVE_CASES.json
test -f AUDIT_RECEIPT_SCHEMA.json
test -f AUDIT_RECEIPT_CONTRACT.json
test -x scripts/audit-receipt-proof.sh
test -x scripts/verify-audit-receipt.cjs

bash scripts/audit-receipt-proof.sh "$VALID_DIR"

RECEIPT="$VALID_DIR/MK10_PRO_AUDIT_RECEIPT.json"
test -f "$RECEIPT"

node scripts/verify-audit-receipt.cjs "$RECEIPT"

node - "$RECEIPT" "$BAD_DIR" <<'NODE'
const fs = require("fs");
const receiptPath = process.argv[2];
const outDir = process.argv[3];
const base = JSON.parse(fs.readFileSync(receiptPath, "utf8"));

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function write(name, mutate) {
  const receipt = clone(base);
  mutate(receipt);
  fs.writeFileSync(`${outDir}/${name}.json`, JSON.stringify(receipt, null, 2) + "\n");
}

write("version_raised", r => {
  r.version = "1.0.4";
});

write("locked_version_raised", r => {
  r.locked_version = "1.0.4";
});

write("canonical_witness_changed", r => {
  r.canonical_runtime_witness = "npm";
});

write("no_version_raise_disabled", r => {
  r.no_version_raise = false;
});

write("npm_promoted_to_canonical", r => {
  r.package_surfaces.npm.runtime_boundary = "canonical_runtime_witness";
});

write("proof_chain_failure", r => {
  r.proof_chain.public_surface_proof = "FAIL";
});

write("bad_sha256_binding", r => {
  r.files.package_surfaces_sha256 = "not-a-sha256";
});

write("source_release_changed", r => {
  r.source_truth.release = "v1.0.4";
});

write("status_failure", r => {
  r.status = "FAIL";
});

write("claim_boundary_expanded", r => {
  r.claim_boundary.does_not_verify = r.claim_boundary.does_not_verify.filter(
    item => item !== "business outcome"
  );
});
NODE

COUNT=0
for bad in "$BAD_DIR"/*.json; do
  COUNT=$((COUNT + 1))
  name="$(basename "$bad")"
  if node scripts/verify-audit-receipt.cjs "$bad" > "$bad.out" 2>&1; then
    printf "NEGATIVE_CASE_ACCEPTED=%s\n" "$name"
    cat "$bad.out"
    exit 1
  fi
  printf "negative_rejected %s\n" "$name"
done

test "$COUNT" -eq 10

printf "\nMK10-PRO v1.0.3 AUDIT RECEIPT NEGATIVE CONTROLS: PASS\n"
