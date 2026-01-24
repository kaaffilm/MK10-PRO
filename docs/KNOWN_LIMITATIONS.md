# Known System Limitations
## Out of Scope for Determinism Implementation

**Status:** These are **system-level incompletions**, not determinism failures.

**Determinism Status:** ✅ **CLOSED** — These do not invalidate the determinism proof.

---

## 1. Root Ingest Binding

### Issue

`_collect_inputs()` root case is still empty:

```python
if not dependencies:
    # Root node - inputs come from ingest
    # This would be populated from ingest manifest
    pass
```

### Impact

- **Affects:** Reproducibility (not determinism)
- **Scope:** Ingest / policy level
- **Determinism:** ✅ Not a determinism failure

### Required Fix (Future Work)

- Ingest manifest must bind root node inputs
- Policy must enforce ingest-bound lineage
- Verifier must reject MTBs missing ingest-bound lineage

**Status:** Allowed temporarily if:
- Policy forbids execution of DAGs with unresolved roots
- Verifier rejects MTBs missing ingest-bound lineage

**In the absence of the stated policy/verifier enforcement, the system MUST be considered invalid.**

---

## 2. Policy Completeness

### Issue

Policy evaluation breadth is still shallow:
- `_check_lineage()` is simplified
- `_check_integrity()` is simplified
- `_evaluate_condition()` is simplified

### Impact

- **Affects:** Policy enforcement completeness
- **Scope:** Policy system
- **Determinism:** ✅ Not a determinism failure

### Required Fix (Future Work)

- Implement full lineage verification
- Implement full integrity checks
- Implement full condition evaluation

**Status:** Acceptable for now; does not undermine determinism.

---

## 3. Resource Determinism

### Issue

CPU features, SIMD, external libs can affect execution:
- Different CPU instruction sets
- Different SIMD capabilities
- Different library versions

### Impact

- **Affects:** Cross-platform reproducibility
- **Scope:** System-level resource constraints
- **Determinism:** ✅ Correctly excluded by scope

### Required Fix (Future Work)

- None — this is correctly out of scope
- Engine does not claim to solve this
- This is a known limitation of deterministic execution

**Status:** Correctly excluded. Not a determinism failure.

---

## DETERMINISM VERDICT

**None of these invalidate the determinism proof.**

### Determinism Status: ✅ CLOSED

The determinism implementation is **mechanically complete**:

- ✅ Double execution with fatal abort
- ✅ Node code hash (no fallback)
- ✅ Input mutation detection
- ✅ File existence symmetry
- ✅ Output comparison
- ✅ File bytes comparison
- ✅ Determinism proof emission

**These limitations are:**
- System-level incompletions
- Out of scope for determinism
- Do not affect determinism proof validity
- Can be addressed in future work

---

## FUTURE WORK

1. **Root Ingest Binding**
   - Implement ingest manifest binding
   - Enforce in policy
   - Verify in verifier

2. **Policy Completeness**
   - Implement full lineage verification
   - Implement full integrity checks
   - Implement full condition evaluation

3. **Resource Determinism**
   - Document platform requirements
   - Document library version constraints
   - Document CPU feature requirements

**None of these are determinism failures.**
**Determinism is closed.**

