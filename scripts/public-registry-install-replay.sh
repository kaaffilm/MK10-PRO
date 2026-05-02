#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.3"
PKG="@kaaffilm/mk10-pro"
REGISTRY="https://registry.npmjs.org"

copy_repo_clean_for_negative_control() {
  dest="$1"
  rm -rf "$dest"
  mkdir -p "$dest"

  (
    tar \
      --exclude='./.git' \
      --exclude='./.venv' \
      --exclude='./build' \
      --exclude='./dist' \
      --exclude='./mk10_pro.egg-info' \
      --exclude='./.pytest_cache' \
      --exclude='./node_modules' \
      --exclude='./packages/npm/node_modules' \
      --exclude='./*.tgz' \
      --exclude='./packages/npm/*.tgz' \
      --exclude='./MK10_PRO_PUBLIC_REGISTRY_INSTALL_REPLAY_RECEIPT.json' \
      --exclude='./MK10_PRO_PUBLIC_REGISTRY_ARTIFACT_LOCK_RECEIPT.json' \
      --exclude='./MK10_PRO_PUBLIC_REGISTRY_RELEASE_READINESS_RECEIPT.json' \
      --exclude='./MK10_PRO_PUBLIC_PACKAGE_INSTALL_REPLAY_RECEIPT.json' \
      --exclude='./MK10_PRO_PUBLIC_RELEASE_SEAL_RECEIPT.json' \
      -cf - .
  ) | (
    cd "$dest"
    tar -xf -
  )

  test -f "$dest/packages/npm/package.json"
  test -f "$dest/PUBLIC_REGISTRY_INSTALL_REPLAY.json"
  test -f "$dest/PUBLIC_REGISTRY_ARTIFACT_LOCK.json"
  test -f "$dest/scripts/public-registry-install-replay.sh"
}

echo "[MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY]"

node <<'NODE'
const fs = require("fs");

function readJson(path) {
return JSON.parse(fs.readFileSync(path, "utf8"));
}
function readIfExists(file) { try { return fs.readFileSync(file, "utf8"); } catch { return ""; } }
function fail(msg) {
throw new Error(msg);
}

const contract = readJson("PUBLIC_REGISTRY_INSTALL_REPLAY.json");
const artifact = readJson("PUBLIC_REGISTRY_ARTIFACT_LOCK.json");
const readiness = readJson("PUBLIC_REGISTRY_RELEASE_READINESS.json");
const localReplay = readJson("PUBLIC_PACKAGE_INSTALL_REPLAY.json");
const releaseSeal = readJson("PUBLIC_RELEASE_SEAL.json");
const manifest = fs.readFileSync("MANIFEST.in", "utf8");
const workflow = fs.readFileSync(".github/workflows/public-registry-install-replay.yml", "utf8");
const script = fs.readFileSync("scripts/public-registry-install-replay.sh", "utf8");
const pkg = readJson("packages/npm/package.json");

if (contract.version !== "1.0.3") fail("contract version mismatch");
if (contract.package !== "@kaaffilm/mk10-pro") fail("contract package mismatch");
if (contract.install_spec !== "@kaaffilm/mk10-pro@1.0.3") fail("install spec mismatch");

if (artifact.registry_version !== "1.0.3") fail("artifact lock registry version mismatch");
if (readiness.version !== "1.0.3") fail("readiness version mismatch");
if (localReplay.version !== "1.0.3") fail("local replay version mismatch");
if (releaseSeal.package_version !== "1.0.3") fail("release seal version mismatch");
if (pkg.version !== "1.0.3") fail("npm package version mismatch");

for (const required of contract.required_chain) {
if (!fs.existsSync(required)) fail(`required chain file missing: ${required}`);
}

for (const required of [
"PUBLIC_REGISTRY_INSTALL_REPLAY.json",
"docs/PUBLIC_REGISTRY_INSTALL_REPLAY.md",
"scripts/public-registry-install-replay.sh",
"tests/test_public_registry_install_replay.py",
".github/workflows/public-registry-install-replay.yml"
]) {
if (!manifest.includes(required)) fail(`MANIFEST missing ${required}`);
}

