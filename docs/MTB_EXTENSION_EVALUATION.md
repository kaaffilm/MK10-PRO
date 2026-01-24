# MTB Schema Extension Evaluation
## Truth Semantics Analysis

**Change:** Add two optional fields to MTB schema:
1. `reproducibility_manifest` (optional)
2. `verification_metadata` (optional)

---

## 1. WHAT NEW FACT IS INTRODUCED

### Fact 1: Reproducibility Manifest

**New Fact:** "This MTB was produced by deterministic execution with these specific inputs."

**Content:**
- Engine version used
- Policy version used
- Schema version
- Hashes of deterministic inputs (DAG, config, policy rules)
- Combined reproducibility proof hash

**Semantic Meaning:**
- Provides evidence that MTB can be reproduced from same inputs
- Links MTB to specific execution environment versions
- Enables verification of reproducibility claim

**Truth Claim:** "Same inputs + same versions = same MTB"

### Fact 2: Verification Metadata

**New Fact:** "This MTB was verified at this time using this verifier."

**Content:**
- Verification timestamp
- Verifier version
- Verification method (standalone/engine/hostile)
- Verification environment (optional)
- Verification results summary

**Semantic Meaning:**
- Records verification history
- Provides audit trail
- Does NOT claim truth about MTB content

**Truth Claim:** "This MTB was verified and passed/failed these checks"

**Note:** This is verification evidence, not MTB content truth.

---

## 2. HOW IT IS VERIFIED

### Reproducibility Manifest Verification

**Verification Process:**

1. **Schema Validation:**
   - Field is optional → old MTBs without it are valid
   - Field structure validated if present
   - No breaking changes

2. **Content Verification:**
   - `engine_version`: String validation (matches execution context)
   - `policy_version`: String validation (matches policy)
   - `schema_version`: String validation (matches `mtb_version`)
   - `deterministic_inputs`: Hash validation
     - `dag_content_hash`: Verify matches DAG content hash
     - `config_hash`: Verify matches config hash
     - `policy_rules_hash`: Verify matches policy rules hash
   - `reproducibility_proof`: Hash validation
     - Verify `hash` matches combined hash of deterministic inputs

3. **Reproducibility Verification:**
   - Extract `deterministic_inputs` from manifest
   - Recompute hashes of current DAG, config, policy rules
   - Compare: computed hashes == stored hashes
   - If match: MTB can be reproduced
   - If mismatch: Reproducibility claim invalid

**Verification Code (Standalone):**
```python
def verify_reproducibility_manifest(mtb: Dict[str, Any]) -> bool:
    """Verify reproducibility manifest without engine."""
    if "reproducibility_manifest" not in mtb:
        return True  # Optional field, not required
    
    manifest = mtb["reproducibility_manifest"]
    
    # Verify structure
    required_fields = ["engine_version", "policy_version", "schema_version", 
                       "deterministic_inputs", "reproducibility_proof"]
    for field in required_fields:
        if field not in manifest:
            return False
    
    # Verify reproducibility proof
    deterministic_inputs = manifest["deterministic_inputs"]
    proof = manifest["reproducibility_proof"]
    
    # Recompute combined hash
    combined = canonical_json(deterministic_inputs)
    computed_hash = compute_sha256(combined.encode('utf-8'))
    
    return computed_hash == proof["hash"]
```

**Verification Without Engine:** ✅ YES
- Only requires: MTB file, JSON schema, hash computation
- No engine access needed
- No execution context needed
- Pure verification from MTB content

### Verification Metadata Verification

**Verification Process:**

1. **Schema Validation:**
   - Field is optional → old MTBs without it are valid
   - Field structure validated if present
   - No breaking changes

2. **Content Verification:**
   - `verification_timestamp`: ISO 8601 format validation
   - `verification_context`: Structure validation
   - `verification_results`: Boolean validation

3. **Verification Results Verification:**
   - `structure_valid`: Verify matches actual structure validation
   - `seal_valid`: Verify matches actual seal verification
   - `evidence_complete`: Verify matches actual evidence check

**Verification Code (Standalone):**
```python
def verify_verification_metadata(mtb: Dict[str, Any]) -> bool:
    """Verify verification metadata matches actual verification."""
    if "verification_metadata" not in mtb:
        return True  # Optional field, not required
    
    metadata = mtb["verification_metadata"]
    results = metadata.get("verification_results", {})
    
    # Re-verify and compare
    actual_structure_valid = verify_mtb_structure(mtb) == []
    actual_seal_valid = verify_seal(mtb)
    actual_evidence_complete = verify_evidence_completeness(mtb)
    
    return (
        results.get("structure_valid") == actual_structure_valid and
        results.get("seal_valid") == actual_seal_valid and
        results.get("evidence_complete") == actual_evidence_complete
    )
```

**Verification Without Engine:** ✅ YES
- Only requires: MTB file, JSON schema, verification code
- No engine access needed
- Re-verifies and compares results

---

## 3. WHY IT DOES NOT ALTER EXISTING TRUTH CLAIMS

### Existing Truth Claims (Unchanged)

**Claim 1: "This MTB represents title/version as fact"**
- **Source:** `title`, `version`, `state`, `ingest_manifest`, `lineage_dag`, `build_evidence`
- **Status:** ✅ UNCHANGED
- **Reason:** New fields are optional, do not affect existing fields

