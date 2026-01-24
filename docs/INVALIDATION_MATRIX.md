# MK10-PRO Invalidation Matrix
## Strict Binary Validity Rules

**Status:** ✅ **DEFINED**

**Requirement:** Enumerate all states in which MK10-PRO must be considered INVALID.

**Rule:** If any invalid state is "recoverable", REJECT.

---

## INVALIDATION MATRIX

| Category | Invalid State | Error Code | Detection Method | Fatal? | Recoverable? |
|----------|---------------|------------|------------------|--------|--------------|
| **INGEST** | Missing ingest manifest | `INGEST_MANIFEST_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **INGEST** | Ingest manifest invalid schema | `INGEST_SCHEMA_INVALID` | JSON Schema validation | ✅ YES | ❌ NO |
| **INGEST** | Root node has no ingest-bound inputs | `ROOT_INPUT_UNBOUND` | Root binding check | ✅ YES | ❌ NO |
| **INGEST** | Ingest asset unused | `INGEST_ASSET_UNUSED` | Usage verification | ✅ YES | ❌ NO |
| **INGEST** | DAG input cannot be traced to ingest | `DAG_INPUT_UNTraceABLE` | Traceability check | ✅ YES | ❌ NO |
| **INGEST** | Ingest asset hash mismatch | `INGEST_HASH_MISMATCH` | Content hash verification | ✅ YES | ❌ NO |
| **DETERMINISM** | Missing determinism proof | `DETERMINISM_PROOF_MISSING` | Evidence check | ✅ YES | ❌ NO |
| **DETERMINISM** | Determinism proof invalid | `DETERMINISM_PROOF_INVALID` | Proof structure check | ✅ YES | ❌ NO |
| **DETERMINISM** | Determinism proof not verified | `DETERMINISM_PROOF_NOT_VERIFIED` | verified != true | ✅ YES | ❌ NO |
| **DETERMINISM** | Node code hash missing | `NODE_CODE_HASH_MISSING` | Proof field check | ✅ YES | ❌ NO |
| **DETERMINISM** | Context hash missing | `CONTEXT_HASH_MISSING` | Proof field check | ✅ YES | ❌ NO |
| **DETERMINISM** | Inputs hash missing | `INPUTS_HASH_MISSING` | Proof field check | ✅ YES | ❌ NO |
| **DETERMINISM** | Outputs hash missing | `OUTPUTS_HASH_MISSING` | Proof field check | ✅ YES | ❌ NO |
| **DETERMINISM** | Executions count != 2 | `DETERMINISM_EXECUTIONS_INVALID` | executions field check | ✅ YES | ❌ NO |
| **DETERMINISM** | Method != "double_execution" | `DETERMINISM_METHOD_INVALID` | method field check | ✅ YES | ❌ NO |
| **EVIDENCE** | Missing execution_start event | `EVIDENCE_START_MISSING` | Event type check | ✅ YES | ❌ NO |
| **EVIDENCE** | Missing execution_complete event | `EVIDENCE_COMPLETE_MISSING` | Event type check | ✅ YES | ❌ NO |
| **EVIDENCE** | Missing node_execution event | `EVIDENCE_NODE_EXECUTION_MISSING` | Event type check | ✅ YES | ❌ NO |
| **EVIDENCE** | Node execution event incomplete | `EVIDENCE_NODE_INCOMPLETE` | Event structure check | ✅ YES | ❌ NO |
| **EVIDENCE** | Evidence event missing integrity_proof | `EVIDENCE_INTEGRITY_MISSING` | Integrity proof check | ✅ YES | ❌ NO |
| **EVIDENCE** | Evidence integrity proof invalid | `EVIDENCE_INTEGRITY_INVALID` | Hash verification | ✅ YES | ❌ NO |
| **EVIDENCE** | Evidence events not chronologically ordered | `EVIDENCE_ORDER_INVALID` | Timestamp ordering | ✅ YES | ❌ NO |
| **EVIDENCE** | Evidence timestamp format invalid | `EVIDENCE_TIMESTAMP_INVALID` | ISO 8601 validation | ✅ YES | ❌ NO |
| **LINEAGE** | Missing lineage_dag | `LINEAGE_DAG_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **LINEAGE** | Lineage DAG has cycles | `LINEAGE_CYCLE_DETECTED` | Topological sort | ✅ YES | ❌ NO |
| **LINEAGE** | Orphan nodes exist | `LINEAGE_ORPHAN_NODES` | Reachability check | ✅ YES | ❌ NO |
| **LINEAGE** | Output cannot be traced to ingest | `LINEAGE_INGEST_UNTraceABLE` | Traceability check | ✅ YES | ❌ NO |
| **LINEAGE** | Skipped transformations | `LINEAGE_SKIPPED_TRANSFORMATIONS` | DAG vs evidence check | ✅ YES | ❌ NO |
| **LINEAGE** | Incomplete dependency graph | `LINEAGE_INCOMPLETE_DEPENDENCIES` | Edge validation | ✅ YES | ❌ NO |
| **LINEAGE** | Input-output inconsistency | `LINEAGE_INPUT_OUTPUT_INCONSISTENCY` | Count validation | ✅ YES | ❌ NO |
| **LINEAGE** | Execution order violates dependencies | `LINEAGE_ORDER_VIOLATION` | Order validation | ✅ YES | ❌ NO |
| **POLICY** | Missing policy_evidence | `POLICY_EVIDENCE_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **POLICY** | Required rule check missing | `POLICY_RULE_CHECK_MISSING` | Rule check existence | ✅ YES | ❌ NO |
| **POLICY** | Required rule check failed | `POLICY_RULE_CHECK_FAILED` | passed != true | ✅ YES | ❌ NO |
| **POLICY** | Invalid state transition | `POLICY_STATE_TRANSITION_INVALID` | Transition validation | ✅ YES | ❌ NO |
| **POLICY** | Required validation not passed | `POLICY_VALIDATION_MISSING` | Validation check | ✅ YES | ❌ NO |
| **POLICY** | Policy bypass attempted | `POLICY_BYPASS_DETECTED` | Configuration check | ✅ YES | ❌ NO |
| **VALIDATION** | Missing validation_evidence | `VALIDATION_EVIDENCE_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **VALIDATION** | Required validation missing | `VALIDATION_REQUIRED_MISSING` | Validation existence | ✅ YES | ❌ NO |
| **VALIDATION** | Required validation failed | `VALIDATION_REQUIRED_FAILED` | passed != true | ✅ YES | ❌ NO |
| **VALIDATION** | Validation details missing | `VALIDATION_DETAILS_MISSING` | Details field check | ✅ YES | ❌ NO |
| **INTEGRITY** | Missing integrity_proof | `INTEGRITY_PROOF_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **INTEGRITY** | Integrity proof algorithm invalid | `INTEGRITY_ALGORITHM_INVALID` | Algorithm check | ✅ YES | ❌ NO |
| **INTEGRITY** | Integrity proof hash missing | `INTEGRITY_HASH_MISSING` | Hash field check | ✅ YES | ❌ NO |
| **INTEGRITY** | Integrity proof hash mismatch | `INTEGRITY_HASH_MISMATCH` | Hash verification | ✅ YES | ❌ NO |
| **INTEGRITY** | Integrity proof hash format invalid | `INTEGRITY_HASH_FORMAT_INVALID` | Hash format check | ✅ YES | ❌ NO |
| **STRUCTURE** | Missing required MTB section | `MTB_SECTION_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **STRUCTURE** | MTB schema validation failed | `MTB_SCHEMA_INVALID` | JSON Schema validation | ✅ YES | ❌ NO |
| **STRUCTURE** | MTB JSON parse error | `MTB_JSON_INVALID` | JSON parsing | ✅ YES | ❌ NO |
| **STRUCTURE** | MTB file not found | `MTB_FILE_NOT_FOUND` | File existence | ✅ YES | ❌ NO |
| **STRUCTURE** | MTB ZIP corrupted | `MTB_ZIP_CORRUPTED` | ZIP validation | ✅ YES | ❌ NO |
| **STRUCTURE** | MTB ZIP contains no JSON | `MTB_ZIP_NO_JSON` | ZIP content check | ✅ YES | ❌ NO |
| **VERIFIER** | Verifier ambiguity (multiple valid interpretations) | `VERIFIER_AMBIGUITY` | Interpretation check | ✅ YES | ❌ NO |
| **VERIFIER** | Verifier cannot determine validity | `VERIFIER_INDETERMINATE` | Binary decision failure | ✅ YES | ❌ NO |
| **VERIFIER** | Verifier requires trust | `VERIFIER_TRUST_REQUIRED` | Trust dependency check | ✅ YES | ❌ NO |
| **VERIFIER** | Verifier requires engine | `VERIFIER_ENGINE_REQUIRED` | Dependency check | ✅ YES | ❌ NO |
| **VERIFIER** | Verifier requires interpretation | `VERIFIER_INTERPRETATION_REQUIRED` | Interpretation check | ✅ YES | ❌ NO |
| **APPROVAL** | Missing approval_events | `APPROVAL_EVENTS_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **APPROVAL** | Approval event structure invalid | `APPROVAL_EVENT_INVALID` | Event structure check | ✅ YES | ❌ NO |
| **APPROVAL** | Approval timestamp invalid | `APPROVAL_TIMESTAMP_INVALID` | ISO 8601 validation | ✅ YES | ❌ NO |
| **ARCHIVE** | Missing archive_declaration | `ARCHIVE_DECLARATION_MISSING` | Schema validation | ✅ YES | ❌ NO |
| **ARCHIVE** | Archive declaration invalid | `ARCHIVE_DECLARATION_INVALID` | Declaration structure | ✅ YES | ❌ NO |

---

## INVALIDATION CATEGORIES

### 1. INGEST (6 invalid states)

**All ingest-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Missing ingest manifest | Schema validation | ❌ NO |
| Root input unbound | Root binding check | ❌ NO |
| Ingest asset unused | Usage verification | ❌ NO |
| DAG input untraceable | Traceability check | ❌ NO |
| Ingest hash mismatch | Content verification | ❌ NO |
| Ingest schema invalid | JSON Schema validation | ❌ NO |

---

### 2. DETERMINISM (9 invalid states)

**All determinism-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Determinism proof missing | Evidence check | ❌ NO |
| Determinism proof invalid | Proof structure | ❌ NO |
| Determinism proof not verified | verified field | ❌ NO |
| Node code hash missing | Proof field check | ❌ NO |
| Context hash missing | Proof field check | ❌ NO |
| Inputs hash missing | Proof field check | ❌ NO |
| Outputs hash missing | Proof field check | ❌ NO |
| Executions count invalid | executions field | ❌ NO |
| Method invalid | method field | ❌ NO |

---

### 3. EVIDENCE (7 invalid states)

**All evidence-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Missing execution_start | Event type check | ❌ NO |
| Missing execution_complete | Event type check | ❌ NO |
| Missing node_execution | Event type check | ❌ NO |
| Node execution incomplete | Event structure | ❌ NO |
| Evidence integrity missing | Integrity proof check | ❌ NO |
| Evidence integrity invalid | Hash verification | ❌ NO |
| Evidence order invalid | Timestamp ordering | ❌ NO |

---

### 4. LINEAGE (7 invalid states)

**All lineage-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Lineage DAG missing | Schema validation | ❌ NO |
| Cycle detected | Topological sort | ❌ NO |
| Orphan nodes | Reachability check | ❌ NO |
| Output untraceable | Traceability check | ❌ NO |
| Skipped transformations | DAG vs evidence | ❌ NO |
| Incomplete dependencies | Edge validation | ❌ NO |
| Input-output inconsistency | Count validation | ❌ NO |

---

### 5. POLICY (6 invalid states)

**All policy-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Policy evidence missing | Schema validation | ❌ NO |
| Rule check missing | Rule existence | ❌ NO |
| Rule check failed | passed field | ❌ NO |
| State transition invalid | Transition validation | ❌ NO |
| Validation missing | Validation check | ❌ NO |
| Policy bypass detected | Configuration check | ❌ NO |

---

### 6. VALIDATION (4 invalid states)

**All validation-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Validation evidence missing | Schema validation | ❌ NO |
| Required validation missing | Validation existence | ❌ NO |
| Required validation failed | passed field | ❌ NO |
| Validation details missing | Details field | ❌ NO |

---

### 7. INTEGRITY (5 invalid states)

**All integrity-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Integrity proof missing | Schema validation | ❌ NO |
| Algorithm invalid | Algorithm check | ❌ NO |
| Hash missing | Hash field check | ❌ NO |
| Hash mismatch | Hash verification | ❌ NO |
| Hash format invalid | Hash format check | ❌ NO |

---

### 8. STRUCTURE (6 invalid states)

**All structure-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Required section missing | Schema validation | ❌ NO |
| Schema validation failed | JSON Schema | ❌ NO |
| JSON parse error | JSON parsing | ❌ NO |
| File not found | File existence | ❌ NO |
| ZIP corrupted | ZIP validation | ❌ NO |
| ZIP no JSON | ZIP content | ❌ NO |

---

### 9. VERIFIER (5 invalid states)

**All verifier-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Verifier ambiguity | Interpretation check | ❌ NO |
| Verifier indeterminate | Binary decision | ❌ NO |
| Verifier trust required | Trust dependency | ❌ NO |
| Verifier engine required | Dependency check | ❌ NO |
| Verifier interpretation required | Interpretation check | ❌ NO |

---

### 10. APPROVAL (3 invalid states)

**All approval-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Approval events missing | Schema validation | ❌ NO |
| Approval event invalid | Event structure | ❌ NO |
| Approval timestamp invalid | ISO 8601 validation | ❌ NO |

---

### 11. ARCHIVE (2 invalid states)

**All archive-related invalidations are fatal and non-recoverable.**

| Invalid State | Detection | Recovery |
|---------------|-----------|----------|
| Archive declaration missing | Schema validation | ❌ NO |
| Archive declaration invalid | Declaration structure | ❌ NO |

---

## BINARY VALIDITY RULE

**MK10-PRO is VALID if and only if:**

- ✅ All 60 invalid states are NOT present
- ✅ All required checks pass
- ✅ All evidence is complete
- ✅ All proofs are valid
- ✅ All bindings are satisfied

**MK10-PRO is INVALID if:**

- ❌ Any of the 60 invalid states is present
- ❌ Any required check fails
- ❌ Any evidence is incomplete
- ❌ Any proof is invalid
- ❌ Any binding is unsatisfied

**No partial validity. No conditional acceptance. Binary only.**

---

## RECOVERY POLICY

**Rule:** If any invalid state is "recoverable", REJECT.

**Status:** ✅ **ENFORCED**

**All 60 invalid states are:**
- ✅ Fatal (execution/verification aborts)
- ❌ Non-recoverable (no retry, no fix, no override)
- ❌ No warnings (binary pass/fail only)
- ❌ No partial acceptance (all or nothing)

---

## DETECTION METHODS

### Schema Validation
- JSON Schema (Draft 7) validation
- Required field checks
- Type validation
- Enum validation

### Structural Checks
- File existence
- JSON parsing
- ZIP validation
- Section presence

### Cryptographic Checks
- Hash verification
- Integrity proof validation
- Evidence integrity checks
- Content hash matching

### Logical Checks
- Topological sort (cycle detection)
- Reachability analysis
- Traceability verification
- Dependency validation

### Evidence Checks
- Event type verification
- Event structure validation
- Timestamp ordering
- Completeness verification

---

## VALIDATION SEQUENCE

**Order of invalidation checks (fail-fast):**

1. **Structure** (6 checks) - Fail immediately if MTB cannot be loaded
2. **Schema** (1 check) - Fail immediately if structure invalid
3. **Integrity** (5 checks) - Fail immediately if seal invalid
4. **Ingest** (6 checks) - Fail immediately if ingest invalid
5. **Lineage** (7 checks) - Fail immediately if lineage invalid
6. **Determinism** (9 checks) - Fail immediately if determinism invalid
7. **Evidence** (7 checks) - Fail immediately if evidence invalid
8. **Policy** (6 checks) - Fail immediately if policy invalid
9. **Validation** (4 checks) - Fail immediately if validation invalid
10. **Approval** (3 checks) - Fail immediately if approval invalid
11. **Archive** (2 checks) - Fail immediately if archive invalid
12. **Verifier** (5 checks) - Fail immediately if verifier invalid

**Any failure → MTB is INVALID. No further checks.**

---

## SUMMARY

**Total Invalid States:** 60

**Categories:** 11

**All States:**
- ✅ Fatal
- ❌ Non-recoverable
- ❌ No warnings
- ❌ No partial acceptance

**Binary Rule:** VALID / INVALID (no middle ground)

---

## STATUS

**Invalidation Matrix:** ✅ **COMPLETE**

**All Invalid States:** ✅ **ENUMERATED**

**Recovery Policy:** ✅ **ENFORCED** (no recoverable states)

**Binary Validity:** ✅ **STRICT** (pass/fail only)

