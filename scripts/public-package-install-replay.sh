#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${OUT:-$(mktemp -d /tmp/mk10-pro-public-package-install-replay.XXXXXX)}"
mkdir -p "$OUT"

ASSERT_JS="$OUT/assert-public-package-install-replay.cjs"
cat > "$ASSERT_JS" <<'JS'
const fs = require("fs");
const path = require("path");

const root = process.argv[2] || process.cwd();

function read(p) {
  return fs.readFileSync(path.join(root, p), "utf8");
}
function json(p) {
  return JSON.parse(read(p));
}
function exists(p) {
  return fs.existsSync(path.join(root, p));
}
function fail(msg) {
  throw new Error(msg);
}
function requireIncludes(file, needle) {
  const text = read(file);
  if (!text.includes(needle)) fail(`${file} missing ${needle}`);
}

const contractPath = "PUBLIC_PACKAGE_INSTALL_REPLAY.json";
if (!exists(contractPath)) fail("PUBLIC_PACKAGE_INSTALL_REPLAY.json missing");

const contract = json(contractPath);
if (contract.artifact !== "PUBLIC_PACKAGE_INSTALL_REPLAY") fail("bad artifact");
if (contract.version !== "1.0.3") fail("bad contract version");
if (contract.status !== "sealed") fail("contract not sealed");

const pkg = json("packages/npm/package.json");
if (pkg.name !== "@kaaffilm/mk10-pro") fail("bad npm package name");
if (pkg.version !== "1.0.3") fail("bad npm package version");
if (!pkg.bin || pkg.bin["mk10-pro"] !== "bin/mk10-pro.js") fail("bad npm bin");

const pyproject = read("pyproject.toml");
if (!/^version\s*=\s*"1\.0\.3"/m.test(pyproject)) fail("bad pyproject version");

for (const p of [
  "PUBLIC_RELEASE_SEAL.json",
  "RELEASE_INDEX.json",
  "AIRGAP_AUDIT_RELEASE_GATE.json",
  "scripts/public-release-seal.sh",
  "scripts/airgap-audit-release-gate.sh",
  "packages/npm/package.json",
  "packages/npm/README.md",
  "packages/npm/PACKAGE_SURFACES.json",
  "packages/npm/bin/mk10-pro.js",
  "scripts/public-package-install-replay.sh",
  ".github/workflows/public-package-install-replay.yml",
  "tests/test_public_package_install_replay.py",
  "docs/PUBLIC_PACKAGE_INSTALL_REPLAY.md"
]) {
  if (!exists(p)) fail(`required file missing: ${p}`);
}

const releaseSeal = json("PUBLIC_RELEASE_SEAL.json");
const releaseSealText = read("PUBLIC_RELEASE_SEAL.json");
if (!releaseSealText.includes("PUBLIC_RELEASE_SEAL")) fail("public release seal identity missing");
if (!releaseSealText.includes("1.0.3")) fail("public release seal does not bind v1.0.3");

const releaseIndex = json("RELEASE_INDEX.json");
const releaseIndexText = JSON.stringify(releaseIndex);
if (!releaseIndexText.includes("PUBLIC_RELEASE_SEAL")) fail("release index missing public release seal");
if (!releaseIndexText.includes("AIRGAP_AUDIT_RELEASE_GATE")) fail("release index missing release gate");

const surfaces = json("packages/npm/PACKAGE_SURFACES.json");
const surfaceText = JSON.stringify(surfaces);
if (!surfaceText.includes("mk10-pro")) fail("package surface missing mk10-pro reference");

requireIncludes("README.md", "Public package install replay");
requireIncludes("MANIFEST.in", "PUBLIC_PACKAGE_INSTALL_REPLAY.json");
requireIncludes("MANIFEST.in", "docs/PUBLIC_PACKAGE_INSTALL_REPLAY.md");
requireIncludes("MANIFEST.in", "scripts/public-package-install-replay.sh");
requireIncludes("MANIFEST.in", "tests/test_public_package_install_replay.py");

console.log("PUBLIC_PACKAGE_INSTALL_REPLAY_CONTRACT_SHAPE: PASS");
JS

printf "\n[MK10-PRO v1.0.3 PUBLIC PACKAGE INSTALL REPLAY]\n"
node "$ASSERT_JS" "$ROOT"

printf "\n[CHAIN: PUBLIC RELEASE SEAL]\n"
OUT="$OUT/public-release-seal" bash "$ROOT/scripts/public-release-seal.sh"

printf "\n[PACK + INSTALL REPLAY]\n"
PACK_DIR="$OUT/npm-pack"
CONSUMER_DIR="$OUT/consumer"
CACHE_DIR="$OUT/npm-cache"
mkdir -p "$PACK_DIR" "$CONSUMER_DIR" "$CACHE_DIR"

(
  cd "$ROOT/packages/npm"
  npm test
  npm pack --pack-destination "$PACK_DIR"
)

TARBALL="$(find "$PACK_DIR" -maxdepth 1 -name '*.tgz' -print -quit)"
test -n "$TARBALL"
test -f "$TARBALL"

