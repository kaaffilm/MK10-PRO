# MK10-PRO: Institutional Review Document

## System Definition

MK10-PRO is deterministic execution infrastructure for audiovisual mastering pipelines. It converts mastering operations into verifiable claims through cryptographic evidence.

The system operates on six immutable axioms:
1. Claims emerge only from execution
2. Evidence is the product (files are inputs)
3. Policy rules cannot be overridden
4. Verification requires no trust or authority
5. Same inputs produce identical outputs
6. Scope ends at pre-delivery truth (no hardware, venues, or operators)

---

## 1. What Constitutes a Valid Claim

A valid claim in MK10-PRO is a **Master Truth Bundle (MTB)** that passes independent verification.

### MTB Structure

An MTB is a JSON document containing:

1. **Ingest Manifest**: Source assets with cryptographic hashes
   - Each asset has: content_address (hash-based), path, hash, size
   - Minimum: one asset required

2. **Lineage DAG**: Complete provenance graph
   - Nodes: transformation steps
   - Edges: dependencies between steps
   - Execution order: deterministic sequence

3. **Build Evidence**: Execution records
   - Execution ID: deterministic identifier
   - Events: sealed evidence of each transformation
   - All events have integrity proofs (cryptographic hashes)

4. **Policy Evidence**: Rule compliance
   - Rule checks: one per policy rule
   - All checks must pass (100% pass rate)
   - No rule violations allowed

5. **Validation Evidence**: Format conformance
   - Validations: one per declared output format
   - All validations must pass (100% pass rate)
   - Structural conformance only (no device testing)

6. **Approval Events**: State transitions
   - From/to states: DRAFT → CANDIDATE → RELEASE → ARCHIVED
   - Transitions are evidence-gated
   - Signatures required for RELEASE promotion

7. **Integrity Proof**: Cryptographic seal
   - Algorithm: hash algorithm (default SHA-256)
   - Hash: canonical hash of MTB (excluding integrity_proof)

8. **Archive Declaration**: Retention intent
   - Declared timestamp
   - Intent: retention policy

### Validity Criteria

An MTB is valid if and only if:

1. **Structure Valid**: Conforms to JSON schema (12 required fields, 8 nested structures)
2. **Seal Valid**: Integrity proof hash matches recomputed hash
3. **Evidence Complete**: All execution events have integrity proofs
4. **Lineage Complete**: All outputs trace to ingest via acyclic DAG
5. **Policy Compliant**: All policy rules checked and passed
6. **Validations Passed**: All format validations passed
7. **Transitions Valid**: All state transitions are policy-compliant
8. **Deterministic**: Execution ID and order are deterministic

**If any criterion fails, the claim is invalid.**

---

## 2. How Claims Are Produced

Claims are produced through deterministic execution of a workflow.

### Execution Process

1. **Ingest**: Source assets are ingested
   - Content hash computed (SHA-256)
   - Content address generated: `{hash}{extension}`
   - Asset recorded in ingest manifest

2. **DAG Definition**: Workflow defined as Directed Acyclic Graph
   - Nodes: transformation steps (pure functions)
   - Edges: dependencies
   - Execution order: topological sort (deterministic)

3. **Execution**: Engine executes DAG
   - Nodes executed in topological order
   - Each node: pure transformation, content-addressed I/O
   - Evidence recorded for each step
   - Execution ID: deterministic hash of DAG + workspace

4. **Evidence Generation**: All transformations emit evidence
   - Execution events: start, node execution, complete
   - Policy checks: rule compliance verification
   - Format validations: structural conformance checks
   - All evidence sealed with integrity proofs

5. **MTB Construction**: Evidence assembled into MTB
   - All required sections populated
   - Integrity proof computed (canonical hash)
   - MTB sealed

6. **State Promotion**: MTB promoted through states
   - DRAFT → CANDIDATE: requires execution complete + validations passed
   - CANDIDATE → RELEASE: requires policy approved + signature
   - RELEASE → ARCHIVED: requires archive declaration

### Determinism Guarantee

Same inputs + same engine + same policy = same outputs.

This is enforced by:
- Content addressing (all artifacts hash-based)
- Immutable execution context
- Pure node transformations (no side effects)
- Deterministic execution ID (hash of inputs)
- Deterministic timestamps (from execution context)

**If determinism is violated, execution fails.**

---

## 3. How Claims Are Verified Independently

Verification requires no engine, no trust, and no authority. Only the MTB file and public repository code are needed.

### Verification Process

1. **Load MTB**: Parse JSON structure

2. **Schema Validation**: Validate against JSON Schema
   - Check 12 required fields present
   - Validate field types
   - Validate nested structures
   - Check enum constraints

3. **Integrity Proof Verification**:
   - Extract `integrity_proof.hash` (expected hash)
   - Remove `integrity_proof` from MTB
   - Compute canonical JSON (sorted keys, no whitespace)
   - Compute SHA-256 hash
   - Compare: computed_hash == expected_hash
   - **If mismatch, claim invalid**

4. **Evidence Verification**:
   - For each event in `build_evidence.events`:
     - Extract event `integrity_proof.hash`
     - Remove `integrity_proof` from event
     - Compute canonical JSON hash
     - Compare: computed_hash == expected_hash
   - **If any event fails, claim invalid**

5. **Lineage Verification**:
   - Verify DAG is acyclic (no cycles)
   - Verify execution_order matches topological sort
   - Verify all outputs trace to ingest
   - **If lineage incomplete, claim invalid**

6. **Policy Verification**:
   - Load policy rules from repository
   - Verify all rules have checks
   - Verify all checks passed (100% required)
   - **If any rule failed, claim invalid**

