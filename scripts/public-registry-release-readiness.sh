#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/mk10-pro-public-registry-release-readiness.XXXXXX")"
NODE="$(command -v node)"

fail() {
  echo "PUBLIC_REGISTRY_RELEASE_READINESS_FAIL: $*" >&2
  exit 1
}

cleanup() {
  rm -rf "$WORK"
}
trap cleanup EXIT

printf "\n[MK10-PRO v1.0.3 PUBLIC REGISTRY RELEASE READINESS]\n"

ASSERT="$WORK/assert-public-registry-release-readiness.cjs"
cat > "$ASSERT" <<'JS'
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const root = process.cwd();

function fail(msg) {
  throw new Error(msg);
}

function read(rel) {
  return fs.readFileSync(path.join(root, rel), "utf8");
}

function json(rel) {
  return JSON.parse(read(rel));
}

function exists(rel) {
  if (!fs.existsSync(path.join(root, rel))) fail(`missing ${rel}`);
}

function sha256(rel) {
  return crypto.createHash("sha256").update(read(rel)).digest("hex");
}

const contract = json("PUBLIC_REGISTRY_RELEASE_READINESS.json");
if (contract.schema_version !== 1) fail("schema_version mismatch");
if (contract.boundary !== "PUBLIC_REGISTRY_RELEASE_READINESS") fail("boundary mismatch");
if (contract.project !== "MK10-PRO") fail("project mismatch");
if (contract.version !== "1.0.3") fail("contract version mismatch");
if (!contract.package || contract.package.name !== "@kaaffilm/mk10-pro") fail("package name mismatch");
if (contract.package.version !== "1.0.3") fail("package version mismatch");
if (contract.package.registry_write_allowed !== false) fail("registry write must be false");

const pkg = json("packages/npm/package.json");
if (pkg.name !== "@kaaffilm/mk10-pro") fail("npm package name mismatch");
if (pkg.version !== "1.0.3") fail("npm package version mismatch");
if (!pkg.bin || !pkg.bin["mk10-pro"]) fail("npm bin missing");

const required = [
  "PUBLIC_REGISTRY_RELEASE_READINESS.json",
  "PUBLIC_PACKAGE_INSTALL_REPLAY.json",
  "PUBLIC_RELEASE_SEAL.json",
  "RELEASE_INDEX.json",
  "AIRGAP_AUDIT_RELEASE_GATE.json",
  "packages/npm/package.json",
  "packages/npm/PACKAGE_SURFACES.json",
  "scripts/public-registry-release-readiness.sh",
  "scripts/public-package-install-replay.sh",
  ".github/workflows/public-registry-release-readiness.yml",
  "docs/PUBLIC_REGISTRY_RELEASE_READINESS.md"
];

for (const rel of required) exists(rel);

const packageInstallReplay = json("PUBLIC_PACKAGE_INSTALL_REPLAY.json");
if (packageInstallReplay.version !== "1.0.3") fail("install replay version mismatch");

const publicReleaseSeal = json("PUBLIC_RELEASE_SEAL.json");
if (!JSON.stringify(publicReleaseSeal).includes("1.0.3")) fail("public release seal version mismatch");

const releaseGate = json("AIRGAP_AUDIT_RELEASE_GATE.json");
if (releaseGate.version !== "1.0.3") fail("release gate version mismatch");

const manifest = read("MANIFEST.in");
for (const rel of [
  "PUBLIC_REGISTRY_RELEASE_READINESS.json",
  "docs/PUBLIC_REGISTRY_RELEASE_READINESS.md",
  "scripts/public-registry-release-readiness.sh",
  ".github/workflows/public-registry-release-readiness.yml"
]) {
  if (!manifest.includes(rel)) fail(`MANIFEST missing ${rel}`);
}

const script = read("scripts/public-registry-release-readiness.sh");
if (!script.includes("npm publish --dry-run")) fail("npm publish dry-run proof missing");

const workflow = read(".github/workflows/public-registry-release-readiness.yml");
for (const line of workflow.split(/\r?\n/)) {
  if (line.includes("npm publish") && !line.includes("--dry-run")) {
    fail("workflow contains registry write publish");
  }
}

