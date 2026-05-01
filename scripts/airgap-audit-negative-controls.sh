#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT="${OUT:-$(mktemp -d /tmp/mk10-pro-airgap-negative-controls.XXXXXX)}"
mkdir -p "$OUT"

printf "\n[MK10-PRO v1.0.3 AIRGAP AUDIT NEGATIVE CONTROLS]\n"

node <<'NODE'
const fs = require("fs");
const path = require("path");
const os = require("os");
const cp = require("child_process");

const root = process.cwd();
const LOCKED_VERSION = "1.0.3";

const required = [
"pyproject.toml",
"README.md",
"MANIFEST.in",
"packages/npm/package.json",
"packages/npm/PACKAGE_SURFACES.json",
"AIRGAP_AUDIT_BUNDLE.json",
"AIRGAP_AUDIT_NEGATIVE_CONTROLS.json",
"OFFLINE_AUDIT_LOCK.json",
"EXTERNAL_AUDIT_GATE.json",
"docs/AIRGAP_AUDIT_BUNDLE.md",
"docs/AIRGAP_AUDIT_NEGATIVE_CONTROLS.md",
"scripts/airgap-audit-bundle.sh",
"scripts/airgap-audit-negative-controls.sh",
"scripts/offline-audit-lock.sh",
"tests/test_airgap_audit_bundle.py",
"tests/test_airgap_audit_negative_controls.py",
".github/workflows/airgap-audit-bundle.yml",
".github/workflows/airgap-audit-negative-controls.yml"
];

const forbiddenPatterns = [
/\bcurl\b/,
/\bwget\b/,
/\bgh\s+api\b/,
/\bgh\s+pr\b/,
/\bgit\s+fetch\b/,
/\bgit\s+pull\b/,
/\bgit\s+clone\b/,
/\bnpm\s+install\b/,
/\bnpm\s+ci\b/,
/\bpip\s+install\b/,
/\bpython\s+-m\s+pip\b/
];

function read(rel, base = root) {
return fs.readFileSync(path.join(base, rel), "utf8");
}

function exists(rel, base = root) {
return fs.existsSync(path.join(base, rel));
}

function parseJson(rel, base = root) {
return JSON.parse(read(rel, base));
}

function assertTree(base) {
for (const rel of required) {
if (!exists(rel, base)) throw new Error(`missing required file: ${rel}`);
}

const pkg = parseJson("packages/npm/package.json", base);
if (pkg.version !== LOCKED_VERSION) throw new Error(`npm version drift: ${pkg.version}`);

const pyproject = read("pyproject.toml", base);
if (!pyproject.includes(`version = "${LOCKED_VERSION}"`)) {
throw new Error("pyproject version drift");
}

const bundle = parseJson("AIRGAP_AUDIT_BUNDLE.json", base);
if (bundle.version !== LOCKED_VERSION) throw new Error("airgap bundle version drift");
if (bundle.lock !== "AIRGAP_AUDIT_BUNDLE") throw new Error("airgap bundle lock drift");

const neg = parseJson("AIRGAP_AUDIT_NEGATIVE_CONTROLS.json", base);
if (neg.version !== LOCKED_VERSION) throw new Error("negative control version drift");
if (neg.lock !== "AIRGAP_AUDIT_NEGATIVE_CONTROLS") throw new Error("negative control lock drift");
if (neg.no_version_raise !== true) throw new Error("negative control version raise boundary weakened");
if (!Array.isArray(neg.negative_cases) || neg.negative_cases.length < 10) {
throw new Error("negative case set weakened");
}

const airgapScript = read("scripts/airgap-audit-bundle.sh", base);
if (!airgapScript.includes("OFFLINE_AUDIT_LOCK")) {
throw new Error("airgap script no longer inherits offline audit lock");
}
if (!airgapScript.includes("MK10-PRO v1.0.3 AIRGAP AUDIT BUNDLE: PASS")) {
throw new Error("airgap script pass boundary missing");
}

for (const pattern of forbiddenPatterns) {
if (pattern.test(airgapScript)) {
throw new Error(`forbidden command present in airgap script: ${pattern}`);
}
}

const workflow = read(".github/workflows/airgap-audit-bundle.yml", base);
if (!workflow.includes("bash scripts/airgap-audit-bundle.sh")) {
throw new Error("airgap workflow no longer runs verifier");
}

const negWorkflow = read(".github/workflows/airgap-audit-negative-controls.yml", base);
if (!negWorkflow.includes("bash scripts/airgap-audit-negative-controls.sh")) {
throw new Error("negative-control workflow no longer runs verifier");
}

const readme = read("README.md", base);
if (!readme.includes("Airgap audit bundle")) throw new Error("README missing airgap audit bundle boundary");
if (!readme.includes("Airgap audit negative controls")) throw new Error("README missing airgap negative controls boundary");
}

