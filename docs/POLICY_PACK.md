# MK10-PRO Policy Pack

## Policy Purpose

The MK10-PRO Policy Pack enforces deterministic pre-delivery truth infrastructure.

**Core Principles:**
- All claims are provable through evidence
- All transformations are deterministic and verifiable
- All outputs are formally validated
- All state transitions are evidence-gated
- No file falls again (location, verification, explanation, reproduction, playability, re-delivery)

**Fundamental Rule:** Policy operates exclusively on evidence. Opinion, intent, and configuration are irrelevant.

## Required Artifacts

### Execution Artifacts

1. **execution_start_event**
   - Type: Evidence event
   - Required fields: execution_id, dag_id, node_order, timestamp, integrity_proof
   - Purpose: Records execution initiation

2. **node_execution_events**
   - Type: Evidence events (one per node)
   - Required fields: node_id, node_type, inputs, output, evidence, timestamp, integrity_proof
   - Requirement: One event per executed node

3. **execution_complete_event**
   - Type: Evidence event
   - Required fields: execution_id, outputs, timestamp, integrity_proof
   - Requirement: Exactly one event per execution

### Validation Artifacts

4. **format_validation_evidence**
   - Type: Evidence events
   - Required fields: format_type, passed, details, timestamp, integrity_proof
   - Requirement: At least one validation per declared output format

### Policy Artifacts

5. **policy_check_evidence**
   - Type: Evidence events
   - Required fields: rule_id, passed, details, timestamp, integrity_proof
   - Requirement: One check per policy rule

### MTB Artifacts

6. **ingest_manifest**
   - Type: MTB section
   - Required fields: assets, ingest_timestamp
   - Requirement: At least one asset

7. **lineage_dag**
   - Type: MTB section
   - Required fields: nodes, edges, execution_order
   - Requirement: Complete provenance graph

8. **build_evidence**
   - Type: MTB section
   - Required fields: execution_id, events
   - Requirement: All execution events

9. **policy_evidence**
   - Type: MTB section
   - Required fields: rule_checks
   - Requirement: All policy rule checks

10. **validation_evidence**
    - Type: MTB section
    - Required fields: validations
    - Requirement: All format validations

11. **integrity_proof**
    - Type: MTB section
    - Required fields: algorithm, hash
    - Requirement: Canonical hash of MTB

## Mandatory Validations

### 1. Determinism Validation

**Requirement:** Execution must be deterministic. Same inputs + same engine + same policy = same outputs.

**Evidence Required:**
- execution_complete_event
- node_execution_events (all)

**Validation Logic:**
1. All node outputs must have content addresses
2. Content addresses must be deterministic (hash-based)
3. Re-execution with same inputs must produce identical content addresses

**Threshold:** 100% of nodes must produce deterministic outputs

**Refusal Condition:** Any node output is non-deterministic

### 2. Evidence Completeness Validation

**Requirement:** All transformations must emit sealed evidence.

**Evidence Required:**
- execution_start_event
- node_execution_events (all)
- execution_complete_event

**Validation Logic:**
1. Every node execution must have corresponding evidence event
2. Every evidence event must have integrity_proof
3. Evidence must be canonical and verifiable

**Threshold:** 100% of node executions must have evidence

**Refusal Condition:** Any node execution lacks evidence or integrity_proof

### 3. Lineage Completeness Validation

**Requirement:** All outputs must trace to ingest via verifiable DAG.

**Evidence Required:**
- ingest_manifest
- lineage_dag
- node_execution_events (all)

**Validation Logic:**
1. All outputs must have content addresses
2. All content addresses must trace to ingest assets or node outputs
3. Lineage DAG must be acyclic and complete
4. No orphan outputs

**Threshold:** 100% of outputs must have complete lineage

**Refusal Condition:** Any output cannot be traced to ingest

### 4. Format Validation

**Requirement:** All outputs must be formally validated for declared format.

**Evidence Required:**
- format_validation_evidence (all)

