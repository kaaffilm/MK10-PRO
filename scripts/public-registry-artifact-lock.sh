#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION="1.0.3"
PKG="@kaaffilm/mk10-pro"

printf "[MK10-PRO v1.0.3 PUBLIC REGISTRY ARTIFACT LOCK]\n"

rm -f MK10_PRO_PUBLIC_REGISTRY_ARTIFACT_LOCK_RECEIPT.json

test "$(cat VERSION)" = "$VERSION"

if [ "${MK10_PUBLIC_REGISTRY_ARTIFACT_LOCK_FAST_CHAIN:-0}" != "1" ]; then
  printf "\n[CHAIN: PUBLIC REGISTRY RELEASE READINESS]\n"
  bash scripts/public-registry-release-readiness.sh
else
  test -f PUBLIC_REGISTRY_RELEASE_READINESS.json
  test -f PUBLIC_PACKAGE_INSTALL_REPLAY.json
  test -f PUBLIC_RELEASE_SEAL.json
  test -f AIRGAP_AUDIT_RELEASE_GATE.json
fi

node <<'NODE'
const fs = require("fs");
const { execFileSync } = require("child_process");

const VERSION = "1.0.3";
const PKG = "@kaaffilm/mk10-pro";

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

function fail(msg) {
  throw new Error(msg);
}

const lock = readJson("PUBLIC_REGISTRY_ARTIFACT_LOCK.json");
const readiness = readJson("PUBLIC_REGISTRY_RELEASE_READINESS.json");
const installReplay = readJson("PUBLIC_PACKAGE_INSTALL_REPLAY.json");
const releaseSeal = readJson("PUBLIC_RELEASE_SEAL.json");
const releaseGate = readJson("AIRGAP_AUDIT_RELEASE_GATE.json");
const pkg = readJson("packages/npm/package.json");

if (lock.version !== VERSION) fail("artifact lock version mismatch");
if (lock.registry_package !== PKG) fail("registry package mismatch");
if (lock.registry_version !== VERSION) fail("registry version mismatch");
if (pkg.version !== VERSION) fail("npm package version drift");
if (readiness.version !== VERSION) fail("readiness version mismatch");
if (installReplay.version !== VERSION) fail("install replay version mismatch");
if (!JSON.stringify(releaseSeal).includes(VERSION)) fail("public release seal missing version");
if (releaseGate.version !== VERSION) fail("release gate version mismatch");
if (!lock.registry_integrity || !lock.registry_integrity.startsWith("sha512-")) fail("bad registry integrity");
if (!lock.registry_shasum || lock.registry_shasum.length < 20) fail("bad registry shasum");
if (!lock.registry_tarball || !lock.registry_tarball.includes("mk10-pro-1.0.3.tgz")) fail("bad registry tarball");

const files = lock.required_files || [];
for (const file of files) {
  if (!fs.existsSync(file)) fail(`required file missing: ${file}`);
}

const manifest = fs.readFileSync("MANIFEST.in", "utf8");
for (const file of [
  "PUBLIC_REGISTRY_ARTIFACT_LOCK.json",
  "docs/PUBLIC_REGISTRY_ARTIFACT_LOCK.md",
  "scripts/public-registry-artifact-lock.sh"
]) {
  if (!manifest.includes(file)) fail(`MANIFEST missing ${file}`);
}

const readme = fs.readFileSync("README.md", "utf8");
if (!readme.includes("MK10-PRO v1.0.3 Public Registry Artifact Lock")) {
  fail("README missing artifact lock section");
}

const live = JSON.parse(execFileSync("npm", ["view", `${PKG}@${VERSION}`, "--json"], {
  encoding: "utf8",
  stdio: ["ignore", "pipe", "pipe"]
}));

if (live.name !== PKG) fail(`live npm name mismatch: ${live.name}`);
if (live.version !== VERSION) fail(`live npm version mismatch: ${live.version}`);
if (live.dist.integrity !== lock.registry_integrity) fail("live npm integrity mismatch");
if (live.dist.shasum !== lock.registry_shasum) fail("live npm shasum mismatch");
if (live.dist.tarball !== lock.registry_tarball) fail("live npm tarball mismatch");

const receipt = {
  receipt: "MK10-PRO v1.0.3 public registry artifact lock",
  version: VERSION,
  registry_package: PKG,
  registry_version: VERSION,
  registry_integrity: lock.registry_integrity,
  registry_shasum: lock.registry_shasum,
  registry_tarball: lock.registry_tarball,
  files_checked: files.length,
  status: "PASS"
};

