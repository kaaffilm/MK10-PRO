<!-- MK10-PRO PACKAGE SURFACES -->

## Public package surfaces

| Surface | Role | Command |
| --- | --- | --- |
| PYPI | Python install and canonical runtime witness | `pip install mk10-pro==1.0.3 && mk10 proof` |
| NPM | Public registry discovery surface | `npm view @kaaffilm/mk10-pro@1.0.3 version` |
| PKG | GitHub Packages registry surface | `npm install @kaaffilm/mk10-pro --registry=https://npm.pkg.github.com` |

Canonical runtime commands:

```bash
mk10 proof
mk10 boundary
mk10 witness
```

MK10-PRO has one source truth: GitHub `main` and signed releases.

NPM and PKG are launcher/discovery surfaces, not canonical runtime witnesses. They do not reimplement MK10-PRO, do not expand its claim boundary, and do not authorize any version raise.

<!-- END MK10-PRO PACKAGE SURFACES -->


<!-- MK10-PRO PUBLIC PACKAGE BOUNDARY -->
## Public package boundary

MK10-PRO has two public surfaces with different authority:

- **GitHub `main`** is the current governed source surface.
- **PyPI `mk10-pro` 1.0.2** is an immutable historical package artifact published before the current source-boundary cleanup.

Current source state:

- Package version: `1.0.2`
- Repository license boundary: `Apache-2.0`
- PyPI publishing: enabled for v1.0.3 through `PYPI_RELEASE_POLICY.md` and Trusted Publishing.
- New package publication must use governed release workflows only.

The existing PyPI 1.0.2 package is historical. PyPI 1.0.3 is the current published witness package. GitHub `main`, signed releases, and package boundary files define the maintained source state.

<!-- END MK10-PRO PUBLIC PACKAGE BOUNDARY -->

<!-- MK10-PRO NO VERSION RAISE LOCK -->
## No-version-raise package lock

MK10-PRO public package surfaces are locked at `1.0.3`.

Do not raise the public package version to repair an immutable registry artifact.

Canonical runtime proof remains:

```bash
pip install mk10-pro==1.0.3
mk10 proof
```

NPM and PKG remain public package surfaces, but they are not the canonical runtime witness.

<!-- END MK10-PRO NO VERSION RAISE LOCK -->

<!-- MK10-PRO 1.0.3 COMPLETION LOCK -->
## MK10-PRO 1.0.3 completion lock

MK10-PRO `1.0.3` is the completed public package surface.

Public surfaces:

```text id="e7qv8p"
PYPI: mk10-pro==1.0.3 — canonical runtime witness
NPM: @kaaffilm/mk10-pro@1.0.3 — public registry discovery surface
PKG: @kaaffilm/mk10-pro@1.0.3 — GitHub Packages surface
````

Final proof:

```bash id="qoq59j"
bash scripts/public-surface-proof.sh
```

No version raise is authorized to repair an immutable registry artifact.

<!-- END MK10-PRO 1.0.3 COMPLETION LOCK -->


<!-- MK10-PRO WITNESS RELEASE SURFACE -->
## Start here

Installed package:

```bash
pip install mk10-pro==1.0.3
mk10 proof
mk10 boundary
mk10 witness
```

Source checkout:

```bash
git clone https://github.com/kaaffilm/MK10-PRO.git
cd MK10-PRO
bash scripts/release-proof.sh
```

Release identity:

```text
MK10-PRO v1.0.3 — Witness Release
```

Success lines:

```text
MK10-PRO PROOF: PASS
MK10-PRO BOUNDARY: PASS
MK10-PRO WITNESS: PASS
MK10-PRO RELEASE PROOF: PASS
```

<!-- END MK10-PRO WITNESS RELEASE SURFACE -->


```
SYS-002
MK10-PRO
Execution index (frozen)

STATUS: REGISTERED
REGISTRY: https://speedkit.eu
SNAPSHOT: https://speedkit.eu/REGISTRY_SNAPSHOT.json
```

Registered system. Identity governed by SPEEDKIT registry.

---

# MK10-PRO v1.0 — Deterministic Pre‑Delivery Truth Infrastructure

> **STATUS:** FINAL / AUTHORITATIVE / CLOSED / FINISHABLE
>
> **SCOPE (HARD BOUNDARY):** Pre‑delivery truth only. Formal playability under declared specifications. No cinema playback. No devices. No operators. No trust. No exceptions.

For scope limits and common misinterpretations, see:
- [CANONICAL.md](CANONICAL.md)
- [ADVERSARIAL_FAQ.md](ADVERSARIAL_FAQ.md)

---

## EXECUTIVE DEFINITION (NON‑MARKETING)

**MK10‑PRO is deterministic audiovisual infrastructure that converts mastering into provable, durable facts instead of trusted outputs.**

If a claim cannot be proven — how a master was produced, what transformed it, which rules governed it, who approved its promotion, or whether it is *formally playable under a declared specification* — MK10‑PRO treats that claim as invalid.

This is not a tool. It is infrastructure.

---

## SYSTEM AXIOMS (IMMUTABLE)

1. **Truth is executable** — claims emerge only from execution.
2. **Evidence is the product** — files are inputs, not outcomes.
3. **Policy is law** — configuration cannot override rules.
4. **Verification is hostile** — no engine, no trust, no authority required.
5. **Determinism is mandatory** — same inputs must yield identical outputs.
6. **Scope ends before institutions** — hardware, venues, operators are out of bounds.

If any axiom is violated, MK10‑PRO is invalid by definition.

---

## QUICK START

```bash
# Install dependencies
pip install -r requirements.txt
# OR
make install