if (!workflow.includes("scripts/public-registry-install-replay.sh")) fail("workflow missing replay script");
if (!script.includes("npm install")) fail("script missing public registry install");
// PUBLIC_REGISTRY_INSTALL_REPLAY_NPM_PACK_GUARD_BEGIN
const executableScriptLines = script
  .split(/\n/)
  .map((line) => line.trim())
  .filter((line) => line && !line.startsWith("#") && !line.includes("script must not use local npm pack"));
if (executableScriptLines.some((line) => line === "npm pack" || line.startsWith("npm pack ") || line.includes(" npm pack "))) fail("script must not use local npm pack");
// PUBLIC_REGISTRY_INSTALL_REPLAY_NPM_PACK_GUARD_END
// PUBLIC_REGISTRY_INSTALL_REPLAY_LOCAL_TGZ_GUARD_BEGIN
const localTarballInstallFragments = [
  "npm install ./",
  "npm install ../",
  "npm install packages/npm/",
  "npm i ./",
  "npm i ../",
  "npm i packages/npm/"
];
// PUBLIC_REGISTRY_INSTALL_REPLAY_LOCAL_TARBALL_GUARD_BEGIN
const shellCommandLinesForTarballGuard = script
  .split(/\n/)
  .map((line) => line.trim())
  .filter((line) => line && !line.startsWith("#"));
const localTarballInstall = shellCommandLinesForTarballGuard.some((line) =>
  /^npm\s+(?:install|i)\b/.test(line) &&
  (line.includes(".tgz") || line.includes("file:") || line.includes("./") || line.includes("../") || line.includes("packages/npm/"))
);
if (localTarballInstall) fail("script must not use local tarball substitution");
// PUBLIC_REGISTRY_INSTALL_REPLAY_LOCAL_TARBALL_GUARD_END
// PUBLIC_REGISTRY_INSTALL_REPLAY_LOCAL_TGZ_GUARD_END

console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_CONTRACT_SHAPE: PASS");
NODE

echo
echo "[CHAIN: PUBLIC REGISTRY ARTIFACT LOCK]"
bash scripts/public-registry-artifact-lock.sh

WORK="$(mktemp -d "${TMPDIR:-/tmp}/mk10-pro-public-registry-install-replay.XXXXXX")"
CONSUMER="$WORK/consumer"
mkdir -p "$CONSUMER"

cp PUBLIC_REGISTRY_ARTIFACT_LOCK.json "$WORK/PUBLIC_REGISTRY_ARTIFACT_LOCK.json"

echo
echo "[CLEAN PUBLIC REGISTRY CONSUMER INSTALL]"
(
cd "$CONSUMER"
npm init -y >/dev/null
npm install "$PKG@$VERSION" --registry "$REGISTRY" --ignore-scripts --no-audit --fund=false
)

echo
echo "[ASSERT INSTALLED PUBLIC REGISTRY ARTIFACT]"
CONSUMER="$CONSUMER" node <<'NODE'
const fs = require("fs");
const path = require("path");
const cp = require("child_process");

function readJson(pathname) {
return JSON.parse(fs.readFileSync(pathname, "utf8"));
}
function fail(msg) {
throw new Error(msg);
}

const consumer = process.env.CONSUMER;
const lock = readJson(path.join(path.dirname(consumer), "PUBLIC_REGISTRY_ARTIFACT_LOCK.json"));
const installedRoot = path.join(consumer, "node_modules", "@kaaffilm", "mk10-pro");

function readIfExists(file) { try { return fs.readFileSync(file, "utf8"); } catch { return ""; } }
const installedReadme = readIfExists(path.join(installedRoot, "README.md"));
const installedSurfaceText = readIfExists(path.join(installedRoot, "PACKAGE_SURFACES.json"));
const installedPackageText = fs.readFileSync(path.join(installedRoot, "package.json"), "utf8");
const installedCombinedSurface = [installedReadme, installedSurfaceText, installedPackageText].join("\n");
if (!installedCombinedSurface.includes("@kaaffilm/mk10-pro") || !installedCombinedSurface.includes("1.0.3")) fail("installed package missing npm pin");

