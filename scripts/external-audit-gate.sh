#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${1:-/tmp/mk10-pro-external-audit-gate}"
mkdir -p "$OUT_DIR"

PYTHON_SEED="${PYTHON:-}"
if [ -z "$PYTHON_SEED" ]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_SEED="python3"
  elif command -v python >/dev/null 2>&1; then
    PYTHON_SEED="python"
  else
    echo "ERROR: python3 or python is required" >&2
    exit 1
  fi
fi

GATE_VENV="${MK10_PRO_EXTERNAL_AUDIT_GATE_VENV:-$OUT_DIR/.venv}"
if [ ! -x "$GATE_VENV/bin/python" ]; then
  "$PYTHON_SEED" -m venv "$GATE_VENV"
fi

PYTHON_BIN="$GATE_VENV/bin/python"
"$PYTHON_BIN" -m pip install --quiet --upgrade pip
"$PYTHON_BIN" -m pip install --quiet pytest build

printf "\n[MK10-PRO v1.0.3 EXTERNAL AUDIT GATE]\n"

node - <<'NODE'
const fs = require("fs");
const gate = JSON.parse(fs.readFileSync("EXTERNAL_AUDIT_GATE.json", "utf8"));
const surface = JSON.parse(fs.readFileSync("PACKAGE_SURFACES.json", "utf8"));
const pkg = JSON.parse(fs.readFileSync("packages/npm/package.json", "utf8"));
const receipt = JSON.parse(fs.readFileSync("AUDIT_RECEIPT_CONTRACT.json", "utf8"));
const schema = JSON.parse(fs.readFileSync("AUDIT_RECEIPT_SCHEMA.json", "utf8"));
const neg = JSON.parse(fs.readFileSync("AUDIT_RECEIPT_NEGATIVE_CASES.json", "utf8"));

function assert(cond, msg) {
  if (!cond) {
    console.error(msg);
    process.exit(1);
  }
}

assert(fs.readFileSync("VERSION", "utf8").trim() === "1.0.3", "VERSION drift");
assert(gate.version === "1.0.3", "gate version drift");
assert(gate.locked_version === "1.0.3", "gate locked_version drift");
assert(gate.canonical_runtime_witness === "pypi", "gate witness drift");
assert(gate.no_version_raise === true, "gate no-version-raise disabled");
assert(surface.version === "1.0.3", "surface version drift");
assert(surface.version_lock.locked_version === "1.0.3", "surface lock drift");
assert(surface.version_lock.canonical_runtime_witness === "pypi", "surface witness drift");
assert(pkg.version === "1.0.3", "npm version drift");
assert(receipt.locked_version === "1.0.3", "receipt lock drift");
assert(schema.properties.locked_version.const === "1.0.3", "schema lock drift");
assert(neg.locked_version === "1.0.3", "negative controls lock drift");
assert(gate.required_layers.length === 7, "missing required layer");
console.log("EXTERNAL_AUDIT_GATE_NODE_ASSERT: PASS");
NODE

bash scripts/public-surface-proof.sh
bash scripts/public-replay-proof.sh
bash scripts/auditor-replay-proof.sh
bash scripts/audit-packet-proof.sh
bash scripts/audit-receipt-proof.sh "$OUT_DIR/audit-receipt"
bash scripts/audit-receipt-schema-proof.sh
bash scripts/audit-receipt-negative-proof.sh "$OUT_DIR/audit-receipt-negative-controls"

"$PYTHON_BIN" -m pytest \
  tests/test_public_surface_lock.py \
  tests/test_public_replay_perimeter.py \
  tests/test_auditor_entrypoint.py \
  tests/test_audit_packet.py \
  tests/test_audit_receipt.py \
  tests/test_audit_receipt_schema.py \
  tests/test_audit_receipt_negative_controls.py

( cd packages/npm && npm test && npm pack --dry-run )

printf "\nMK10-PRO v1.0.3 EXTERNAL AUDIT GATE: PASS\n"
