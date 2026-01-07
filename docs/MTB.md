# Master Truth Bundle (MTB)

## Definition

The **Master Truth Bundle (MTB)** is the product of MK10-PRO. Files are inputs, not outcomes.

An MTB is a sealed, self-contained, verifiable object that represents a title/version as fact.

If the MTB validates, the title exists.
If it does not, the title is not real.

## Structure

### Required Sections

#### 1. Ingest Manifest

All source assets with cryptographic hashes:

```json
{
  "assets": [
    {
      "content_address": "abc123def456.mxf",
      "path": "/path/to/source.mxf",
      "hash": "abc123def456...",
      "size": 1234567890,
      "metadata": {}
    }
  ],
  "ingest_timestamp": "2024-01-01T00:00:00Z"
}
```

#### 2. Lineage DAG

Full asset provenance graph:

```json
{
  "nodes": [...],
  "edges": [...],
  "execution_order": ["node1", "node2", "node3"]
}
```

#### 3. Build Evidence

Deterministic execution records:

```json
{
  "execution_id": "exec-123",
  "events": [
    {
      "event_type": "execution_start",
      "timestamp": "...",
      "integrity_proof": {...}
    }
  ]
}
```

#### 4. Policy Evidence

Rules applied and satisfied:

```json
{
  "rule_checks": [
    {
      "rule_id": "determinism_required",
      "passed": true,
      "details": {}
    }
  ]
}
```

#### 5. Validation Evidence

Formal spec conformance results:

```json
{
  "validations": [
    {
      "format_type": "DCP",
      "passed": true,
      "details": {}
    }
  ]
}
```

#### 6. Approval Events

State transitions with signers:

```json
[
  {
    "from_state": "DRAFT",
    "to_state": "CANDIDATE",
    "timestamp": "...",
    "signer": "user@example.com"
  }
]
```

#### 7. Integrity Proof

Canonical hash sealing the bundle:

```json
{
  "algorithm": "sha256",
  "hash": "abc123def456..."
}
```

#### 8. Archive Declaration

Fixity and retention intent:

```json
{
  "declared_at": "2024-01-01T00:00:00Z",
  "intent": "permanent",
  "retention_policy": "indefinite"
}
```

## Sealing

An MTB is sealed by:
1. Computing canonical JSON representation (without integrity_proof)
2. Computing SHA-256 hash
3. Adding integrity_proof section

Once sealed, any modification breaks the seal.

## Verification

MTB verification:
1. Loads MTB structure
2. Validates against JSON schema
3. Verifies integrity proof
4. Checks required sections
5. Validates evidence completeness

Verification requires no engine, no trust, no authority.

## Immutability

Once sealed, an MTB cannot be modified. Any change creates a new identity (new hash).

This ensures:
- Historical integrity
- Auditability
- Non-repudiation

## States

MTB states:
- **DRAFT** — execution incomplete
- **CANDIDATE** — validation satisfied
- **RELEASE** — policy-approved truth
- **ARCHIVED** — sealed and immutable

State is evidence. Opinion is irrelevant.

