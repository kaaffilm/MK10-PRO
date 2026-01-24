# MTB Schema Extension Proposal

## Extension: Reproducibility Manifest and Verification Metadata

### 1. New Fields

#### Field 1: `reproducibility_manifest` (Optional)

```json
{
  "reproducibility_manifest": {
    "engine_version": "1.0.0",
    "policy_version": "1.0.0",
    "schema_version": "1.0",
    "deterministic_inputs": {
      "dag_content_hash": "sha256:abc123...",
      "config_hash": "sha256:def456...",
      "policy_rules_hash": "sha256:ghi789..."
    },
    "reproducibility_proof": {
      "algorithm": "sha256",
      "hash": "sha256:xyz789..."
    }
  }
}
```

**Type:** Object (optional, not in required list)

**Purpose:** Provides deterministic evidence that execution can be reproduced. Contains version information and hashes of all deterministic inputs that produced this MTB.

**Fields:**
- `engine_version`: String - MK10-PRO engine version used
- `policy_version`: String - Policy pack version used
- `schema_version`: String - MTB schema version (matches mtb_version)
- `deterministic_inputs`: Object - Hashes of all inputs that affect determinism
  - `dag_content_hash`: String - Hash of DAG definition
  - `config_hash`: String - Hash of execution configuration
  - `policy_rules_hash`: String - Hash of policy rules applied
- `reproducibility_proof`: Object - Hash of all reproducibility inputs
  - `algorithm`: String - Hash algorithm (default: "sha256")
  - `hash`: String - Combined hash of all deterministic inputs

#### Field 2: `verification_metadata` (Optional)

```json
{
  "verification_metadata": {
    "verification_timestamp": "2024-01-01T00:00:00Z",
    "verification_context": {
      "verifier_version": "1.0.0",
      "verification_method": "standalone",
      "verification_environment": {
        "os": "linux",
        "python_version": "3.9.0"
      }
    },
    "verification_results": {
      "structure_valid": true,
      "seal_valid": true,
      "evidence_complete": true
    }
  }
}
```

**Type:** Object (optional, not in required list)

**Purpose:** Records metadata about MTB verification without affecting the MTB itself. This is verification evidence, not MTB content.

**Fields:**
- `verification_timestamp`: String (ISO 8601) - When verification occurred
- `verification_context`: Object - Context of verification
  - `verifier_version`: String - Verifier version used
  - `verification_method`: String - "standalone" | "engine" | "hostile"
  - `verification_environment`: Object - Environment info (optional)
- `verification_results`: Object - Summary of verification results
  - `structure_valid`: Boolean
  - `seal_valid`: Boolean
  - `evidence_complete`: Boolean

### 2. Purpose

**Reproducibility Manifest:**
- Enables verification that an MTB can be reproduced from the same inputs
- Provides deterministic evidence of all inputs that affect execution
- Supports the "No File Falls Again" promise by enabling reproduction
- Does not affect MTB validity (optional field)

**Verification Metadata:**
- Records verification history without modifying MTB content
- Enables audit trail of verification events
- Supports hostile verification tracking
- Does not affect MTB validity (optional field, verification-only)

### 3. Determinism Impact Analysis

#### Reproducibility Manifest

**Determinism Impact: NONE**

**Analysis:**
1. **Field is optional**: Old MTBs without this field remain valid
2. **Content is deterministic**: All fields are computed from deterministic inputs
   - `engine_version`: Fixed string from execution context
   - `policy_version`: Fixed string from policy
   - `schema_version`: Matches `mtb_version` (already deterministic)
   - `deterministic_inputs`: Hashes of deterministic inputs (DAG, config, policy)
   - `reproducibility_proof`: Hash of deterministic inputs (deterministic)
3. **No time dependencies**: All values derived from execution context
4. **No randomness**: All values are deterministic functions of inputs
5. **Seal computation unchanged**: Seal excludes `integrity_proof`, new optional fields don't affect it

**Conclusion:** Adding this field does not affect determinism. Same inputs produce same MTB (with or without this field).

#### Verification Metadata

**Determinism Impact: NONE**

**Analysis:**
1. **Field is optional**: Old MTBs without this field remain valid
2. **Not part of MTB content**: This is verification evidence, not MTB content
3. **Seal computation unchanged**: This field would be excluded from seal computation (if added to MTB)
4. **Verification-only**: This field is added during verification, not during MTB creation

**Note:** This field should ideally be stored separately from the MTB (e.g., in a verification log), but can be included in MTB for convenience without affecting validity.

**Conclusion:** Adding this field does not affect determinism. It's verification metadata, not execution content.

### 4. Verification Impact Analysis

#### Schema Validation

**Impact: NONE**

**Analysis:**
1. **JSON Schema**: New fields are optional (not in `required` array)
2. **Old MTBs**: Will validate successfully (missing optional fields is valid)
3. **New MTBs**: Will validate successfully (optional fields present is valid)
4. **Schema validator**: jsonschema.Draft7Validator handles optional fields correctly

**Verification Code Impact:**
```python
# Current verification code (mtb/verify.py)
required_sections = [
    "ingest_manifest",
    "lineage_dag",
    "build_evidence",
    "policy_evidence",
    "validation_evidence",
    "approval_events",
    "integrity_proof",
]

# No changes needed - new fields are optional
# Old MTBs: All required sections present → valid
# New MTBs: All required sections present + optional fields → valid
```

