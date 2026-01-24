# Feature Request Evaluation Framework

## Evaluation Process

All feature requests must be evaluated against MK10-PRO axioms before consideration.

### Evaluation Criteria

1. **Axiom Compliance**
   - Does it violate any of the 6 immutable axioms?
   - If yes, reject immediately

2. **Scope Boundaries**
   - Does it expand beyond pre-delivery truth?
   - Does it reference playback, devices, venues, operators?
   - If yes, reject immediately

3. **Determinism**
   - Does it introduce non-deterministic behavior?
   - Does it depend on time, randomness, or environment?
   - If yes, reject immediately

4. **Trust Requirements**
   - Does it require trust in operator, author, or environment?
   - Does it require interpretation or subjectivity?
   - If yes, reject immediately

5. **Evidence Requirements**
   - Can all claims be sealed into MTB?
   - Can all claims be independently verified?
   - If no, reject immediately

### Axiom Checklist

For each feature request, verify:

- [ ] **Axiom 1: Truth is executable** - Claims emerge only from execution
- [ ] **Axiom 2: Evidence is the product** - Files are inputs, not outcomes
- [ ] **Axiom 3: Policy is law** - Configuration cannot override rules
- [ ] **Axiom 4: Verification is hostile** - No engine, no trust, no authority required
- [ ] **Axiom 5: Determinism is mandatory** - Same inputs yield identical outputs
- [ ] **Axiom 6: Scope ends before institutions** - Hardware, venues, operators out of bounds

### Rejection Criteria

**IMMEDIATE REJECTION** if feature request:

1. Violates any axiom
2. Expands scope beyond pre-delivery truth
3. Introduces non-determinism
4. Requires trust, interpretation, or subjectivity
5. Cannot be sealed into MTB
6. Cannot be independently verified

**No compromises. No exceptions.**

---

## Example Evaluations

### Example 1: "Add human approval workflow"

**Evaluation:**
- ❌ **REJECTED** - Violates Axiom 2 (Evidence is the product)
- ❌ **REJECTED** - Introduces subjectivity (human judgment)
- ❌ **REJECTED** - Cannot be independently verified (requires trust in human)

**Reason:** Human approval is opinion, not evidence. MK10-PRO operates only on evidence.

### Example 2: "Add device playback testing"

**Evaluation:**
- ❌ **REJECTED** - Violates Axiom 6 (Scope ends before institutions)
- ❌ **REJECTED** - Expands scope beyond pre-delivery truth
- ❌ **REJECTED** - References devices (explicitly excluded)

**Reason:** Device testing is out of scope. MK10-PRO validates structural conformance only.

### Example 3: "Add configurable policy rules"

**Evaluation:**
- ❌ **REJECTED** - Violates Axiom 3 (Policy is law)
- ❌ **REJECTED** - Allows configuration to override rules

**Reason:** Policy is law. Configuration cannot override rules.

### Example 4: "Add timestamp-based execution ID"

**Evaluation:**
- ❌ **REJECTED** - Violates Axiom 5 (Determinism is mandatory)
- ❌ **REJECTED** - Introduces time dependency (non-deterministic)

**Reason:** Execution IDs must be deterministic. Time-based IDs are non-deterministic.

### Example 5: "Add reproducibility manifest to MTB"

**Evaluation:**
- ✅ **ACCEPTED** - No axiom violations
- ✅ **ACCEPTED** - Deterministic (hash-based)
- ✅ **ACCEPTED** - Can be sealed into MTB
- ✅ **ACCEPTED** - Can be independently verified
- ✅ **ACCEPTED** - Additive only (backward compatible)

**Reason:** Enhances reproducibility without violating axioms. Optional field, deterministic content.

---

## Evaluation Template

Use this template for all feature requests:

```
FEATURE REQUEST: [Name]

DESCRIPTION:
[Feature description]

AXIOM EVALUATION:
- Axiom 1 (Truth is executable): [PASS/FAIL] - [Reason]
- Axiom 2 (Evidence is the product): [PASS/FAIL] - [Reason]
- Axiom 3 (Policy is law): [PASS/FAIL] - [Reason]
- Axiom 4 (Verification is hostile): [PASS/FAIL] - [Reason]
- Axiom 5 (Determinism is mandatory): [PASS/FAIL] - [Reason]
- Axiom 6 (Scope ends before institutions): [PASS/FAIL] - [Reason]

SCOPE EVALUATION:
- Expands beyond pre-delivery truth: [YES/NO] - [Reason]
- References playback/devices/venues/operators: [YES/NO] - [Reason]

DETERMINISM EVALUATION:
- Introduces non-determinism: [YES/NO] - [Reason]
- Depends on time/randomness/environment: [YES/NO] - [Reason]

TRUST EVALUATION:
- Requires trust: [YES/NO] - [Reason]
- Requires interpretation: [YES/NO] - [Reason]
- Requires subjectivity: [YES/NO] - [Reason]

EVIDENCE EVALUATION:
- Can be sealed into MTB: [YES/NO] - [Reason]
- Can be independently verified: [YES/NO] - [Reason]

VERDICT:
[ACCEPTED/REJECTED]

REASON:
[Detailed explanation]
```

---

## Final Authority

**If any axiom is violated, the feature is rejected.**
**If scope is expanded, the feature is rejected.**
**If determinism is violated, the feature is rejected.**
**If trust is required, the feature is rejected.**

**No compromises. No exceptions. No appeals.**

