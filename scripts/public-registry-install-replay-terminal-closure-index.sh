#!/usr/bin/env bash
set -euo pipefail

REPO="kaaffilm/MK10-PRO"
PKG="@kaaffilm/mk10-pro"
VERSION="1.0.3"

CONTRACT="PUBLIC_REGISTRY_INSTALL_REPLAY_TERMINAL_CLOSURE_INDEX.json"
RECEIPT_PATH="${RECEIPT_PATH:-${TMPDIR:-/tmp}/MK10_PRO_PUBLIC_REGISTRY_INSTALL_REPLAY_TERMINAL_CLOSURE_INDEX_RECEIPT.json}"

VERSION_TAG="v1.0.3"
BASE_SEAL_TAG="mk10-pro-v1.0.3-public-registry-install-replay-seal"
RELEASE_OBJECT_WITNESS_TAG="mk10-pro-v1.0.3-public-registry-install-replay-release-object-git-witness-seal"
FINALITY_TAG="mk10-pro-v1.0.3-public-registry-install-replay-finality-index-seal"
REMOTE_OUTSIDER_TAG="mk10-pro-v1.0.3-public-registry-install-replay-remote-outsider-final-replay-witness-seal"

VERSION_TARGET="d914996fc84c5370cfba57ee578ea0a06f74d7f3"
BASE_SEAL_TARGET="3174f958c45944b9c929f5a945532cac9f772edb"
RELEASE_OBJECT_WITNESS_TARGET="f5a5f1a31482f165267520d4f4ba19423c00cd3b"
FINALITY_TARGET="420dce9d3c0b144117bfc8c0eee0b02a257939fd"
REMOTE_OUTSIDER_TARGET="d83fa319b82c902d06582eef73589f7c4c9350fd"

NPM_INTEGRITY="sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ=="
NPM_SHASUM="6a07a514bfcd91bb434314798334e5fb19959dfb"
NPM_TARBALL="https://registry.npmjs.org/@kaaffilm/mk10-pro/-/mk10-pro-1.0.3.tgz"

printf "[MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY TERMINAL CLOSURE INDEX]\n"

node - "$CONTRACT" "$PKG" "$VERSION" "$VERSION_TAG" "$VERSION_TARGET" "$BASE_SEAL_TAG" "$BASE_SEAL_TARGET" "$RELEASE_OBJECT_WITNESS_TAG" "$RELEASE_OBJECT_WITNESS_TARGET" "$FINALITY_TAG" "$FINALITY_TARGET" "$REMOTE_OUTSIDER_TAG" "$REMOTE_OUTSIDER_TARGET" "$NPM_INTEGRITY" "$NPM_SHASUM" "$NPM_TARBALL" <<'NODE'
const fs = require("fs");
const [
path, pkg, version,
versionTag, versionTarget,
baseTag, baseTarget,
witnessTag, witnessTarget,
finalityTag, finalityTarget,
remoteTag, remoteTarget,
integrity, shasum, tarball
] = process.argv.slice(2);

const c = JSON.parse(fs.readFileSync(path, "utf8"));
function eq(a,b,k){ if(a !== b) throw new Error(`${k}: ${a} !== ${b}`); }

eq(c.package, pkg, "package");
eq(c.version, version, "version");
eq(c.public_registry_package, `${pkg}@${version}`, "public_registry_package");
eq(c.version_tag, versionTag, "version_tag");
eq(c.version_target, versionTarget, "version_target");
eq(c.base_replay_seal_tag, baseTag, "base_replay_seal_tag");
eq(c.base_replay_seal_target, baseTarget, "base_replay_seal_target");
eq(c.release_object_git_witness_tag, witnessTag, "release_object_git_witness_tag");
eq(c.release_object_git_witness_target, witnessTarget, "release_object_git_witness_target");
eq(c.finality_index_tag, finalityTag, "finality_index_tag");
eq(c.finality_index_target, finalityTarget, "finality_index_target");
eq(c.remote_outsider_final_replay_witness_tag, remoteTag, "remote_outsider_final_replay_witness_tag");
eq(c.remote_outsider_final_replay_witness_target, remoteTarget, "remote_outsider_final_replay_witness_target");
eq(c.npm_integrity, integrity, "npm_integrity");
eq(c.npm_shasum, shasum, "npm_shasum");
eq(c.npm_tarball, tarball, "npm_tarball");

