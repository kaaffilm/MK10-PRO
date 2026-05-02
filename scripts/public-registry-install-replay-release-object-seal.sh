#!/usr/bin/env bash
set -euo pipefail

export PAGER=cat
export GH_PAGER=cat
export GIT_PAGER=cat

PKG="@kaaffilm/mk10-pro"
VERSION="1.0.3"
WITNESS="PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.json"

test -f "$WITNESS"
test -f "PUBLIC_REGISTRY_INSTALL_REPLAY.json"
test -f "scripts/public-registry-install-replay.sh"

node <<'NODE'
const fs = require("fs");
const w = JSON.parse(fs.readFileSync("PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL.json", "utf8"));
function assert(cond, msg) { if (!cond) throw new Error(msg); }

assert(w.contract_version === "1.0.3", "bad contract_version");
assert(w.repo === "kaaffilm/MK10-PRO", "bad repo");
assert(w.package === "@kaaffilm/mk10-pro", "bad package");
assert(w.package_version === "1.0.3", "bad package_version");
assert(w.merged_main_head === "3174f958c45944b9c929f5a945532cac9f772edb", "bad merged_main_head");
assert(w.version_tag === "v1.0.3", "bad version_tag");
assert(w.version_tag_target === "d914996fc84c5370cfba57ee578ea0a06f74d7f3", "bad version_tag_target");
assert(w.seal_tag === "mk10-pro-v1.0.3-public-registry-install-replay-seal", "bad seal_tag");
assert(w.seal_tag_target === "3174f958c45944b9c929f5a945532cac9f772edb", "bad seal_tag_target");
assert(w.release_url === "https://github.com/kaaffilm/MK10-PRO/releases/tag/mk10-pro-v1.0.3-public-registry-install-replay-seal", "bad release_url");
assert(w.npm_integrity === "sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ==", "bad npm_integrity");
assert(w.npm_shasum === "6a07a514bfcd91bb434314798334e5fb19959dfb", "bad npm_shasum");
console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL_CONTRACT_SHAPE: PASS");
NODE

git fetch origin main --tags >/dev/null 2>&1 || true

SEAL_TARGET="$(git rev-parse mk10-pro-v1.0.3-public-registry-install-replay-seal^{commit})"
VERSION_TARGET="$(git rev-parse v1.0.3^{commit})"
test "$SEAL_TARGET" = "3174f958c45944b9c929f5a945532cac9f772edb"
test "$VERSION_TARGET" = "d914996fc84c5370cfba57ee578ea0a06f74d7f3"

if command -v gh >/dev/null 2>&1; then
  gh release view mk10-pro-v1.0.3-public-registry-install-replay-seal --repo kaaffilm/MK10-PRO \
    --json tagName,isDraft,isPrerelease,targetCommitish,url \
    > /tmp/mk10-pro-release-object-seal-gh.json

  node <<'NODE'
const fs = require("fs");
const r = JSON.parse(fs.readFileSync("/tmp/mk10-pro-release-object-seal-gh.json", "utf8"));
function assert(cond, msg) { if (!cond) throw new Error(msg); }

assert(r.tagName === "mk10-pro-v1.0.3-public-registry-install-replay-seal", "bad release tagName");
assert(r.targetCommitish === "3174f958c45944b9c929f5a945532cac9f772edb", "bad release targetCommitish");
assert(r.isDraft === false, "release draft");
assert(r.isPrerelease === false, "release prerelease");
assert(r.url === "https://github.com/kaaffilm/MK10-PRO/releases/tag/mk10-pro-v1.0.3-public-registry-install-replay-seal", "bad release url");
console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL_GH_RELEASE_ASSERT: PASS");
NODE
fi

npm view "$PKG@$VERSION" --json > /tmp/mk10-pro-release-object-seal-npm.json

node <<'NODE'
const fs = require("fs");
const n = JSON.parse(fs.readFileSync("/tmp/mk10-pro-release-object-seal-npm.json", "utf8"));
function assert(cond, msg) { if (!cond) throw new Error(msg); }

assert(n.name === "@kaaffilm/mk10-pro", "bad npm name");
assert(n.version === "1.0.3", "bad npm version");
assert(n.dist.integrity === "sha512-1tfocHCucwMzlQ4IABjPNVSgg+mQszlr7F6C9qgVPLqBZk96g/cP8SoZMMXsg++OFqHLoBohU5JYrSC0ER8WpQ==", "bad npm integrity");
assert(n.dist.shasum === "6a07a514bfcd91bb434314798334e5fb19959dfb", "bad npm shasum");
console.log("PUBLIC_REGISTRY_INSTALL_REPLAY_RELEASE_OBJECT_SEAL_NPM_ASSERT: PASS");
NODE

echo "MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY RELEASE OBJECT SEAL: PASS"