fs.writeFileSync("MK10_PRO_PUBLIC_REGISTRY_ARTIFACT_LOCK_RECEIPT.json", JSON.stringify(receipt, null, 2) + "\n");
console.log(`PUBLIC_REGISTRY_ARTIFACT_LOCK_NODE_ASSERT: PASS files=${files.length}`);
NODE

if [ "${MK10_PUBLIC_REGISTRY_ARTIFACT_LOCK_SKIP_NEGATIVE:-0}" != "1" ]; then
  printf "\n[NEGATIVE CONTROLS]\n"
  node <<'NODE'
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const ROOT = process.cwd();

function copyRepo(dest) {
  fs.cpSync(ROOT, dest, {
    recursive: true,
    filter(src) {
      const rel = path.relative(ROOT, src);
      if (!rel) return true;
      if (rel === ".git" || rel.startsWith(".git/")) return false;
      if (rel === "node_modules" || rel.includes("/node_modules/")) return false;
      if (rel === ".pytest_cache" || rel.includes("/.pytest_cache/")) return false;
      if (rel === "build" || rel === "dist" || rel === "mk10_pro.egg-info") return false;
      if (rel.endsWith(".tgz")) return false;
      if (rel.endsWith("_RECEIPT.json")) return false;
      return true;
    }
  });
}

function patchJson(file, fn, cwd) {
  const p = path.join(cwd, file);
  const data = JSON.parse(fs.readFileSync(p, "utf8"));
  fn(data);
  fs.writeFileSync(p, JSON.stringify(data, null, 2) + "\n");
}

function patchText(file, fn, cwd) {
  const p = path.join(cwd, file);
  fs.writeFileSync(p, fn(fs.readFileSync(p, "utf8")));
}

const cases = [
  ["public_registry_artifact_lock_removed", cwd => fs.rmSync(path.join(cwd, "PUBLIC_REGISTRY_ARTIFACT_LOCK.json"), { force: true })],
  ["public_registry_release_readiness_removed", cwd => fs.rmSync(path.join(cwd, "PUBLIC_REGISTRY_RELEASE_READINESS.json"), { force: true })],
  ["public_package_install_replay_removed", cwd => fs.rmSync(path.join(cwd, "PUBLIC_PACKAGE_INSTALL_REPLAY.json"), { force: true })],
  ["public_release_seal_removed", cwd => fs.rmSync(path.join(cwd, "PUBLIC_RELEASE_SEAL.json"), { force: true })],
  ["script_removed", cwd => fs.rmSync(path.join(cwd, "scripts/public-registry-artifact-lock.sh"), { force: true })],
  ["workflow_removed", cwd => fs.rmSync(path.join(cwd, ".github/workflows/public-registry-artifact-lock.yml"), { force: true })],
  ["npm_package_version_raised", cwd => patchJson("packages/npm/package.json", j => { j.version = "1.0.4"; }, cwd)],
  ["registry_integrity_tampered", cwd => patchJson("PUBLIC_REGISTRY_ARTIFACT_LOCK.json", j => { j.registry_integrity = "sha512-tampered"; }, cwd)],
  ["registry_shasum_tampered", cwd => patchJson("PUBLIC_REGISTRY_ARTIFACT_LOCK.json", j => { j.registry_shasum = "0000000000000000000000000000000000000000"; }, cwd)],
  ["manifest_missing_registry_artifact_lock", cwd => patchText("MANIFEST.in", s => s.replace(/.*PUBLIC_REGISTRY_ARTIFACT_LOCK.*\n/g, ""), cwd)]
];

for (const [name, mutate] of cases) {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), `mk10-registry-artifact-lock-negative-${name}-`));
  copyRepo(work);
  mutate(work);

  let rejected = false;
  try {
    execFileSync("bash", ["scripts/public-registry-artifact-lock.sh"], {
      cwd: work,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
      env: {
        ...process.env,
        MK10_PUBLIC_REGISTRY_ARTIFACT_LOCK_SKIP_NEGATIVE: "1",
        MK10_PUBLIC_REGISTRY_ARTIFACT_LOCK_FAST_CHAIN: "1"
      }
    });
  } catch {
    rejected = true;
  }

  fs.rmSync(work, { recursive: true, force: true });

  if (!rejected) throw new Error(`negative case accepted: ${name}`);
  console.log(`negative_rejected ${name}`);
}
NODE
fi

printf "\nMK10-PRO v1.0.3 PUBLIC REGISTRY ARTIFACT LOCK: PASS\n"
