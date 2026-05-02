#!/usr/bin/env bash
set -euo pipefail

export PAGER=cat
export GH_PAGER=cat
export GIT_PAGER=cat

REPO="${REPO:-kaaffilm/MK10-PRO}"
PKG="${PKG:-@kaaffilm/mk10-pro}"
VERSION="${VERSION:-1.0.3}"

VERSION_TAG="v1.0.3"
BASE_SEAL_TAG="mk10-pro-v1.0.3-public-registry-install-replay-seal"
WITNESS_TAG="mk10-pro-v1.0.3-public-registry-install-replay-release-object-git-witness-seal"

EXPECTED_VERSION_TARGET="d914996fc84c5370cfba57ee578ea0a06f74d7f3"
EXPECTED_BASE_SEAL_TARGET="3174f958c45944b9c929f5a945532cac9f772edb"
EXPECTED_WITNESS_TARGET="f5a5f1a31482f165267520d4f4ba19423c00cd3b"

EXPECTED_NPM_INTEGRITY="sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ=="
EXPECTED_NPM_SHASUM="6a07a514bfcd91bb434314798334e5fb19959dfb"
EXPECTED_NPM_TARBALL="https://registry.npmjs.org/@kaaffilm/mk10-pro/-/mk10-pro-1.0.3.tgz"

remote_tag_target() {
  local tag="$1"
  local peeled
  peeled="$(git ls-remote --tags origin "refs/tags/${tag}^{}" | awk '{print $1}' | head -n1)"
  if [ -z "$peeled" ]; then
    peeled="$(git ls-remote --tags origin "refs/tags/${tag}" | awk '{print $1}' | head -n1)"
  fi
  printf "%s" "$peeled"
}

printf "[MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY FINALITY INDEX]\n"

test -f PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.json
test -f docs/PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.md

test "$(git rev-parse "${VERSION_TAG}^{commit}")" = "$EXPECTED_VERSION_TARGET"
test "$(git rev-parse "${BASE_SEAL_TAG}^{commit}")" = "$EXPECTED_BASE_SEAL_TARGET"
test "$(git rev-parse "${WITNESS_TAG}^{commit}")" = "$EXPECTED_WITNESS_TARGET"

test "$(remote_tag_target "$VERSION_TAG")" = "$EXPECTED_VERSION_TARGET"
test "$(remote_tag_target "$BASE_SEAL_TAG")" = "$EXPECTED_BASE_SEAL_TARGET"
test "$(remote_tag_target "$WITNESS_TAG")" = "$EXPECTED_WITNESS_TARGET"

test "$(gh pr view 33 --repo "$REPO" --json state,mergeCommit --jq '.state + " " + .mergeCommit.oid')" = "MERGED $EXPECTED_BASE_SEAL_TARGET"
test "$(gh pr view 34 --repo "$REPO" --json state,mergeCommit --jq '.state + " " + .mergeCommit.oid')" = "MERGED $EXPECTED_WITNESS_TARGET"

test "$(gh release view "$BASE_SEAL_TAG" --repo "$REPO" --json tagName,isDraft,isPrerelease --jq '.tagName + " " + (.isDraft|tostring) + " " + (.isPrerelease|tostring)')" = "$BASE_SEAL_TAG false false"
test "$(gh release view "$WITNESS_TAG" --repo "$REPO" --json tagName,isDraft,isPrerelease --jq '.tagName + " " + (.isDraft|tostring) + " " + (.isPrerelease|tostring)')" = "$WITNESS_TAG false false"

NPM_JSON="$(mktemp)"
npm view "$PKG@$VERSION" name version dist.integrity dist.shasum dist.tarball --json > "$NPM_JSON"

node - "$NPM_JSON" "$PKG" "$VERSION" "$EXPECTED_NPM_INTEGRITY" "$EXPECTED_NPM_SHASUM" "$EXPECTED_NPM_TARBALL" <<'NODE'
const fs = require("fs");
const [file, pkg, version, integrity, shasum, tarball] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(file, "utf8"));
function eq(actual, expected, label) {
  if (actual !== expected) throw new Error(`${label}: expected ${expected}, got ${actual}`);
}
eq(data.name, pkg, "name");
eq(data.version, version, "version");
const dist = data.dist || {};
eq(dist.integrity ?? data["dist.integrity"], integrity, "dist.integrity");
eq(dist.shasum ?? data["dist.shasum"], shasum, "dist.shasum");
eq(dist.tarball ?? data["dist.tarball"], tarball, "dist.tarball");
NODE

node <<'NODE'
const fs = require("fs");
const data = JSON.parse(fs.readFileSync("PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX.json", "utf8"));
const required = [
  "artifact",
  "version",
  "package",
  "repository",
  "version_tag",
  "version_tag_target",
  "base_seal_tag",
  "base_seal_target",
  "release_object_git_witness_tag",
  "release_object_git_witness_target",
  "npm_integrity",
  "npm_shasum",
  "npm_tarball",
  "admissibility",
  "forbidden_actions"
];
for (const key of required) {
  if (!(key in data)) throw new Error(`missing finality key: ${key}`);
}
const encoded = JSON.stringify(data).toLowerCase();
for (const forbidden of ["npm publish", "registry write", "tag mutation", "release mutation"]) {
  if (!encoded.includes(forbidden)) throw new Error(`missing forbidden boundary: ${forbidden}`);
}
console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_FINALITY_INDEX_CONTRACT_SHAPE: PASS");
NODE

printf "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY FINALITY INDEX: PASS\n"
