#!/usr/bin/env node
"use strict";

const fs = require("fs");

function fail(message) {
  console.error(`AUDIT_RECEIPT_SCHEMA_VERIFY: FAIL: ${message}`);
  process.exit(1);
}

function readJson(path) {
  try {
    return JSON.parse(fs.readFileSync(path, "utf8"));
  } catch (err) {
    fail(`cannot read json ${path}: ${err.message}`);
  }
}

function must(condition, message) {
  if (!condition) fail(message);
}

function isSha256(value) {
  return typeof value === "string" && /^[0-9a-f]{64}$/.test(value);
}

const receiptPath = process.argv[2];
if (!receiptPath) {
  fail("usage: node scripts/verify-audit-receipt.cjs <receipt.json>");
}

const schema = readJson("AUDIT_RECEIPT_SCHEMA.json");
const contract = readJson("AUDIT_RECEIPT_CONTRACT.json");
const surface = readJson("PACKAGE_SURFACES.json");
const pkg = readJson("packages/npm/package.json");
const receipt = readJson(receiptPath);

must(schema.title === "MK10-PRO v1.0.3 Audit Receipt", "schema title drift");
must(contract.locked_version === "1.0.3", "contract lock drift");
must(contract.canonical_runtime_witness === "pypi", "contract witness drift");
must(surface.version === "1.0.3", "surface version drift");
must(surface.version_lock.locked_version === "1.0.3", "surface lock drift");
must(surface.version_lock.canonical_runtime_witness === "pypi", "surface witness drift");
must(pkg.version === "1.0.3", "npm package version drift");

must(receipt.receipt_type === "mk10_pro_v1_0_3_external_audit_receipt", "receipt type drift");
must(receipt.status === "PASS", "receipt status drift");
must(receipt.version === "1.0.3", "receipt version drift");
must(receipt.locked_version === "1.0.3", "receipt lock drift");
must(receipt.canonical_runtime_witness === "pypi", "receipt witness drift");
must(receipt.no_version_raise === true, "no-version-raise drift");

must(receipt.source_truth.repository === "kaaffilm/MK10-PRO", "source repository drift");
must(receipt.source_truth.branch === "main", "source branch drift");
must(receipt.source_truth.release === "v1.0.3", "source release drift");

must(receipt.package_surfaces.pypi.package === "mk10-pro", "pypi package drift");
must(receipt.package_surfaces.pypi.version === "1.0.3", "pypi version drift");
must(receipt.package_surfaces.pypi.role === "canonical runtime witness", "pypi role drift");

must(receipt.package_surfaces.npm.package === "@kaaffilm/mk10-pro", "npm package drift");
must(receipt.package_surfaces.npm.version === "1.0.3", "npm version drift");
must(receipt.package_surfaces.npm.runtime_boundary === "not_canonical_runtime_witness", "npm boundary drift");

must(receipt.package_surfaces.pkg.package === "@kaaffilm/mk10-pro", "pkg package drift");
must(receipt.package_surfaces.pkg.version === "1.0.3", "pkg version drift");
must(receipt.package_surfaces.pkg.runtime_boundary === "not_canonical_runtime_witness", "pkg boundary drift");

for (const [name, state] of Object.entries(receipt.proof_chain || {})) {
  must(state === "PASS", `proof chain ${name} drift`);
}
for (const key of [
  "public_surface_proof",
  "public_replay_perimeter",
  "auditor_replay_entrypoint",
  "external_audit_packet"
]) {
  must(receipt.proof_chain[key] === "PASS", `missing proof ${key}`);
}

for (const key of [
  "audit_receipt_contract_sha256",
  "package_surfaces_sha256",
  "audit_packet_sha256",
  "public_surface_sha256",
  "auditor_start_here_sha256"
]) {
  must(isSha256(receipt.files[key]), `invalid sha256 ${key}`);
}

must(receipt.claim_boundary.claim === "deterministic_pre_delivery_truth_infrastructure", "claim drift");
for (const excluded of [
  "playback",
  "device compatibility",
  "venue certification",
  "operator trustworthiness",
  "post-delivery behavior",
  "business outcome"
]) {
  must(receipt.claim_boundary.does_not_verify.includes(excluded), `missing exclusion ${excluded}`);
}

console.log("AUDIT_RECEIPT_SCHEMA_VERIFY: PASS");