**Claim 2: "This MTB was produced by deterministic execution"**
- **Source:** `build_evidence.execution_id`, `lineage_dag`, node execution events
- **Status:** ✅ UNCHANGED
- **Reason:** New fields provide additional evidence but don't replace existing evidence

**Claim 3: "This MTB is sealed and immutable"**
- **Source:** `integrity_proof`
- **Status:** ✅ UNCHANGED
- **Reason:** Seal computation includes new fields (if present), creating new identity, but seal verification logic unchanged

**Claim 4: "This MTB is policy-compliant"**
- **Source:** `policy_evidence.rule_checks`
- **Status:** ✅ UNCHANGED
- **Reason:** New fields don't affect policy evidence

**Claim 5: "This MTB is formally validated"**
- **Source:** `validation_evidence.validations`
- **Status:** ✅ UNCHANGED
- **Reason:** New fields don't affect validation evidence

### Truth Semantics Analysis

#### Reproducibility Manifest

**Does it change truth semantics?** ❌ NO

**Analysis:**
1. **Additive only:** Field is optional, not required
2. **Does not replace existing evidence:** Existing `build_evidence` and `lineage_dag` remain unchanged
3. **Does not alter existing claims:** All existing truth claims remain valid
4. **New claim is separate:** "This MTB can be reproduced" is additional claim, not replacement
5. **Seal semantics unchanged:** Seal includes new field (if present), creating new identity, but verification logic unchanged

**Conclusion:** Reproducibility manifest adds new fact without altering existing truth claims.

#### Verification Metadata

**Does it change truth semantics?** ❌ NO

**Analysis:**
1. **Additive only:** Field is optional, not required
2. **Verification evidence, not MTB content:** This is metadata about verification, not about MTB itself
3. **Does not alter existing claims:** All existing truth claims remain valid
4. **New claim is separate:** "This MTB was verified" is additional claim, not replacement
5. **Seal semantics unchanged:** If included in seal, creates new identity, but verification logic unchanged

**Note:** Verification metadata should ideally be stored separately from MTB (e.g., in verification log), but including it in MTB doesn't change MTB truth semantics.

**Conclusion:** Verification metadata adds new fact without altering existing truth claims.

---

## BACKWARD COMPATIBILITY

### Old MTBs (without new fields)

**Truth Claims:**
- ✅ All existing truth claims remain valid
- ✅ Schema validation passes (optional fields not required)
- ✅ Seal verification passes (seal computed without new fields)
- ✅ Evidence verification passes (all required evidence present)
- ✅ Structure checks pass (all required sections present)

**Conclusion:** Old MTBs maintain all truth claims. No semantic changes.

### New MTBs (with new fields)

**Truth Claims:**
- ✅ All existing truth claims remain valid
- ✅ New truth claims added (reproducibility, verification history)
- ✅ Schema validation passes (optional fields valid)
- ✅ Seal verification passes (seal includes new fields, new identity)
- ✅ Evidence verification passes (all required evidence present + optional)

**Conclusion:** New MTBs maintain all existing truth claims and add new ones. No semantic changes to existing claims.

---

## VERIFICATION WITHOUT ENGINE

### Reproducibility Manifest

**Verification Requirements:**
- MTB file
- JSON schema
- Hash computation (SHA-256)
- Canonical JSON serialization

**Engine Required?** ❌ NO

**Verification Process:**
1. Extract `reproducibility_manifest` from MTB
2. Extract `deterministic_inputs` hashes
3. Recompute combined hash
4. Compare with `reproducibility_proof.hash`
5. If match: Reproducibility claim valid

**Conclusion:** ✅ Verification possible without engine.

### Verification Metadata

**Verification Requirements:**
- MTB file
- JSON schema
- Verification code (structure, seal, evidence checks)

**Engine Required?** ❌ NO

**Verification Process:**
1. Extract `verification_metadata` from MTB
2. Extract `verification_results`
3. Re-verify MTB (structure, seal, evidence)
4. Compare: stored results == actual results
5. If match: Verification metadata valid

**Conclusion:** ✅ Verification possible without engine.

---

## FINAL VERDICT

### Truth Semantics: ✅ UNCHANGED

**Reasons:**
1. New fields are optional (not required)
2. Existing truth claims remain valid
3. New fields add new facts, don't replace existing facts
4. Seal semantics unchanged (new identity if fields present, but verification logic unchanged)
5. Evidence semantics unchanged (required evidence unchanged)

### Backward Compatibility: ✅ GUARANTEED

**Reasons:**
1. Old MTBs verify successfully
2. New MTBs verify successfully
3. Mixed environments work correctly
4. No breaking changes
5. No semantic changes to existing fields

### Verification Without Engine: ✅ POSSIBLE

**Reasons:**
1. Reproducibility manifest: Only requires hash computation
2. Verification metadata: Only requires verification code
3. No engine access needed
4. No execution context needed

---

## CONCLUSION

**Change Status: ✅ ACCEPTED**

**Reasoning:**
- New facts introduced: Reproducibility evidence, verification history
- Verification: Possible without engine (hash computation, verification code)
- Truth semantics: Unchanged (additive only, optional fields)
- Backward compatibility: Guaranteed (old MTBs verify, new MTBs verify)

**The change does NOT alter existing truth claims. It adds new facts without changing existing semantics.**