# Ingest source assets
mk10 ingest --source /path/to/assets

# Execute mastering pipeline
mk10 execute --dag pipeline.yaml

# Promote to release
mk10 promote --title "MyTitle" --version "v1.0" --state RELEASE

# Verify an MTB
mk10 verify --mtb /path/to/mtb.zip
```

### Runtime Dependencies

**Required:**
- `pyyaml>=6.0` — YAML parsing (policy rules, config)
- `jsonschema>=4.0` — JSON schema validation (MTB, evidence, ingest)
- `click>=8.0` — CLI framework
- `cryptography>=41.0` — Cryptographic operations
- `pycryptodome>=3.19.0` — Additional crypto support

**Full list:** See `requirements.txt`

---

## THE ACTUAL PRODUCT: MASTER TRUTH BUNDLE (MTB)

Files are not the product.

The **Master Truth Bundle (MTB)** is the product.

An MTB is a sealed, self‑contained, verifiable object that represents a title/version as fact.

If the MTB validates, the title exists.
If it does not, the title is not real.

---

## GOVERNING PROMISE — "NO FILE FALLS AGAIN"

A master is considered safe only if it can always:

1. Be located
2. Be verified
3. Be explained
4. Be reproduced
5. Be proven formally playable under its specification
6. Be re‑delivered without ambiguity

If any condition fails, MK10‑PRO refuses the claim.

---

## LICENSE

See LICENSE file for details.

---

## FINAL AUTHORITY STATEMENT

If MK10‑PRO says a title exists, it exists.
If MK10‑PRO refuses a claim, the claim is invalid.

There is no appeal to trust.
There is only proof.

<!-- MK10-PRO FINAL PUBLIC SURFACE COMPLETION LOCK -->
## v1.0.3 final public surface completion lock

MK10-PRO v1.0.3 is the completed public package surface.

Public surfaces:

| Surface | Status |
| --- | --- |
| PYPI | canonical runtime witness |
| NPM | public registry discovery surface |
| PKG | GitHub Packages package-surface mirror |

Completion lock:

```text
1.0.3
````

Do not raise the public package version to repair an immutable registry artifact.

PyPI remains the canonical runtime witness. NPM and PKG remain public package surfaces only.

<!-- END MK10-PRO FINAL PUBLIC SURFACE COMPLETION LOCK -->





<!-- MK10-PRO PUBLIC REPLAY PERIMETER -->

## MK10-PRO v1.0.3 public replay perimeter

MK10-PRO v1.0.3 is complete only while the public replay perimeter stays locked to `1.0.3`.

Replay surfaces:

```text
PYPI: mk10-pro==1.0.3 — canonical runtime witness
NPM: @kaaffilm/mk10-pro@1.0.3 — public registry discovery surface
PKG: @kaaffilm/mk10-pro@1.0.3 — GitHub Packages surface
```

Replay proof:

```bash
bash scripts/public-replay-proof.sh
```

No public package version may be raised to repair an immutable registry artifact.

PyPI remains the canonical runtime witness. NPM and PKG remain public package surfaces only.

<!-- END MK10-PRO PUBLIC REPLAY PERIMETER -->

<!-- MK10-PRO AUDITOR ENTRYPOINT -->

## MK10-PRO v1.0.3 auditor entrypoint

Public audit starts here:

```bash
bash scripts/auditor-replay-proof.sh
```

The auditor entrypoint confirms:

* source truth remains GitHub `main` and release `v1.0.3`;
* PyPI remains the canonical runtime witness;
* NPM and PKG remain package/discovery surfaces only;
* public package version remains locked at `1.0.3`;
* public surface proof and public replay proof both pass.

Do not raise the public package version to repair an immutable registry artifact.

See:

* [`AUDITOR_START_HERE.md`](AUDITOR_START_HERE.md)
* [`docs/AUDITOR_REPLAY.md`](docs/AUDITOR_REPLAY.md)

<!-- END MK10-PRO AUDITOR ENTRYPOINT -->


