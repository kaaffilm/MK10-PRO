# What MK10-PRO Is (and Is Not)

## Problem Solved

MK10-PRO produces **Master Truth Bundles (MTB)** — cryptographically sealed records of audiovisual mastering state. It answers: "What exactly was delivered, and can I prove it?"

## What It Does

- Ingests audiovisual assets and metadata
- Computes deterministic hashes over content
- Records policy checks with evidence
- Seals everything into a verifiable MTB

## What It Does NOT Do

- Store or host files
- Replace QC tools
- Provide human review
- Guarantee content quality
- Handle DRM or encryption

## Example

```bash
pip install mk10-pro
mk10 ingest --manifest manifest.yaml --output bundle/
mk10 verify bundle/mtb.json
```

Output: `VERIFIED` or `FAILED` with reason codes.

## Verification

```bash
mk10 verify mtb.json
```

Deterministic: same input → same hash → same verdict.

## When to Use

- Pre-delivery verification for film/TV
- Audit trail for mastering decisions
- Proof of state at handoff points

## When NOT to Use

- General file hashing (use `sha256sum`)
- CI artifact signing (use Sigstore)
- Blockchain notarization (different trust model)