7. **Validation Verification**:
   - Verify all validations passed (100% required)
   - Verify validation structure
   - **If any validation failed, claim invalid**

8. **State Transition Verification**:
   - Verify transitions are policy-compliant
   - Verify signatures (if required)
   - **If transitions invalid, claim invalid**

### Verification Requirements

**Required:**
- MTB file (JSON or ZIP)
- Public repository (for schema and policy rules)
- Verification code (canonical JSON, hash computation)

**Not Required:**
- Execution engine
- Trust in operator
- Trust in author
- Trust in environment
- Authority approval

### Verification Result

**If all steps pass**: Claim is valid. The MTB is cryptographically proven and structurally valid.

**If any step fails**: Claim is invalid. The specific violated invariant is identified.

**There is no appeal process.** Verification is deterministic and final.

---

## 4. Why Results Are Final and Non-Appealable

Results are final because verification is:
1. **Deterministic**: Same MTB always produces same verification result
2. **Cryptographic**: Proofs are mathematically verifiable
3. **Public**: Verification code and rules are public
4. **Independent**: No authority required
5. **Exhaustive**: All required checks are performed

### Determinism

Verification is a pure function:
- Input: MTB file
- Output: Valid or Invalid (with specific error)

Same MTB → same result. No randomness, no time dependencies, no environment dependencies.

### Cryptographic Proofs

All proofs are cryptographic:
- Integrity proof: SHA-256 hash (or declared algorithm)
- Evidence proofs: SHA-256 hash per event
- Signatures: RSA-PSS-SHA256 (if present)

These are mathematically verifiable. No interpretation required.

### Public Verification

Verification code is public:
- Repository: https://github.com/kaaffilm/MK10-PRO
- Schema: `mtb/schema/mtb.schema.json`
- Policy: `engine/policy/rules.yaml`
- Verification code: `mtb/verify.py`, `mtb/seal.py`

Anyone can verify using only public code. No proprietary components.

### No Authority Required

Verification does not require:
- Execution engine
- Operator approval
- Author credentials
- Institutional authority

Only cryptographic proofs are required.

### Exhaustive Checks

All required checks are performed:
- Structure (12 fields, 8 nested structures)
- Integrity (MTB seal, all event seals)
- Lineage (acyclicity, traceability)
- Policy (all rules, 100% pass rate)
- Validation (all formats, 100% pass rate)
- Transitions (policy compliance)

If all checks pass, the claim is proven. If any check fails, the claim is invalid.

### No Appeal Process

There is no appeal because:
- Verification is deterministic (no interpretation)
- Proofs are cryptographic (mathematically verifiable)
- Rules are public (no hidden criteria)
- Process is transparent (all code public)

**If verification fails, the claim is invalid. Period.**

**If verification succeeds, the claim is valid. Period.**

---

## 5. Where System Authority Begins and Ends

### System Authority Begins

MK10-PRO has authority over:

1. **Claim Validity**: Whether an MTB is valid or invalid
   - Based on cryptographic proofs
   - Based on structural conformance
   - Based on policy compliance
   - No interpretation, no exceptions

2. **State Transitions**: Whether promotion is allowed
   - Based on evidence (not opinion)
   - Based on policy rules (not configuration)
   - Based on cryptographic proofs (not trust)

3. **Execution Determinism**: Whether execution is deterministic
   - Based on content addressing
   - Based on evidence verification
   - Based on reproducibility

4. **Format Validation**: Whether output is structurally valid
   - Based on schema conformance
   - Based on specification compliance
   - Structural validation only (no device testing)

### System Authority Ends

MK10-PRO has no authority over:

1. **File Content Correctness**: Does not verify file content matches intent
   - Only verifies structure and format
   - Does not verify artistic correctness
   - Does not verify business logic

2. **Device Playback**: Does not verify playback on specific devices
   - Only verifies structural conformance
   - Device compatibility is out of scope
   - Venue testing is out of scope

3. **Human Judgment**: Does not make artistic or business decisions
   - Only verifies evidence
   - Only enforces policy rules
   - No interpretation of intent

4. **Hardware/Infrastructure**: Does not manage hardware or venues
   - No device management
   - No venue management
   - No operator management

5. **External Systems**: Does not integrate with external systems
   - No database dependencies
   - No network dependencies (for verification)
   - No external service dependencies

6. **Business Logic**: Does not enforce business rules
   - Only enforces technical policy
   - Business decisions are out of scope

### Scope Boundary

**MK10-PRO scope: Pre-delivery truth only**

- ✅ In scope: Execution, evidence, validation, policy, verification
- ❌ Out of scope: Playback, devices, venues, operators, business logic

**The system produces verifiable claims about mastering execution.**
**The system does not produce or verify playback capability.**

---

## Summary

### Valid Claim

A valid claim is an MTB that:
- Conforms to schema
- Has valid integrity proof
- Has complete evidence with integrity proofs
- Has complete lineage
- Passes all policy rules
- Passes all format validations
- Has valid state transitions

### Claim Production

Claims are produced by:
- Deterministic execution of workflows
- Evidence generation at every step
- Cryptographic sealing of all evidence
- Policy-compliant state promotion

### Independent Verification

Verification requires:
- MTB file
- Public repository (schema, policy, code)
- Cryptographic verification (no trust required)

### Finality

Results are final because:
- Verification is deterministic
- Proofs are cryptographic
- Code is public
- No authority required
- All checks are exhaustive

### System Boundaries

MK10-PRO has authority over:
- Claim validity
- State transitions
- Execution determinism
- Format validation

MK10-PRO has no authority over:
- File content correctness
- Device playback
- Human judgment
- Hardware/infrastructure
- External systems
- Business logic

**The system produces verifiable claims. It does not produce trust.**