**Validation Logic:**
1. Every declared output format must have validation evidence
2. All validations must pass (passed == true)
3. Validation must be structural/spec conformance only
4. No device playback validation (out of scope)

**Threshold:** 100% of declared formats must pass validation

**Refusal Condition:** Any format validation fails or is missing

### 5. Integrity Validation

**Requirement:** MTB must be sealed with verifiable integrity proof.

**Evidence Required:**
- integrity_proof

**Validation Logic:**
1. MTB must have integrity_proof section
2. Integrity proof must be canonical hash of MTB (without proof)
3. Hash algorithm must be declared and supported
4. Hash verification must pass

**Threshold:** Integrity proof must be valid

**Refusal Condition:** Integrity proof missing, invalid, or verification fails

### 6. Policy Compliance Validation

**Requirement:** All policy rules must be satisfied.

**Evidence Required:**
- policy_check_evidence (all)

**Validation Logic:**
1. Every policy rule must have check evidence
2. All rule checks must pass (passed == true)
3. No rule violations allowed

**Threshold:** 100% of policy rules must pass

**Refusal Condition:** Any policy rule fails

## Thresholds

### Execution Thresholds

- **node_execution_evidence_ratio**: 1.0 (100%)
  - 100% of nodes must have execution evidence
  - Refusal if below threshold

- **execution_complete_required**: true
  - Execution must complete successfully
  - Refusal if missing

- **deterministic_outputs_ratio**: 1.0 (100%)
  - 100% of outputs must be deterministic
  - Refusal if below threshold

### Evidence Thresholds

- **integrity_proof_coverage**: 1.0 (100%)
  - 100% of evidence events must have integrity_proof
  - Refusal if below threshold

- **canonical_format_required**: true
  - All evidence must be canonical JSON
  - Refusal if invalid

### Validation Thresholds

- **format_validation_pass_rate**: 1.0 (100%)
  - 100% of format validations must pass
  - Refusal if below threshold

- **declared_format_coverage**: 1.0 (100%)
  - 100% of declared formats must have validation
  - Refusal if below threshold

### Lineage Thresholds

- **output_lineage_completeness**: 1.0 (100%)
  - 100% of outputs must have complete lineage to ingest
  - Refusal if below threshold

- **dag_acyclicity_required**: true
  - Lineage DAG must be acyclic
  - Refusal if cyclic

### Policy Thresholds

- **rule_check_pass_rate**: 1.0 (100%)
  - 100% of policy rules must pass
  - Refusal if below threshold

- **rule_check_coverage**: 1.0 (100%)
  - 100% of policy rules must have check evidence
  - Refusal if below threshold

### Integrity Thresholds

- **mtb_seal_required**: true
  - MTB must be sealed with integrity proof
  - Refusal if missing

- **seal_verification_required**: true
  - MTB seal must verify successfully
  - Refusal if invalid

## Promotion Permissions

### DRAFT → CANDIDATE

**Required Evidence:**
- execution_complete_event
- format_validation_evidence (all declared formats)
- policy_check_evidence (all rules)

**Required Validations:**
- determinism_validation: pass
- evidence_completeness_validation: pass
- format_validation: pass
- policy_compliance_validation: pass

**Required Thresholds:**
- execution.node_execution_evidence_ratio: 1.0
- execution.deterministic_outputs_ratio: 1.0
- validation.format_validation_pass_rate: 1.0
- policy.rule_check_pass_rate: 1.0

**Refusal Conditions:**
- Execution incomplete or failed
- Any format validation fails
- Any policy rule fails
- Evidence incomplete
- Non-deterministic outputs

### CANDIDATE → RELEASE

**Required Evidence:**
- policy_check_evidence (all rules passed)
- state_transition_event (with signature)

**Required Validations:**
- policy_compliance_validation: pass
- integrity_validation: pass

**Required Thresholds:**
- policy.rule_check_pass_rate: 1.0
- integrity.mtb_seal_required: true
- integrity.seal_verification_required: true

**Required Signatures:**
- approval_signature: required

**Refusal Conditions:**
- Any policy rule fails
- MTB not sealed
- Seal verification fails
- Approval signature missing or invalid