function copyTree(dst) {
for (const rel of required) {
const src = path.join(root, rel);
const target = path.join(dst, rel);
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.copyFileSync(src, target);
}
}

function mutateJson(file, base, mutator) {
const p = path.join(base, file);
const data = JSON.parse(fs.readFileSync(p, "utf8"));
mutator(data);
fs.writeFileSync(p, JSON.stringify(data, null, 2) + "\n");
}

function mutateText(file, base, mutator) {
const p = path.join(base, file);
fs.writeFileSync(p, mutator(fs.readFileSync(p, "utf8")));
}

const cases = {
airgap_contract_version_raised(base) {
mutateJson("AIRGAP_AUDIT_BUNDLE.json", base, d => { d.version = "1.0.4"; });
},
npm_package_version_raised(base) {
mutateJson("packages/npm/package.json", base, d => { d.version = "1.0.4"; });
},
pyproject_version_raised(base) {
mutateText("pyproject.toml", base, s => s.replace('version = "1.0.3"', 'version = "1.0.4"'));
},
airgap_contract_removed(base) {
fs.rmSync(path.join(base, "AIRGAP_AUDIT_BUNDLE.json"));
},
airgap_script_removed(base) {
fs.rmSync(path.join(base, "scripts/airgap-audit-bundle.sh"));
},
offline_lock_script_removed(base) {
fs.rmSync(path.join(base, "scripts/offline-audit-lock.sh"));
},
workflow_run_removed(base) {
mutateText(".github/workflows/airgap-audit-bundle.yml", base, s => s.replace("bash scripts/airgap-audit-bundle.sh", "echo skipped"));
},
forbidden_curl_added(base) {
mutateText("scripts/airgap-audit-bundle.sh", base, s => s + "\ncurl [https://example.invalid\n](https://example.invalid\n)");
},
forbidden_git_fetch_added(base) {
mutateText("scripts/airgap-audit-bundle.sh", base, s => s + "\ngit fetch origin main\n");
},
forbidden_package_install_added(base) {
mutateText("scripts/airgap-audit-bundle.sh", base, s => s + "\nnpm install\n");
}
};

assertTree(root);

for (const [name, mutate] of Object.entries(cases)) {
const dir = fs.mkdtempSync(path.join(os.tmpdir(), `mk10-airgap-negative-${name}-`));
copyTree(dir);
mutate(dir);
let rejected = false;
try {
assertTree(dir);
} catch {
rejected = true;
}
if (!rejected) throw new Error(`negative control was not rejected: ${name}`);
console.log(`negative_rejected ${name}`);
}

console.log("AIRGAP_AUDIT_NEGATIVE_CONTROLS_NODE_ASSERT: PASS");
NODE

POSITIVE_OUT="$OUT/positive"
mkdir -p "$POSITIVE_OUT"
OUT="$POSITIVE_OUT" bash scripts/airgap-audit-bundle.sh

printf "\nMK10-PRO v1.0.3 AIRGAP AUDIT NEGATIVE CONTROLS: PASS\n"