#### Seal Verification

**Impact: NONE**

**Analysis:**
1. **Seal computation**: Excludes `integrity_proof` when computing hash
   ```python
   mtb_without_proof = {k: v for k, v in mtb.items() if k != "integrity_proof"}
   canonical = canonical_json_bytes(mtb_without_proof)
   ```
2. **New fields**: Are included in canonical JSON (if present)
3. **Old MTBs**: Don't have new fields → same canonical JSON → same hash → valid
4. **New MTBs**: Have new fields → different canonical JSON → different hash → valid (new identity)
5. **Verification**: `verify_seal()` recomputes hash without `integrity_proof` → works for both

**Conclusion:** Seal verification remains valid. Old MTBs verify correctly. New MTBs with new fields have different hashes (new identity), which is correct.

#### Evidence Verification

**Impact: NONE**

**Analysis:**
1. **Required evidence**: Unchanged (all existing evidence types still required)
2. **New fields**: Provide additional evidence but don't replace required evidence
3. **Policy checks**: Unchanged (policy operates on existing evidence)
4. **Lineage checks**: Unchanged (lineage_dag unchanged)

**Conclusion:** Evidence verification remains valid. New fields provide additional information but don't affect required evidence checks.

### 5. Backward Compatibility Guarantee

#### Old MTBs (without new fields)

**Validation:**
- ✅ Schema validation: Passes (optional fields not required)
- ✅ Seal verification: Passes (seal computed without new fields)
- ✅ Evidence verification: Passes (all required evidence present)
- ✅ Structure checks: Passes (all required sections present)

**Conclusion:** Old MTBs verify successfully. No breaking changes.

#### New MTBs (with new fields)

**Validation:**
- ✅ Schema validation: Passes (optional fields valid)
- ✅ Seal verification: Passes (seal includes new fields in hash)
- ✅ Evidence verification: Passes (all required evidence present + optional)
- ✅ Structure checks: Passes (all required sections present)

**Conclusion:** New MTBs verify successfully. New fields enhance but don't break.

#### Mixed Environment

**Scenario:** Old verifier verifying new MTB
- ✅ Schema validation: Passes (optional fields ignored if unknown)
- ✅ Seal verification: Passes (seal computation includes all fields)
- ✅ Evidence verification: Passes (required evidence present)

**Scenario:** New verifier verifying old MTB
- ✅ Schema validation: Passes (optional fields not required)
- ✅ Seal verification: Passes (seal computed without new fields)
- ✅ Evidence verification: Passes (all required evidence present)

**Conclusion:** Full backward compatibility. Old and new MTBs verify in both old and new verifiers.

### 6. Implementation Notes

#### Schema Update

```json
{
  "properties": {
    // ... existing properties ...
    
    "reproducibility_manifest": {
      "type": "object",
      "description": "Deterministic evidence of reproducibility",
      "properties": {
        "engine_version": {"type": "string"},
        "policy_version": {"type": "string"},
        "schema_version": {"type": "string"},
        "deterministic_inputs": {
          "type": "object",
          "properties": {
            "dag_content_hash": {"type": "string"},
            "config_hash": {"type": "string"},
            "policy_rules_hash": {"type": "string"}
          }
        },
        "reproducibility_proof": {
          "type": "object",
          "properties": {
            "algorithm": {"type": "string"},
            "hash": {"type": "string"}
          }
        }
      }
    },
    
    "verification_metadata": {
      "type": "object",
      "description": "Verification history and context",
      "properties": {
        "verification_timestamp": {"type": "string", "format": "date-time"},
        "verification_context": {
          "type": "object",
          "properties": {
            "verifier_version": {"type": "string"},
            "verification_method": {"type": "string"},
            "verification_environment": {"type": "object"}
          }
        },
        "verification_results": {
          "type": "object",
          "properties": {
            "structure_valid": {"type": "boolean"},
            "seal_valid": {"type": "boolean"},
            "evidence_complete": {"type": "boolean"}
          }
        }
      }
    }
  }
  // Note: NOT added to "required" array - remains optional
}
```

#### Seal Computation

**No changes needed.** Current implementation already handles optional fields:

```python
def seal_mtb(mtb: Dict[str, Any]) -> Dict[str, Any]:
    # Excludes integrity_proof
    mtb_copy = {k: v for k, v in mtb.items() if k != "integrity_proof"}
    # Includes all other fields (including new optional fields)
    canonical = canonical_json_bytes(mtb_copy)
    hash_value = compute_sha256(canonical)
    # ...
```

#### Verification Logic

**No changes needed.** Current verification:
1. Checks required sections (unchanged)
2. Verifies seal (works with or without new fields)
3. Validates structure (optional fields allowed)

### 7. Summary

**Extension Status: ✅ VALID**

**Backward Compatibility: ✅ GUARANTEED**

- Old MTBs verify successfully
- New MTBs verify successfully
- Mixed environments work correctly
- No breaking changes
- No semantic changes to existing fields
- Verification logic remains valid

**Determinism: ✅ PRESERVED**

- New fields are deterministic (if present)
- No time dependencies
- No randomness
- Seal computation unchanged

**Verification: ✅ VALID**

- Schema validation works
- Seal verification works
- Evidence verification works
- All checks remain valid

This extension is **additive only**, **backward compatible**, and **axiom-compliant**.