const installedPkg = readJson(path.join(installedRoot, "package.json"));
const packageLock = readJson(path.join(consumer, "package-lock.json"));
const lockedDep = packageLock.packages["node_modules/@kaaffilm/mk10-pro"];

if (!lockedDep) fail("package-lock missing installed dependency");
if (installedPkg.name !== "@kaaffilm/mk10-pro") fail(`installed name drift: ${installedPkg.name}`);
if (installedPkg.version !== "1.0.3") fail(`installed version drift: ${installedPkg.version}`);
if (lockedDep.version !== "1.0.3") fail(`package-lock version drift: ${lockedDep.version}`);
if (lockedDep.integrity !== lock.registry_integrity) fail("installed integrity mismatch");
if (lockedDep.resolved !== lock.registry_tarball) fail("installed tarball mismatch");

const binRel = typeof installedPkg.bin === "string"
? installedPkg.bin
: installedPkg.bin && installedPkg.bin["mk10-pro"];

if (!binRel) fail("installed package missing mk10-pro bin");

const binPath = path.join(installedRoot, binRel);
if (!fs.existsSync(binPath)) fail("installed bin file missing");

const out = cp.execFileSync(process.execPath, [binPath], { encoding: "utf8" });
if (!out.includes("mk10-pro==1.0.3")) fail("installed bin missing PyPI pin");

console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_INSTALLED_ARTIFACT_ASSERT: PASS");
console.log(`installed=${installedPkg.name}@${installedPkg.version}`);
console.log(`integrity=${lockedDep.integrity}`);
console.log(`resolved=${lockedDep.resolved}`);
NODE

node <<'NODE'
const fs = require("fs");

const receipt = {
receipt: "MK10-PRO v1.0.3 public registry install replay",
version: "1.0.3",
package: "@kaaffilm/mk10-pro",
install_spec: "@kaaffilm/mk10-pro@1.0.3",
registry: "https://registry.npmjs.org",
status: "PASS",
generated_at: new Date().toISOString()
};

fs.writeFileSync("MK10_PRO_PUBLIC_REGISTRY_INSTALL_REPLAY_RECEIPT.json", JSON.stringify(receipt, null, 2) + "\n");
NODE

if [ "${SKIP_PUBLIC_REGISTRY_INSTALL_REPLAY_NEGATIVE_CONTROLS:-0}" != "1" ]; then
echo
echo "[NEGATIVE CONTROLS]"
POS="$WORK/positive"
mkdir -p "$POS"
copy_repo_clean_for_negative_control "$WORK"

POS="$POS" node <<'NODE'
const fs = require("fs");
const path = require("path");
const cp = require("child_process");

const pos = process.env.POS;
const base = path.dirname(pos);


const work = fs.mkdtempSync(path.join(require("os").tmpdir(), "mk10-pro-public-registry-install-replay."));
function copyCase(name) {
  const positiveRoot = path.join(work, "positive");

  if (!fs.existsSync(positiveRoot)) {
    fs.cpSync(process.cwd(), positiveRoot, {
      recursive: true,
      dereference: false,
      filter: (src) => {
        const rel = path.relative(process.cwd(), src);
        if (!rel) return true;
        const base = path.basename(rel);
        const parts = rel.split(path.sep);
        if (parts.includes(".git")) return false;
        if (parts.includes(".venv")) return false;
        if (parts.includes("node_modules")) return false;
        if (parts.includes("__pycache__")) return false;
        if (parts.includes(".pytest_cache")) return false;
        if (parts.includes("build")) return false;
        if (parts.includes("dist")) return false;
        if (parts.includes("mk10_pro.egg-info")) return false;
        if (base.endsWith(".tgz")) return false;
        if (/^MK10_PRO_.*_RECEIPT\\.json$/.test(base)) return false;
        return true;
      }
    });

    for (const required of [
      "PUBLIC_REGISTRY_INSTALL_REPLAY.json",
      "PUBLIC_REGISTRY_ARTIFACT_LOCK.json",
      "PUBLIC_REGISTRY_RELEASE_READINESS.json",
      "PUBLIC_PACKAGE_INSTALL_REPLAY.json",
      "PUBLIC_RELEASE_SEAL.json",
      "packages/npm/package.json",
      "scripts/public-registry-install-replay.sh",
      ".github/workflows/public-registry-install-replay.yml"
    ]) {
      if (!fs.existsSync(path.join(positiveRoot, required))) {
        throw new Error("positive snapshot missing " + required);
      }
    }

    console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_POSITIVE_SNAPSHOT_CREATED: PASS");
  }

  const dir = path.join(work, name);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.cpSync(positiveRoot, dir, { recursive: true, dereference: false });
  return dir;
}