### RELEASE → ARCHIVED

**Required Evidence:**
- archive_declaration_event

**Required Validations:**
- integrity_validation: pass

**Required Thresholds:**
- integrity.mtb_seal_required: true
- integrity.seal_verification_required: true

**Refusal Conditions:**
- Archive declaration missing
- MTB seal invalid

### ARCHIVED

**Status:** Terminal state. No transitions allowed.

**Refusal Conditions:**
- Any transition from ARCHIVED is refused

## Explicit Refusal Conditions

### Determinism Violations

1. **Non-deterministic execution**
   - Evidence check: Any node output is non-deterministic
   - Refusal reason: Violates determinism axiom
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

2. **Missing execution evidence**
   - Evidence check: Any node execution lacks evidence event
   - Refusal reason: Violates evidence requirement
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

### Validation Failures

3. **Format validation failure**
   - Evidence check: Any format validation has passed == false
   - Refusal reason: Output not formally playable
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

4. **Missing format validation**
   - Evidence check: Declared format lacks validation evidence
   - Refusal reason: Format not validated
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

### Policy Violations

5. **Policy rule failure**
   - Evidence check: Any policy_check has passed == false
   - Refusal reason: Policy rule violated
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

6. **Missing policy check**
   - Evidence check: Any policy rule lacks check evidence
   - Refusal reason: Policy compliance unverified
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

### Integrity Violations

7. **Missing integrity proof**
   - Evidence check: MTB lacks integrity_proof section
   - Refusal reason: MTB not sealed
   - States blocked: RELEASE, ARCHIVED

8. **Invalid integrity proof**
   - Evidence check: Integrity proof verification fails
   - Refusal reason: MTB integrity compromised
   - States blocked: RELEASE, ARCHIVED

### Evidence Violations

9. **Missing integrity_proof on evidence**
   - Evidence check: Any evidence event lacks integrity_proof
   - Refusal reason: Evidence not sealed
   - States blocked: CANDIDATE, RELEASE, ARCHIVED

10. **Non-canonical evidence**
    - Evidence check: Evidence not in canonical JSON format
    - Refusal reason: Evidence not verifiable
    - States blocked: CANDIDATE, RELEASE, ARCHIVED

### State Transition Violations

11. **Invalid state transition**
    - Evidence check: State transition not allowed by policy
    - Refusal reason: Transition requirements not met
    - States blocked: CANDIDATE, RELEASE, ARCHIVED

12. **Missing approval signature**
    - Evidence check: CANDIDATE → RELEASE transition lacks signature
    - Refusal reason: Approval not authorized
    - States blocked: RELEASE, ARCHIVED

13. **Invalid approval signature**
    - Evidence check: Approval signature verification fails
    - Refusal reason: Approval not authentic
    - States blocked: RELEASE, ARCHIVED

### Lineage Violations

14. **Cyclic lineage DAG**
    - Evidence check: Lineage DAG contains cycles
    - Refusal reason: Lineage graph invalid
    - States blocked: CANDIDATE, RELEASE, ARCHIVED

15. **Orphan outputs**
    - Evidence check: Outputs exist without lineage to ingest
    - Refusal reason: Provenance incomplete
    - States blocked: CANDIDATE, RELEASE, ARCHIVED

### Execution Violations

16. **Execution incomplete**
    - Evidence check: execution_complete event missing or execution_failure present
    - Refusal reason: Execution did not complete successfully
    - States blocked: CANDIDATE, RELEASE, ARCHIVED

17. **Execution failure**
    - Evidence check: execution_failure event present
    - Refusal reason: Execution failed
    - States blocked: CANDIDATE, RELEASE, ARCHIVED

## Enforcement

**Policy is law. No exceptions.**

- **strict**: true
- **on_violation**: reject
- **allow_overrides**: false
- **allow_warnings**: false
- **allow_partial**: false

All policy rules are mandatory. All thresholds are absolute. No configuration can override policy. No warnings substitute for failures. Evidence is the only source of truth. Opinion is irrelevant.

