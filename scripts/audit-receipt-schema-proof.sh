#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${1:-/tmp/mk10-pro-audit-receipt-schema}"
mkdir -p "$OUT_DIR"

printf "\n[MK10-PRO AUDIT RECEIPT SCHEMA PROOF]\n"

test "$(cat VERSION)" = "1.0.3"
test -f AUDIT_RECEIPT_SCHEMA.json
test -f AUDIT_RECEIPT_CONTRACT.json
test -f docs/AUDIT_RECEIPT_SCHEMA.md
test -x scripts/verify-audit-receipt.cjs
test -x scripts/audit-receipt-proof.sh

bash scripts/audit-receipt-proof.sh "$OUT_DIR"

RECEIPT="$OUT_DIR/MK10_PRO_AUDIT_RECEIPT.json"
test -f "$RECEIPT"

node scripts/verify-audit-receipt.cjs "$RECEIPT"

printf "\nMK10-PRO v1.0.3 AUDIT RECEIPT SCHEMA: PASS\n"
