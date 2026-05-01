#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION="1.0.3"

printf "\n[MK10-PRO v%s OFFLINE AUDIT LOCK]\n" "$VERSION"

node <<'NODE'
const fs = require("fs");

const mustRead = (p) => {
  if (!fs.existsSync(p)) throw new Error(`missing ${p}`);
  return fs.readFileSync(p, "utf8");
};
const mustJson = (p) => JSON.parse(mustRead(p));

const lock = mustJson("OFFLINE_AUDIT_LOCK.json");
if (lock.version !== "1.0.3") throw new Error("offline lock version drift");
if (lock.lock !== "OFFLINE_AUDIT_LOCK") throw new Error("offline lock identity drift");
if (lock.version_boundary.locked_version !== "1.0.3") throw new Error("locked version drift");
if (lock.version_boundary.version_raise_allowed !== false) throw new Error("version raise boundary drift");

const pkgPath = lock.npm_package_json || (fs.existsSync("package.json") ? "package.json" : "packages/npm/package.json");
const npmDir = lock.npm_working_directory || (pkgPath === "package.json" ? "." : "packages/npm");

const requiredFiles = [
  "pyproject.toml",
  "README.md",
  "MANIFEST.in",
  "AUDITOR_START_HERE.md",
  "AUDIT_PACKET.md",
  "AUDIT_RECEIPT_CONTRACT.json",
  "AUDIT_RECEIPT_SCHEMA.json",
  "AUDIT_RECEIPT_NEGATIVE_CASES.json",
  "EXTERNAL_AUDIT_GATE.json",
  "OFFLINE_AUDIT_LOCK.json",
  "docs/AUDITOR_REPLAY.md",
  "docs/AUDIT_PACKET.md",
  "docs/AUDIT_RECEIPT.md",
  "docs/AUDIT_RECEIPT_SCHEMA.md",
  "docs/AUDIT_RECEIPT_NEGATIVE_CONTROLS.md",
  "docs/EXTERNAL_AUDIT_GATE.md",
  "docs/OFFLINE_AUDIT_LOCK.md",
  "scripts/public-surface-proof.sh",
  "scripts/public-replay-proof.sh",
  "scripts/auditor-replay-proof.sh",
  "scripts/audit-packet-proof.sh",
  "scripts/audit-receipt-proof.sh",
  "scripts/audit-receipt-schema-proof.sh",
  "scripts/audit-receipt-negative-proof.sh",
  "scripts/external-audit-gate.sh",
  "scripts/offline-audit-lock.sh",
  ".github/workflows/offline-audit-lock.yml"
];

for (const p of requiredFiles) mustRead(p);
mustRead(pkgPath);

const pkg = mustJson(pkgPath);
if (pkg.name !== "@kaaffilm/mk10-pro") throw new Error("npm package name drift");
if (pkg.version !== "1.0.3") throw new Error("npm package version drift");

const pyproject = mustRead("pyproject.toml");
if (!/version\s*=\s*"1\.0\.3"/.test(pyproject)) throw new Error("python package version drift");

const gate = mustJson("EXTERNAL_AUDIT_GATE.json");
if (gate.version !== "1.0.3") throw new Error("external audit gate version drift");

const negativeCases = mustJson("AUDIT_RECEIPT_NEGATIVE_CASES.json");

const collectArrays = (value, out = []) => {
  if (Array.isArray(value)) out.push(value);
  else if (value && typeof value === "object") {
    for (const v of Object.values(value)) collectArrays(v, out);
  }
  return out;
};

const negativeCaseList =
  Array.isArray(negativeCases.cases) ? negativeCases.cases :
  Array.isArray(negativeCases.negative_cases) ? negativeCases.negative_cases :
  Array.isArray(negativeCases.required_negative_cases) ? negativeCases.required_negative_cases :
  collectArrays(negativeCases).sort((a, b) => b.length - a.length)[0] || [];

if (!Array.isArray(negativeCaseList) || negativeCaseList.length < 10) {
  throw new Error(`negative controls weakened: discovered ${negativeCaseList.length}`);
}

for (const expected of [
  "bad_sha256_binding",
  "canonical_witness_changed",
  "claim_boundary_expanded",
  "locked_version_raised",
  "no_version_raise_disabled",
  "npm_promoted_to_canonical",
  "proof_chain_failure",
  "source_release_changed",
  "status_failure",
  "version_raised"
]) {
  if (!negativeCaseList.some((x) => String(x).includes(expected))) {
    throw new Error(`negative control missing: ${expected}`);
  }
}

const offlineScriptRaw = mustRead("scripts/offline-audit-lock.sh");
const offlineScript = offlineScriptRaw.replace(
  /\/\/ FORBIDDEN_SCAN_TABLE_START[\s\S]*?\/\/ FORBIDDEN_SCAN_TABLE_END/g,
  ""
);

// FORBIDDEN_SCAN_TABLE_START
const forbiddenPatterns = [
  { label: "curl", re: new RegExp("\\bcu" + "rl\\b") },
  { label: "wget", re: new RegExp("\\bw" + "get\\b") },
  { label: "gh api", re: new RegExp("\\bgh\\s+ap" + "i\\b") },
  { label: "gh pr", re: new RegExp("\\bgh\\s+p" + "r\\b") },
  { label: "git fetch", re: new RegExp("\\bgit\\s+fet" + "ch\\b") },
  { label: "git pull", re: new RegExp("\\bgit\\s+pu" + "ll\\b") },
  { label: "git clone", re: new RegExp("\\bgit\\s+cl" + "one\\b") },
  { label: "npm install", re: new RegExp("\\bnpm\\s+inst" + "all\\b") },
  { label: "npm ci", re: new RegExp("\\bnpm\\s+c" + "i\\b") },
  { label: "pip install", re: new RegExp("\\bpip\\s+inst" + "all\\b") },
  { label: "python -m pip", re: new RegExp("\\bpython\\s+-m\\s+p" + "ip\\b") },
  { label: "python3 -m pip", re: new RegExp("\\bpython3\\s+-m\\s+p" + "ip\\b") }
];
// FORBIDDEN_SCAN_TABLE_END

for (const { label, re } of forbiddenPatterns) {
  if (re.test(offlineScript)) {
    throw new Error(`offline verifier contains forbidden network/install command: ${label}`);
  }
}

const readme = mustRead("README.md");
const readmeLower = readme.toLowerCase();

const readmeSemanticChecks = [
  ["public surface", ["public", "surface"]],
  ["public replay perimeter", ["public", "replay", "perimeter"]],
  ["auditor replay", ["auditor", "replay"]],
  ["external audit packet", ["external", "audit", "packet"]],
  ["audit receipt", ["audit", "receipt"]],
  ["audit receipt schema", ["receipt", "schema"]],
  ["audit receipt negative controls", ["negative", "controls"]],
  ["external audit gate", ["external", "audit", "gate"]],
  ["offline audit lock", ["offline", "audit", "lock"]]
];

for (const [name, tokens] of readmeSemanticChecks) {
  if (!tokens.every((token) => readmeLower.includes(token))) {
    throw new Error(`README missing semantic boundary: ${name}`);
  }
}

console.log(`OFFLINE_AUDIT_LOCK_NODE_ASSERT: PASS pkg=${pkgPath} npm_dir=${npmDir}`);
NODE

if [ -f package.json ] && [ -f test/smoke.mjs ]; then
  npm test
elif [ -f packages/npm/package.json ] && [ -f packages/npm/test/smoke.mjs ]; then
  (cd packages/npm && npm test)
fi

printf "\nMK10-PRO v%s OFFLINE AUDIT LOCK: PASS\n" "$VERSION"