function readJson(dir, rel) {
return JSON.parse(fs.readFileSync(path.join(dir, rel), "utf8"));
}

function writeJson(dir, rel, data) {
fs.writeFileSync(path.join(dir, rel), JSON.stringify(data, null, 2) + "\n");
}

function mutateText(dir, rel, fn) {
const p = path.join(dir, rel);
fs.writeFileSync(p, fn(fs.readFileSync(p, "utf8")));
}

function expectReject(name, mutate) {
const dir = copyCase(name);
mutate(dir);
try {
cp.execFileSync("bash", ["scripts/public-registry-install-replay.sh"], {
cwd: dir,
env: { ...process.env, SKIP_PUBLIC_REGISTRY_INSTALL_REPLAY_NEGATIVE_CONTROLS: "1" },
stdio: "pipe",
timeout: 120000
});
throw new Error(`negative control unexpectedly passed: ${name}`);
} catch (err) {
if (String(err.message).includes("unexpectedly passed")) throw err;
console.log(`negative_rejected ${name}`);
}
}

expectReject("public_registry_install_replay_removed", dir => fs.rmSync(path.join(dir, "PUBLIC_REGISTRY_INSTALL_REPLAY.json"), { force: true }));
expectReject("public_registry_artifact_lock_removed", dir => fs.rmSync(path.join(dir, "PUBLIC_REGISTRY_ARTIFACT_LOCK.json"), { force: true }));
expectReject("public_registry_release_readiness_removed", dir => fs.rmSync(path.join(dir, "PUBLIC_REGISTRY_RELEASE_READINESS.json"), { force: true }));
expectReject("script_removed", dir => fs.rmSync(path.join(dir, "scripts/public-registry-install-replay.sh"), { force: true }));
expectReject("workflow_removed", dir => fs.rmSync(path.join(dir, ".github/workflows/public-registry-install-replay.yml"), { force: true }));
expectReject("npm_package_version_raised", dir => {
const pkg = readJson(dir, "packages/npm/package.json");
pkg.version = "1.0.4";
writeJson(dir, "packages/npm/package.json", pkg);
});
expectReject("registry_integrity_tampered", dir => {
const lock = readJson(dir, "PUBLIC_REGISTRY_ARTIFACT_LOCK.json");
lock.registry_integrity = `${lock.registry_integrity}.tampered`;
writeJson(dir, "PUBLIC_REGISTRY_ARTIFACT_LOCK.json", lock);
});
expectReject("registry_tarball_tampered", dir => {
const lock = readJson(dir, "PUBLIC_REGISTRY_ARTIFACT_LOCK.json");
lock.registry_tarball = lock.registry_tarball.replace("1.0.3", "1.0.4");
writeJson(dir, "PUBLIC_REGISTRY_ARTIFACT_LOCK.json", lock);
});
expectReject("manifest_missing_registry_install_replay", dir => {
mutateText(dir, "MANIFEST.in", text => text.replace(/^include PUBLIC_REGISTRY_INSTALL_REPLAY.json\n/m, ""));
});
NODE
fi

echo
echo "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY: PASS"