for (const [key, value] of Object.entries(c.mutation_boundary)) {
if (value !== false) throw new Error(`mutation boundary failed: ${key}`);
}

console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_TERMINAL_CLOSURE_INDEX_CONTRACT_SHAPE: PASS");
NODE

if [ "${TERMINAL_CLOSURE_LIVE_REPLAY:-0}" = "1" ]; then
TMP="$(mktemp -d)"
git clone "[https://github.com/$REPO.git](https://github.com/$REPO.git)" "$TMP/repo" >/dev/null
cd "$TMP/repo"
git fetch origin --tags --force >/dev/null
git checkout "$REMOTE_OUTSIDER_TAG" >/dev/null

test "$(git rev-parse HEAD)" = "$REMOTE_OUTSIDER_TARGET"
test "$(git rev-list -n 1 "$VERSION_TAG")" = "$VERSION_TARGET"
test "$(git rev-list -n 1 "$BASE_SEAL_TAG")" = "$BASE_SEAL_TARGET"
test "$(git rev-list -n 1 "$RELEASE_OBJECT_WITNESS_TAG")" = "$RELEASE_OBJECT_WITNESS_TARGET"
test "$(git rev-list -n 1 "$FINALITY_TAG")" = "$FINALITY_TARGET"
test "$(git rev-list -n 1 "$REMOTE_OUTSIDER_TAG")" = "$REMOTE_OUTSIDER_TARGET"

REMOTE_OUTSIDER_LIVE_REPLAY=1 RECEIPT_PATH="$(mktemp)" 
bash scripts/public-registry-install-replay-remote-outsider-final-replay-witness.sh

NPM_JSON="$(mktemp)"
npm view "$PKG@$VERSION" name version dist.integrity dist.shasum dist.tarball --json > "$NPM_JSON"

node - "$NPM_JSON" "$PKG" "$VERSION" "$NPM_INTEGRITY" "$NPM_SHASUM" "$NPM_TARBALL" <<'NODE'
const fs = require("fs");
const [path, pkg, version, integrity, shasum, tarball] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(path, "utf8"));
const dist = data.dist || {};
function eq(a,b,k){ if(a !== b) throw new Error(`${k}: ${a} !== ${b}`); }
eq(data.name, pkg, "name");
eq(data.version, version, "version");
eq(dist.integrity ?? data["dist.integrity"], integrity, "dist.integrity");
eq(dist.shasum ?? data["dist.shasum"], shasum, "dist.shasum");
eq(dist.tarball ?? data["dist.tarball"], tarball, "dist.tarball");
console.log("TERMINAL_CLOSURE_NPM_ARTIFACT_ASSERT: PASS");
NODE

if command -v gh >/dev/null 2>&1 && [ -n "${GH_TOKEN:-}" ]; then
gh release view "$BASE_SEAL_TAG" --repo "$REPO" >/dev/null
gh release view "$RELEASE_OBJECT_WITNESS_TAG" --repo "$REPO" >/dev/null
gh release view "$FINALITY_TAG" --repo "$REPO" >/dev/null
gh release view "$REMOTE_OUTSIDER_TAG" --repo "$REPO" >/dev/null
fi
fi

node - "$RECEIPT_PATH" "$REMOTE_OUTSIDER_TAG" "$REMOTE_OUTSIDER_TARGET" "$PKG" "$VERSION" <<'NODE'
const fs = require("fs");
const [path, tag, target, pkg, version] = process.argv.slice(2);
fs.writeFileSync(path, JSON.stringify({
pass: true,
closure: "terminal_public_registry_install_replay_index",
remote_outsider_final_replay_witness_tag: tag,
remote_outsider_final_replay_witness_target: target,
package: `${pkg}@${version}`,
generated_at: new Date().toISOString()
}, null, 2) + "\n");
NODE

printf "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY TERMINAL CLOSURE INDEX: PASS\n"
