# MK10-PRO Specification

## Overview

MK10-PRO is deterministic audiovisual infrastructure that converts mastering into provable, durable facts instead of trusted outputs.

## System Axioms

1. **Truth is executable** — claims emerge only from execution.
2. **Evidence is the product** — files are inputs, not outcomes.
3. **Policy is law** — configuration cannot override rules.
4. **Verification is hostile** — no engine, no trust, no authority required.
5. **Determinism is mandatory** — same inputs must yield identical outputs.
6. **Scope ends before institutions** — hardware, venues, operators are out of bounds.

## Execution Model

### DAG-Based Workflows

Work is expressed as a Directed Acyclic Graph (DAG):
- Nodes are pure transformations with no side effects
- Edges define dependencies
- Execution follows topological order
- All inputs and outputs are content-addressed

### Determinism

Same inputs + same engine + same policy = same outputs.

Determinism is enforced through:
- Content addressing of all artifacts
- Immutable execution context
- Pure node transformations
- Evidence recording at every step

### Evidence

Every transformation emits evidence:
- Execution events
- Policy rule checks
- Validation results
- State transitions

All evidence is:
- Cryptographically sealed
- Canonically formatted
- Immutably recorded

## Policy System

Policy is law. Rules cannot be overridden by configuration.

### Rules

Policy rules define mandatory requirements:
- Determinism required
- Evidence required
- Lineage required
- Validation required
- Immutability required
- Playability required

### States

Title/version states:
- **DRAFT** — execution incomplete
- **CANDIDATE** — validation satisfied
- **RELEASE** — policy-approved truth
- **ARCHIVED** — sealed and immutable

State transitions are evidence-gated. Opinion is irrelevant.

## Format Validation

### DCP Validation

DCP validation checks:
- ASSETMAP presence and validity
- PKL presence and validity
- CPL presence and validity
- XML well-formedness
- Schema conformance

**Note:** This validates structural conformance only. Playback on specific devices or venues is explicitly excluded.

## Master Truth Bundle (MTB)

The MTB is the product. Files are inputs, not outcomes.

### MTB Contents

1. **Ingest Manifest** — all source assets with cryptographic hashes
2. **Lineage DAG** — full asset provenance graph
3. **Build Evidence** — deterministic execution records
4. **Policy Evidence** — rules applied and satisfied
5. **Validation Evidence** — formal spec conformance results
6. **Approval & Promotion Events** — state transitions with signers
7. **Integrity Proof** — canonical hash sealing the bundle
8. **Archive Declaration** — fixity and retention intent

### MTB Properties

- **Sealed** — cryptographically bound
- **Self-contained** — all evidence included
- **Verifiable** — can be verified without engine
- **Immutable** — once sealed, cannot be modified

## Verification

MTB verification requires:
- No engine
- No trust
- No authority

Verification checks:
- Structure conformance (JSON schema)
- Integrity proof validity
- Required sections presence
- Evidence completeness

## Governing Promise

"No File Falls Again"

A master is safe only if it can always:
1. Be located
2. Be verified
3. Be explained
4. Be reproduced
5. Be proven formally playable under its specification
6. Be re-delivered without ambiguity

If any condition fails, MK10-PRO refuses the claim.

