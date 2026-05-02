#!/usr/bin/env bash
set -euo pipefail

REPO="kaaffilm/MK10-PRO"
PKG="@kaaffilm/mk10-pro"
VERSION="1.0.3"

CONTRACT="PUBLIC_REGISTRY_INSTALL_REPLAY_REMOTE_OUTSIDER_FINAL_REPLAY_WITNESS.json"
RECEIPT_PATH="${RECEIPT_PATH:-${TMPDIR:-/tmp}/MK10_PRO_PUBLIC_REGISTRY_INSTALL_REPLAY_REMOTE_OUTSIDER_FINAL_REPLAY_WITNESS_RECEIPT.json}"

FINALITY_TAG="mk10-pro-v1.0.3-public-registry-install-replay-finality-index-seal"
FINALITY_TARGET="420dce9d3c0b144117bfc8c0eee0b02a257939fd"
BASE_SEAL_TAG="mk10-pro-v1.0.3-public-registry-install-replay-seal"
BASE_SEAL_TARGET="3174f958c45944b9c929f5a945532cac9f772edb"
WITNESS_TAG="mk10-pro-v1.0.3-public-registry-install-replay-release-object-git-witness-seal"
WITNESS_TARGET="f5a5f1a31482f165267520d4f4ba19423c00cd3b"
VERSION_TAG="v1.0.3"
VERSION_TARGET="d914996fc84c5370cfba57ee578ea0a06f74d7f3"

NPM_INTEGRITY="sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ=="
NPM_SHASUM="6a07a514bfcd91bb434314798334e5fb19959dfb"
NPM_TARBALL="https://registry.npmjs.org/@kaaffilm/mk10-pro/-/mk10-pro-1.0.3.tgz"

printf "[MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY REMOTE OUTSIDER FINAL REPLAY WITNESS]\n"

node - "$CONTRACT" "$PKG" "$VERSION" "$FINALITY_TAG" "$FINALITY_TARGET" "$BASE_SEAL_TAG" "$BASE_SEAL_TARGET" "$WITNESS_TAG" "$WITNESS_TARGET" "$VERSION_TAG" "$VERSION_TARGET" "$NPM_INTEGRITY" "$NPM_SHASUM" "$NPM_TARBALL" <<'NODE'
const fs = require("fs");
const [
  path, pkg, version,
  finalityTag, finalityTarget,
  baseTag, baseTarget,
  witnessTag, witnessTarget,
  versionTag, versionTarget,
  integrity, shasum, tarball
] = process.argv.slice(2);

const c = JSON.parse(fs.readFileSync(path, "utf8"));
function eq(a, b, k) { if (a !== b) throw new Error(`${k}: ${a} !== ${b}`); }

eq(c.package, pkg, "package");
eq(c.version, version, "version");
eq(c.public_registry_package, `${pkg}@${version}`, "public_registry_package");
eq(c.finality_tag, finalityTag, "finality_tag");
eq(c.finality_target, finalityTarget, "finality_target");
eq(c.base_replay_seal_tag, baseTag, "base_replay_seal_tag");
eq(c.base_replay_seal_target, baseTarget, "base_replay_seal_target");
eq(c.release_object_git_witness_tag, witnessTag, "release_object_git_witness_tag");
eq(c.release_object_git_witness_target, witnessTarget, "release_object_git_witness_target");
eq(c.version_tag, versionTag, "version_tag");
eq(c.version_target, versionTarget, "version_target");
eq(c.npm_integrity, integrity, "npm_integrity");
eq(c.npm_shasum, shasum, "npm_shasum");
eq(c.npm_tarball, tarball, "npm_tarball");

for (const [key, value] of Object.entries(c.mutation_boundary || {})) {
  if (value !== false) throw new Error(`mutation boundary failed: ${key}`);
}

console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_REMOTE_OUTSIDER_FINAL_REPLAY_WITNESS_CONTRACT_SHAPE: PASS");
NODE

if [ "${REMOTE_OUTSIDER_LIVE_REPLAY:-0}" = "1" ]; then
  TMP="$(mktemp -d)"
  git clone "https://github.com/$REPO.git" "$TMP/repo" >/dev/null
  cd "$TMP/repo"
  git fetch origin --tags --force >/dev/null
  git checkout "$FINALITY_TAG" >/dev/null

  test "$(git rev-parse HEAD)" = "$FINALITY_TARGET"
  test "$(git rev-list -n 1 "$FINALITY_TAG")" = "$FINALITY_TARGET"
  test "$(git rev-list -n 1 "$BASE_SEAL_TAG")" = "$BASE_SEAL_TARGET"
  test "$(git rev-list -n 1 "$WITNESS_TAG")" = "$WITNESS_TARGET"
  test "$(git rev-list -n 1 "$VERSION_TAG")" = "$VERSION_TARGET"

  bash scripts/public-registry-install-replay-finality-index.sh

  NPM_JSON="$(mktemp)"
  npm view "$PKG@$VERSION" name version dist.integrity dist.shasum dist.tarball --json > "$NPM_JSON"
  node - "$NPM_JSON" "$PKG" "$VERSION" "$NPM_INTEGRITY" "$NPM_SHASUM" "$NPM_TARBALL" <<'NODE'
const fs = require("fs");
const [path, pkg, version, integrity, shasum, tarball] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(path, "utf8"));
const dist = data.dist || {};
function eq(a, b, k) { if (a !== b) throw new Error(`${k}: ${a} !== ${b}`); }
eq(data.name, pkg, "name");
eq(data.version, version, "version");
eq(dist.integrity ?? data["dist.integrity"], integrity, "dist.integrity");
eq(dist.shasum ?? data["dist.shasum"], shasum, "dist.shasum");
eq(dist.tarball ?? data["dist.tarball"], tarball, "dist.tarball");
console.log("REMOTE_OUTSIDER_NPM_ARTIFACT_ASSERT: PASS");
NODE

  if command -v gh >/dev/null 2>&1 && [ -n "${GH_TOKEN:-}" ]; then
    gh release view "$FINALITY_TAG" --repo "$REPO" >/dev/null
    gh release view "$BASE_SEAL_TAG" --repo "$REPO" >/dev/null
    gh release view "$WITNESS_TAG" --repo "$REPO" >/dev/null
  fi
fi

node - "$RECEIPT_PATH" "$FINALITY_TAG" "$FINALITY_TARGET" "$PKG" "$VERSION" <<'NODE'
const fs = require("fs");
const [path, finalityTag, finalityTarget, pkg, version] = process.argv.slice(2);
fs.writeFileSync(path, JSON.stringify({
  pass: true,
  witness: "remote_outsider_final_replay",
  finality_tag: finalityTag,
  finality_target: finalityTarget,
  package: `${pkg}@${version}`,
  generated_at: new Date().toISOString()
}, null, 2) + "\n");
NODE

printf "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY REMOTE OUTSIDER FINAL REPLAY WITNESS: PASS\n"