(
  cd "$CONSUMER_DIR"
  npm init -y >/dev/null
  NPM_CONFIG_CACHE="$CACHE_DIR" \
  NPM_CONFIG_REGISTRY="http://127.0.0.1:9" \
  npm install --ignore-scripts --no-audit --no-fund --offline "$TARBALL"

  node - <<'NODE'
const fs = require("fs");
const path = require("path");
const pkgPath = path.join(process.cwd(), "node_modules/@kaaffilm/mk10-pro/package.json");
const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
if (pkg.name !== "@kaaffilm/mk10-pro") throw new Error("installed package name mismatch");
if (pkg.version !== "1.0.3") throw new Error("installed package version mismatch");
if (!pkg.bin || pkg.bin["mk10-pro"] !== "bin/mk10-pro.js") throw new Error("installed bin mismatch");
for (const rel of ["README.md", "PACKAGE_SURFACES.json", "bin/mk10-pro.js"]) {
  const p = path.join(process.cwd(), "node_modules/@kaaffilm/mk10-pro", rel);
  if (!fs.existsSync(p)) throw new Error(`installed package missing ${rel}`);
}
console.log("PUBLIC_PACKAGE_INSTALL_REPLAY_INSTALL_ASSERT: PASS");
NODE

  node --check "node_modules/@kaaffilm/mk10-pro/bin/mk10-pro.js"
)

printf "\n[NEGATIVE CONTROLS]\n"
NEG_ROOT="$OUT/negative"
mkdir -p "$NEG_ROOT"

run_negative() {
  local name="$1"
  local mutator="$2"
  local copy="$NEG_ROOT/$name"
  rm -rf "$copy"
  mkdir -p "$copy"
  tar --exclude='.git' \
      --exclude='build' \
      --exclude='dist' \
      --exclude='.pytest_cache' \
      --exclude='mk10_pro.egg-info' \
      --exclude='*.tgz' \
      -C "$ROOT" -cf - . | tar -C "$copy" -xf -
  bash -c "cd '$copy' && $mutator"
  if node "$ASSERT_JS" "$copy" >/tmp/mk10-pro-public-package-install-replay-negative.log 2>&1; then
    cat /tmp/mk10-pro-public-package-install-replay-negative.log
    echo "negative_failed $name"
    exit 1
  fi
  echo "negative_rejected $name"
}

run_negative "public_package_install_replay_removed" "rm -f PUBLIC_PACKAGE_INSTALL_REPLAY.json"
run_negative "release_index_removed" "rm -f RELEASE_INDEX.json"
run_negative "public_release_seal_removed" "rm -f PUBLIC_RELEASE_SEAL.json"
run_negative "release_gate_contract_removed" "rm -f AIRGAP_AUDIT_RELEASE_GATE.json"
run_negative "install_script_removed" "rm -f scripts/public-package-install-replay.sh"
run_negative "workflow_removed" "rm -f .github/workflows/public-package-install-replay.yml"
run_negative "npm_package_version_raised" "python3 - <<'PY'
import json, pathlib
p=pathlib.Path('packages/npm/package.json')
d=json.loads(p.read_text())
d['version']='1.0.4'
p.write_text(json.dumps(d, indent=2)+'\n')
PY"
run_negative "npm_bin_removed" "rm -f packages/npm/bin/mk10-pro.js"
run_negative "npm_package_surface_removed" "rm -f packages/npm/PACKAGE_SURFACES.json"
run_negative "manifest_missing_public_package_install_replay" "python3 - <<'PY'
import pathlib
p=pathlib.Path('MANIFEST.in')
p.write_text('\n'.join([line for line in p.read_text().splitlines() if 'PUBLIC_PACKAGE_INSTALL_REPLAY' not in line and 'public-package-install-replay' not in line and 'test_public_package_install_replay' not in line])+'\n')
PY"

RECEIPT="$OUT/MK10_PRO_PUBLIC_PACKAGE_INSTALL_REPLAY_RECEIPT.json"
node - <<NODE
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const root = "$ROOT";
const files = [
  "PUBLIC_PACKAGE_INSTALL_REPLAY.json",
  "PUBLIC_RELEASE_SEAL.json",
  "RELEASE_INDEX.json",
  "AIRGAP_AUDIT_RELEASE_GATE.json",
  "packages/npm/package.json",
  "packages/npm/PACKAGE_SURFACES.json",
  "packages/npm/bin/mk10-pro.js",
  "scripts/public-package-install-replay.sh",
  ".github/workflows/public-package-install-replay.yml",
  "tests/test_public_package_install_replay.py",
  "docs/PUBLIC_PACKAGE_INSTALL_REPLAY.md"
];
const digest = {};
for (const rel of files) {
  const buf = fs.readFileSync(path.join(root, rel));
  digest[rel] = crypto.createHash("sha256").update(buf).digest("hex");
}
const receipt = {
  artifact: "MK10_PRO_PUBLIC_PACKAGE_INSTALL_REPLAY_RECEIPT",
  version: "1.0.3",
  status: "PASS",
  network_after_checkout: "forbidden",
  install_source: "local npm pack tarball",
  package: "@kaaffilm/mk10-pro",
  package_version: "1.0.3",
  file_count: files.length,
  digests: digest
};
fs.writeFileSync("$RECEIPT", JSON.stringify(receipt, null, 2) + "\n");
console.log("PUBLIC_PACKAGE_INSTALL_REPLAY_NODE_ASSERT: PASS files=" + files.length);
console.log("RECEIPT=$RECEIPT");
NODE

printf "\nMK10-PRO v1.0.3 PUBLIC PACKAGE INSTALL REPLAY: PASS\n"
