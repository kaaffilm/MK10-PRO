# MK10-PRO — AUTHORITATIVE SYSTEM MEMO

**State:** Determinism CLOSED · System PARTIALLY COMPLETE · Truth Law ACTIVE  
**Audience:** Engineers, auditors, hostile verifiers, future maintainers  
**Tone:** Mechanical, non-interpretive, final where stated

---

## 1. SYSTEM IDENTITY (FROZEN)

**MK10-PRO is deterministic pre-delivery truth infrastructure.**

* Not a tool
* Not a workflow
* Not a validator
* Not a playback system
* Not trust-based

It converts **audiovisual mastering claims** into **provable, sealed facts**.

If a claim cannot be proven mechanically, MK10-PRO treats it as invalid.

---

## 2. AXIOMS (IMMUTABLE LAW)

1. **Truth is executable**
   Claims emerge only from execution.

2. **Evidence is the product**
   Files are inputs. Evidence bundles are outcomes.

3. **Policy is law**
   Configuration cannot override rules.

4. **Verification is hostile**
   No engine. No trust. No authority required.

5. **Determinism is mandatory**
   Same inputs must yield identical outputs.

6. **Scope ends before institutions**
   Hardware, venues, operators, playback devices are out of bounds.

Violation of any axiom → system invalid.

---

## 3. CURRENT SYSTEM STATUS (CRITICAL)

| Domain                     | Status         | Meaning                              |
| -------------------------- | -------------- | ------------------------------------ |
| Determinism                | ✅ CLOSED       | Mechanically enforced, non-forgeable |
| Execution semantics        | ✅ LAW          | Pure DAG, fatal aborts               |
| Evidence generation        | ✅ ACTIVE       | Canonical, hash-sealed               |
| Verifier authority         | ⚠️ INCOMPLETE   | Imports engine; not standalone       |
| Root ingest binding        | ❌ MISSING      | No input binding; system invalid     |
| Policy completeness        | ⚠️ INCOMPLETE   | Simplified checks; gaps exist        |
| Cross-platform determinism | ❌ EXCLUDED     | Out of scope; no claim made          |

---

## 4. DETERMINISM — FINAL VERDICT

**Status: CLOSED**

Determinism is no longer a claim. It is mechanically enforced.

### What is enforced (engine/core/engine.py)

* Double execution of every node
* Canonical comparison of outputs
* Canonical comparison of evidence (excluding proof)
* File existence symmetry enforcement
* File byte hash comparison
* Node source code hash (NO fallback)
* Execution context hash
* Input mutation detection (before & after each execution)
* Fatal abort on any mismatch
* Determinism proof emitted into evidence

### What is impossible now

* Silent non-determinism
* "Looks deterministic" behavior
* Mutating inputs without detection
* Different code sharing a hash
* One execution writing files and the other not

**Axiom 5 is mechanically closed.**

---

## 5. DETERMINISM PROOF MODEL

Each node emits:

```json
{
  "determinism_proof": {
    "verified": true,
    "method": "double_execution",
    "node_code_hash": "sha256:…",
    "context_hash": "sha256:…",
    "inputs_hash": "sha256:…",
    "outputs_hash": "sha256:…",
    "executions": 2
  }
}
```

Verifier checks:

* Proof presence
* verified == true
* Proof integrity via MTB seal

Verifier **does not re-execute**.

---

## 6. EXECUTION MODEL (LAW)

* Work is a DAG
* Nodes are pure transformations
* No hidden state
* No retries
* No warnings
* No recovery
* Failures are typed and fatal
* Evidence emitted for every step

---

## 7. PRODUCT DEFINITION

### The product is NOT files.

The product is the **Master Truth Bundle (MTB)**.

If the MTB validates → the title exists
If it does not → the title is not real

---

## 8. MTB — AUTHORITATIVE CONTENTS

An MTB must contain:

* Ingest manifest (inputs + hashes)
* Lineage DAG
* Build evidence
* Policy evidence
* Validation evidence
* Approval / promotion events
* Determinism proofs
* Integrity seal
* Archive declaration

Nothing optional. Nothing inferred.

---

## 9. KNOWN LIMITATIONS (EXPLICIT, NON-AMBIGUOUS)

### 9.1 Root Ingest Binding — OPEN

* Root DAG nodes currently have no bound inputs
* Affects reproducibility, not determinism
* **System MUST be considered invalid** if:

  * Policy does not forbid unresolved roots
  * Verifier does not reject MTBs missing ingest-bound lineage

This is the **primary ontological gap**.

---

### 9.2 Policy Completeness — PARTIAL

* Lineage checks simplified
* Integrity checks simplified
* Condition evaluation shallow

Does NOT undermine determinism.
Does undermine claim completeness.

---

### 9.3 Resource Determinism — OUT OF SCOPE

* CPU features
* SIMD
* External library behavior

Correctly excluded.
No claim is made. No fix required.

---

## 10. VERIFIER STATUS (IMPORTANT)

### Current state

* Verifier exists
* Still imports from engine
* Not yet fully standalone
* Authority leakage remains

### Required state

* Zero engine imports
* Schema + hash only
* Rejects ambiguity
* Rejects missing ingest binding
* Rejects missing determinism proofs

**Until this is complete, truth authority is not fully externalized.**

---

## 11. SYSTEM VALIDITY CONDITIONS (BINARY)

MK10-PRO is **valid** only if:

* Determinism proof exists for all nodes ✅
* Evidence is sealed ✅
* Policy forbids unresolved roots ❌ (pending)
* Verifier rejects invalid MTBs ❌ (pending)

Anything else → INVALID.

---

## 12. NEXT NON-NEGOTIABLE STEP

**Root ingest binding.**

Reason:

* It is where truth enters the system
* Without it, everything above is correct but unanchored
* Policy and verifier depend on it

Do NOT:

* Expand policy breadth first
* Add new formats
* Add performance features
* Add usability layers

Those are distractions.

---