const receipt = {
  receipt_type: "MK10_PRO_PUBLIC_REGISTRY_RELEASE_READINESS_RECEIPT",
  project: "MK10-PRO",
  version: "1.0.3",
  package: "@kaaffilm/mk10-pro",
  registry_write_allowed: false,
  required_files: required,
  file_count: required.length,
  sha256: Object.fromEntries(required.map((rel) => [rel, sha256(rel)]))
};

fs.writeFileSync(
  process.env.RECEIPT || path.join(root, "MK10_PRO_PUBLIC_REGISTRY_RELEASE_READINESS_RECEIPT.json"),
  JSON.stringify(receipt, null, 2) + "\n"
);

console.log(`PUBLIC_REGISTRY_RELEASE_READINESS_NODE_ASSERT: PASS files=${required.length}`);
JS

cd "$ROOT"

"$NODE" "$ASSERT"

printf "\n[CHAIN: PUBLIC PACKAGE INSTALL REPLAY]\n"
bash scripts/public-package-install-replay.sh

printf "\n[NPM REGISTRY DRY-RUN READINESS]\n"
(
  cd packages/npm
  npm test
  npm pack --dry-run

  PKG="$(node -p 'require("./package.json").name')"
  VERSION="$(node -p 'require("./package.json").version')"

  REGISTRY_VERSION="$(npm view "$PKG@$VERSION" version 2>/dev/null || true)"
  if [ "$REGISTRY_VERSION" = "$VERSION" ]; then
    printf "PUBLIC_REGISTRY_RELEASE_READINESS_ALREADY_PUBLISHED: PASS package=%s version=%s\n" "$PKG" "$VERSION"
  else
    npm publish --dry-run --access public
    printf "PUBLIC_REGISTRY_RELEASE_READINESS_PUBLISH_DRY_RUN: PASS package=%s version=%s\n" "$PKG" "$VERSION"
  fi
)

printf "\n[NEGATIVE CONTROLS]\n"
run_negative() {
  local name="$1"
  local mutator="$2"
  local case_dir="$WORK/negative-$name"
  mkdir -p "$case_dir"
  rsync -a \
    --exclude ".git" \
    --exclude ".pytest_cache" \
    --exclude "node_modules" \
    --exclude "*.tgz" \
    "$ROOT"/ "$case_dir"/
  (cd "$case_dir" && bash -c "$mutator")
  if (cd "$case_dir" && "$NODE" "$ASSERT" >/dev/null 2>&1); then
    fail "negative did not fail: $name"
  fi
  echo "negative_rejected $name"
}

run_negative "public_registry_release_readiness_removed" 'rm -f PUBLIC_REGISTRY_RELEASE_READINESS.json'
run_negative "public_package_install_replay_removed" 'rm -f PUBLIC_PACKAGE_INSTALL_REPLAY.json'
run_negative "public_release_seal_removed" 'rm -f PUBLIC_RELEASE_SEAL.json'
run_negative "release_gate_removed" 'rm -f AIRGAP_AUDIT_RELEASE_GATE.json'
run_negative "script_removed" 'rm -f scripts/public-registry-release-readiness.sh'
run_negative "workflow_removed" 'rm -f .github/workflows/public-registry-release-readiness.yml'
run_negative "npm_package_version_raised" 'python3 - <<PY
import json, pathlib
p=pathlib.Path("packages/npm/package.json")
d=json.loads(p.read_text())
d["version"]="1.0.4"
p.write_text(json.dumps(d, indent=2)+"\n")
PY'
run_negative "manifest_missing_registry_readiness" 'python3 - <<PY
from pathlib import Path
p=Path("MANIFEST.in")
p.write_text("\n".join(line for line in p.read_text().splitlines() if "PUBLIC_REGISTRY_RELEASE_READINESS" not in line and "public-registry-release-readiness" not in line)+"\n")
PY'
run_negative "workflow_contains_registry_write_publish" 'printf "\n      - run: npm publish\n" >> .github/workflows/public-registry-release-readiness.yml'

RECEIPT="${OUT:-$WORK}/MK10_PRO_PUBLIC_REGISTRY_RELEASE_READINESS_RECEIPT.json"
RECEIPT="$RECEIPT" "$NODE" "$ASSERT"
echo "RECEIPT=$RECEIPT"

printf "\nMK10-PRO v1.0.3 PUBLIC REGISTRY RELEASE READINESS: PASS\n"
