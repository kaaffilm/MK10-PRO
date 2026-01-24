# Hostile Verification Summary
## Third-Party Verification Checklist

**Trust Model:** Zero trust. Only cryptographic proofs and public repository code.

---

## VERIFICATION STEPS (12 Total)

### Step 1: MTB Load and Parse
- Load MTB file (JSON or ZIP)
- Parse JSON structure
- **Failure**: JSON parse error, file unreadable

### Step 2: Schema Structure Validation
- Validate against JSON Schema (Draft 7)
- Check 12 required fields present
- Validate field types and enums
- Validate nested structures (8 nested objects)
- **Failure**: Missing field, wrong type, invalid enum, empty required array

### Step 3: Integrity Proof Verification
- Extract integrity_proof
- Remove integrity_proof from MTB
- Compute canonical JSON (sorted keys, no whitespace)
- Compute SHA-256 hash
- Compare with stored hash
- **Failure**: Missing proof, hash mismatch, unsupported algorithm

### Step 4: Evidence Integrity Verification
- For each event in build_evidence.events:
  - Verify integrity_proof present
  - Remove integrity_proof from event
  - Compute canonical JSON hash
  - Compare with stored hash
- Verify event types and order
- **Failure**: Missing proof, hash mismatch, missing event type, execution_failure present

### Step 5: Lineage DAG Verification
- Verify DAG structure (nodes, edges, execution_order)
- Check for cycles (must be acyclic)
- Verify execution_order matches topological sort
- Verify all outputs trace to ingest
- **Failure**: Cycle detected, orphan output, missing dependency

### Step 6: Policy Evidence Verification
- Load policy rules from repository
- Verify all rules have checks
- Verify all checks passed (100% pass rate required)
- **Failure**: Missing rule check, rule failed, invalid rule ID

### Step 7: Validation Evidence Verification
- Extract all validations
- Verify all validations passed (100% pass rate required)
- Verify validation structure
- **Failure**: Validation failed, missing format_type, missing details

### Step 8: State Transition Verification
- Verify state transitions are valid
- Check transition requirements met
- Verify signatures (if required for RELEASE)
- **Failure**: Invalid transition, missing signature, invalid signature

### Step 9: Content Address Verification
- Extract all content addresses
- Verify format: `{hash_hex}{extension}`
- Verify hash is hexadecimal (64 chars for SHA-256)
- **Failure**: Invalid format, invalid hash length, non-hex hash

### Step 10: Determinism Verification
- Verify execution_id is deterministic format
- Verify execution order is deterministic
- **Failure**: Execution ID not deterministic, order non-deterministic

### Step 11: Ingest Manifest Verification
- Verify all assets have required fields
- Verify hash matches content_address
- Verify size is valid
- **Failure**: Missing field, hash mismatch, invalid size

### Step 12: Final Comprehensive Check
- Verify all required sections present and non-empty
- Check for evidence contradictions
- Re-verify integrity proof
- **Failure**: Section missing/empty, contradiction, seal fails

---

## HASH COMPUTATIONS

### Total Hash Operations:

1. **MTB Integrity Proof**: 1 hash
   - Algorithm: SHA-256 (or declared algorithm)
   - Input: Canonical JSON of MTB (without integrity_proof)
   - Output: 64-character hex string

2. **Evidence Events**: N hashes (N = number of events)
   - Algorithm: SHA-256 (per event integrity_proof)
   - Input: Canonical JSON of each event (without integrity_proof)
   - Output: 64-character hex string per event

3. **Signature Verifications**: M verifications (M = number of signatures)
   - Algorithm: RSA-PSS-SHA256
   - Input: Canonical JSON of signed data
   - Output: Boolean (signature valid/invalid)

**Total**: 1 + N + M cryptographic operations

---

## SCHEMA CHECKS

### Top-Level Required Fields (12):
1. `mtb_version` - String
2. `title` - String
3. `version` - String
4. `state` - Enum: ["DRAFT", "CANDIDATE", "RELEASE", "ARCHIVED"]
5. `ingest_manifest` - Object
6. `lineage_dag` - Object
7. `build_evidence` - Object
8. `policy_evidence` - Object
9. `validation_evidence` - Object
10. `approval_events` - Array
11. `integrity_proof` - Object
12. `archive_declaration` - Object

### Nested Required Fields:

#### ingest_manifest:
- `assets` - Array (non-empty)
- `ingest_timestamp` - String
- Each asset: `content_address`, `path`, `hash`, `size`

#### lineage_dag:
- `nodes` - Array
- `edges` - Array
- `execution_order` - Array of strings

#### build_evidence:
- `execution_id` - String (non-empty)
- `events` - Array (non-empty)

#### policy_evidence:
- `rule_checks` - Array
- Each check: `rule_id`, `passed`

#### validation_evidence:
- `validations` - Array
- Each validation: `format_type`, `passed`

#### approval_events:
- Array of objects
- Each event: `from_state`, `to_state`, `timestamp`

#### integrity_proof:
- `algorithm` - String
- `hash` - String (non-empty, hex)

#### archive_declaration:
- `declared_at` - String
- `intent` - String

---

## FAILURE CONDITIONS

### Critical Failures (Claim Invalidated):

1. **Structure Invalid**
   - Missing required field
   - Wrong type
   - Invalid enum value
   - Empty required array

2. **Integrity Proof Invalid**
   - Missing integrity_proof
   - Hash mismatch
   - Unsupported algorithm

3. **Evidence Invalid**
   - Event missing integrity_proof
   - Event hash mismatch
   - Missing execution_start
   - Missing execution_complete
   - execution_failure present

4. **Lineage Invalid**
   - Cycle detected
   - Orphan output
   - Missing dependency

5. **Policy Violation**
   - Missing rule check
   - Rule failed
   - Invalid rule ID

6. **Validation Failed**
   - Format validation failed
   - Missing format_type
   - Missing details

7. **State Transition Invalid**
   - Invalid transition
   - Missing signature (for RELEASE)
   - Invalid signature

8. **Content Address Invalid**
   - Invalid format
   - Invalid hash length
   - Non-hex hash

9. **Determinism Violated**
   - Execution ID not deterministic
   - Execution order non-deterministic

10. **Ingest Invalid**
    - Missing required field
    - Hash mismatch
    - Invalid size

11. **Comprehensive Check Failed**
    - Section missing/empty
    - Evidence contradiction
    - Final seal fails

---

## VERIFICATION RESULT

### If All Steps Pass:

**CLAIM MUST BE ACCEPTED**

**Reasoning:**
- Structure valid (schema proven)
- Integrity proven (cryptographic proof)
- Evidence sealed (all events verified)
- Lineage complete (DAG verified)
- Policy compliant (all rules passed)
- Validations passed (all formats valid)
- Transitions valid (policy-compliant)
- Deterministic (execution verified)

**The claim is cryptographically provable and structurally valid.**
**As a hostile verifier, I cannot invalidate it.**

### If Any Step Fails:

**CLAIM INVALIDATED**

**Precise Invariant Violation:**
- See failure conditions above
- The specific violated invariant is identified
- The claim cannot be accepted

---

## VERIFICATION CODE REQUIREMENTS

To perform hostile verification, only these are needed:

1. **MTB file** (JSON or ZIP)
2. **Public repository** containing:
   - `mtb/schema/mtb.schema.json` (schema)
   - `engine/policy/rules.yaml` (policy rules)
   - `engine/policy/states.yaml` (state definitions)
   - Verification code (canonical JSON, hash computation)

**No engine required. No trust required. Only cryptographic proofs.**

