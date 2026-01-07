# Verification Guide

## Overview

MK10-PRO verification is **hostile** — no engine, no trust, no authority required.

Any third party can verify an MTB using only public rules and this repository.

## Verification Process

### 1. Load MTB

Load the MTB file (JSON or ZIP):

```bash
mk10 verify --mtb /path/to/mtb.zip
```

Or programmatically:

```python
from mtb.verify import verify_mtb
from pathlib import Path

results = verify_mtb(Path("/path/to/mtb.zip"))
```

### 2. Structure Validation

MTB structure is validated against JSON schema:

- All required sections present
- Types match schema
- Values conform to constraints

### 3. Integrity Proof Verification

The integrity proof is verified:

1. Extract integrity_proof from MTB
2. Remove integrity_proof from MTB
3. Compute canonical JSON hash
4. Compare with stored hash

If hashes match, integrity is proven.

### 4. Evidence Verification

Evidence is verified:

- All events have integrity proofs
- Signatures are valid (if present)
- Timestamps are valid
- Event types are recognized

### 5. Policy Verification

Policy rules are verified:

- All required rules checked
- All rules passed (if strict)
- State transitions are valid

### 6. Validation Verification

Format validations are verified:

- Validations were performed
- Validations passed
- Details are present

## Verification Results

Verification returns:

```json
{
  "valid": true,
  "errors": [],
  "warnings": [],
  "details": {
    "structure": "valid",
    "seal": "valid"
  }
}
```

### Valid MTB

- Structure conforms to schema
- Integrity proof is valid
- All required sections present
- Evidence is complete

### Invalid MTB

- Structure errors
- Integrity proof mismatch
- Missing required sections
- Evidence incomplete

## Standalone Verification

Verification can be performed without the MK10-PRO engine:

```python
# Only requires:
# - MTB file
# - JSON schema
# - Public verification code

from verifier.verify_mtb import verify_mtb
results = verify_mtb(mtb_path)
```

## Trust Model

MK10-PRO verification requires **zero trust**:

- No trusted authority
- No trusted engine
- No trusted keys (for structure verification)

Only cryptographic proofs are trusted:
- Hash integrity
- Signature validity (if present)

## Failure Modes

### Structure Invalid

MTB does not conform to schema:
- Missing required sections
- Invalid types
- Constraint violations

### Integrity Invalid

Integrity proof verification fails:
- Hash mismatch
- Missing integrity_proof
- Invalid algorithm

### Evidence Invalid

Evidence verification fails:
- Missing integrity proofs
- Invalid signatures
- Incomplete events

### Policy Invalid

Policy verification fails:
- Rules not checked
- Rules failed
- Invalid state transitions

## Verification Tools

### CLI

```bash
mk10 verify --mtb /path/to/mtb.zip
```

### Python API

```python
from mtb.verify import verify_mtb
results = verify_mtb(Path("mtb.zip"))
```

### Standalone Script

```bash
python -m verifier.verify_mtb /path/to/mtb.zip
```

## Best Practices

1. **Verify before use** — always verify MTB before accepting as truth
2. **Verify independently** — use standalone verifier when possible
3. **Check warnings** — warnings may indicate issues
4. **Verify regularly** — re-verify archived MTBs periodically
5. **Store verification results** — keep verification evidence

## Security Considerations

- Verification code is public and auditable
- No secrets required for structure verification
- Signatures require public keys (if present)
- Hash algorithms are cryptographically secure

## Limitations

Verification checks:
- ✅ Structure conformance
- ✅ Integrity proof
- ✅ Evidence completeness
- ✅ Policy compliance

Verification does NOT check:
- ❌ File content correctness (only structure)
- ❌ Playback on devices (explicitly excluded)
- ❌ Business logic correctness
- ❌ External dependencies

