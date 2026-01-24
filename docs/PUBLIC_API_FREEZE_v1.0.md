# Public API Freeze — MK10-PRO v1.0
## Immutable Interface Lock

**Version:** 1.0.0  
**Date:** Release Lock

---

## FROZEN PUBLIC INTERFACES

### Engine Core (`engine/core/`)

**Frozen Classes:**
- `Engine` — Deterministic execution engine
- `ExecutionContext` — Immutable execution context
- `Node` — Abstract base class for transformation nodes
- `NodeInput` — Input dataclass
- `NodeOutput` — Output dataclass
- `DAG` — Directed acyclic graph
- `DAGEdge` — DAG edge representation

**Frozen Exceptions:**
- `MK10Error` — Base exception
- `DeterminismError` — Determinism violation
- `PolicyError` — Policy violation
- `ValidationError` — Validation failure
- `EvidenceError` — Evidence error
- `ExecutionError` — Execution failure
- `DAGError` — DAG error
- `MTBError` — MTB error
- `StateError` — State error
- `IngestError` — Ingest error

**Rule:** Any change to these interfaces requires new major version.

---

### Policy (`engine/policy/`)

**Frozen Classes:**
- `Policy` — Policy enforcement system

**Frozen Methods:**
- `check_rules()` — Check all policy rules
- `can_transition()` — Check state transition

**Rule:** Policy interface changes require new major version.

---

### Verifier (`verifier/`)

**Frozen Functions:**
- `verify_mtb()` — Main MTB verification
- `verify_root_ingest_binding()` — Root ingest binding verification
- `verify_policy_evidence()` — Policy evidence verification
- `verify_seal()` — Integrity seal verification
- `load_mtb()` — Load MTB from file
- `load_schema()` — Load JSON schema

**Rule:** Verifier interface changes require new major version.

---

### MTB Schema (`mtb/schema/`)

**Frozen Schemas:**
- `mtb.schema.json` — Master Truth Bundle schema
- `evidence.schema.json` — Evidence event schema
- `ingest.schema.json` — Ingest manifest schema

**Rule:** Schema changes require new major version.

---

## VERSIONING RULES

**Major Version Bump Required For:**
- Public API changes
- Schema changes
- Policy rule changes
- Verifier interface changes
- Breaking changes to MTB structure

**Minor Version Bump Allowed For:**
- Internal optimizations (no interface change)
- Bug fixes (no behavior change)
- Documentation updates

**Patch Version Bump Allowed For:**
- Documentation corrections
- Typo fixes

---

## FREEZE STATUS

**Public API:** ✅ **FROZEN**

**All interfaces locked for v1.0.**

**No modifications allowed without version bump and axiom review.**