<!-- MK10-PRO EXTERNAL AUDIT PACKET -->
## MK10-PRO v1.0.3 external audit packet

External auditor entrypoint:

    bash scripts/audit-packet-proof.sh

This verifies:

- public surface lock
- public replay perimeter
- auditor replay entrypoint
- no-version-raise rule
- PyPI canonical runtime witness
- NPM / PKG public surface boundary

The audit packet does not expand the claim boundary.

<!-- END MK10-PRO EXTERNAL AUDIT PACKET -->

<!-- MK10-PRO AUDIT RECEIPT -->
## MK10-PRO v1.0.3 audit receipt

Machine-readable audit receipt:

    bash scripts/audit-receipt-proof.sh

The receipt proves:

- public surface proof passed
- public replay perimeter passed
- auditor replay entrypoint passed
- external audit packet passed
- version remains 1.0.3
- PyPI remains canonical runtime witness
- NPM and PKG remain non-canonical public package surfaces
- no public package version was raised

The receipt is evidence output, not a new claim surface.

<!-- END MK10-PRO AUDIT RECEIPT -->

<!-- MK10-PRO AUDIT RECEIPT SCHEMA -->
## MK10-PRO v1.0.3 audit receipt schema

Machine-verifiable receipt schema:

    bash scripts/audit-receipt-schema-proof.sh

Standalone receipt verification:

    node scripts/verify-audit-receipt.cjs /path/to/MK10_PRO_AUDIT_RECEIPT.json

This fixes the receipt shape at v1.0.3 and preserves the no-version-raise rule.

<!-- END MK10-PRO AUDIT RECEIPT SCHEMA -->

<!-- MK10-PRO AUDIT RECEIPT NEGATIVE CONTROLS -->
## MK10-PRO v1.0.3 audit receipt negative controls

The audit receipt verifier must reject mutated receipts:

    bash scripts/audit-receipt-negative-proof.sh

Negative cases include version drift, witness drift, NPM canonicalization, failed proof-chain state, invalid hash binding, wrong source release, disabled no-version-raise rule, and claim-boundary expansion.

<!-- END MK10-PRO AUDIT RECEIPT NEGATIVE CONTROLS -->

<!-- MK10-PRO EXTERNAL AUDIT GATE -->
## MK10-PRO v1.0.3 external audit gate

Run the complete external audit surface from one command:

    bash scripts/external-audit-gate.sh

This executes the public surface lock, public replay perimeter, auditor replay entrypoint, external audit packet, audit receipt, audit receipt schema verifier, negative controls, targeted tests, and NPM surface verification.

<!-- END MK10-PRO EXTERNAL AUDIT GATE -->

## Offline audit lock

MK10-PRO v1.0.3 includes an offline audit lock:

```sh
bash scripts/offline-audit-lock.sh
````

This verifier is local/static after checkout. It does not install packages, query npm/PyPI, call GitHub APIs, or promote live registry state to canonical truth.

## v1.0.3 Airgap Audit Bundle

MK10-PRO v1.0.3 now includes an airgap audit bundle.

After checkout, the bundle verifies the local audit perimeter without registry lookup, network fetch, GitHub API access, package installation, or version raise.

Verifier:

    bash scripts/airgap-audit-bundle.sh

## Airgap audit negative controls

MK10-PRO v1.0.3 includes an airgap audit negative-control layer.

It verifies that the airgap audit bundle rejects version drift, missing required evidence, disabled workflow wiring, loss of offline-lock inheritance, and forbidden network or package-install commands after checkout.

```sh
bash scripts/airgap-audit-negative-controls.sh
````


<!-- AIRGAP_NEGATIVE_CONTROLS_README_BOUNDARY_COMPAT -->
Airgap audit bundle
Airgap audit negative controls
Offline audit lock
External audit gate
Audit receipt negative controls
No version raise
<!-- /AIRGAP_NEGATIVE_CONTROLS_README_BOUNDARY_COMPAT -->
## Airgap audit digest lock

The v1.0.3 airgap audit digest lock computes SHA-256 digests for the offline replay perimeter, airgap bundle, and airgap negative controls from repository checkout only.

`sh
bash scripts/airgap-audit-digest-lock.sh
`

## Airgap audit release gate

MK10-PRO v1.0.3 includes an airgap audit release gate.

Run:

```sh
bash scripts/airgap-audit-release-gate.sh
```

This gate replays the offline audit lock, airgap audit bundle, airgap audit negative controls, and airgap audit digest lock from repository checkout without requiring network fetch, registry lookup, or package installation.

## MK10-PRO v1.0.3 public release seal

MK10-PRO v1.0.3 is bound by PUBLIC_RELEASE_SEAL.json and RELEASE_INDEX.json.

The public release seal is discovery and release-gate binding only. It does not mutate package behavior, feature surface, CLI flags, or package version.

Verify:

    bash scripts/public-release-seal.sh

