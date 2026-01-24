# MK10-PRO Implementation Prompts
## Precision Prompts for Mechanical Fixes

**Purpose:** These prompts are designed to **mechanically fix each incomplete domain** in MK10-PRO **without violating any axiom**.

**Usage:** Use these prompts verbatim with an LLM, code reviewer, or yourself in "hostile mode".

**These are not "creative" prompts.**
**They are precision prompts intended to drive correct implementation, review, and rejection behavior.**

---

## 🔒 GLOBAL CONSTRAINT PROMPT (ALWAYS PREFIX)

> You are operating under MK10-PRO axioms.
> Reject any solution that:
>
> * introduces non-determinism
> * relies on trust, defaults, or interpretation
> * allows silent failure or fallback
> * weakens verifier authority
> * permits validity without mechanical enforcement
>
> If any axiom is violated, respond with **REJECTED** and state which axiom is broken.

---

## 1️⃣ ROOT INGEST BINDING — **PRIMARY FIX (HIGHEST PRIORITY)**

### Prompt: Ingest Manifest Schema

> Design a **minimal, content-addressed ingest manifest schema** for MK10-PRO.
>
> Requirements:
>
> * Must bind **all root DAG inputs** explicitly
> * Each asset must have:
>
>   * content hash
>   * declared role
>   * immutable metadata
> * No filesystem discovery
> * No defaults
> * No inference
> * Canonical JSON only
>
> Output:
>
> 1. JSON Schema (`ingest.schema.json`)
> 2. Example valid ingest manifest
> 3. List of rejection conditions the verifier must enforce
>
> If any root input can exist without an ingest entry, **REJECT**.

---

### Prompt: Engine Enforcement (`_collect_inputs`)

> Rewrite `_collect_inputs()` so that:
>
> * Root nodes **must** receive inputs from the ingest manifest
> * Absence of ingest binding causes immediate fatal abort
> * No execution may proceed with unresolved root inputs
>
> Provide:
>
> * Exact code diff
> * Failure modes
> * Error types raised
>
> Reject any design that allows execution with `pass`, empty inputs, or implicit discovery.

---

### Prompt: Verifier Enforcement (Root Binding)

> Define a verifier rule that **rejects any MTB** where:
>
> * A root DAG node has no ingest-bound inputs
> * An ingest asset is unused
> * A DAG input cannot be traced to ingest
>
> The verifier must:
>
> * Require no engine
> * Use only MTB + schema
> * Fail closed
>
> Output rejection logic in pseudocode.
>
> If the verifier can accept an MTB with unresolved roots, **REJECT**.

---

## 2️⃣ VERIFIER AUTHORITY — **STANDALONE HOSTILE VERIFIER**

### Prompt: Verifier Decoupling

> Refactor the MK10-PRO verifier so that:
>
> * It has **zero imports** from `engine/`
> * It depends only on:
>
>   * json
>   * hashlib
>   * jsonschema
> * All truth validation happens here
>
> Provide:
>
> * New verifier folder structure
> * List of removed dependencies
> * Proof that the engine can be deleted without weakening verification
>
> Any dependency on engine logic → **REJECT**.

---

### Prompt: Hostile Verification Steps

> Enumerate the **complete hostile verification sequence** for MK10-PRO.
>
> Requirements:
>
> * Determinism proof validation
> * Ingest binding validation
> * Lineage completeness
> * Policy satisfaction
> * Integrity seal verification
>
> Output must be:
>
> * Ordered
> * Binary (pass/fail)
> * Non-interpretive
>
> If any step relies on trust or narrative, **REJECT**.

---

## 3️⃣ POLICY COMPLETENESS — **LAW, NOT CONFIG**

### Prompt: Lineage Completeness Enforcement

> Design a policy rule that enforces:
>
> * Every output traces back to ingest
> * No orphan nodes
> * No cycles
> * No skipped transformations
>
> Provide:
>
> * Formal definition of "complete lineage"
> * Mechanical checks
> * Verifier rejection conditions
>
> If lineage can be "assumed", **REJECT**.

---

### Prompt: Policy Condition Evaluation

> Rewrite `_evaluate_condition()` to:
>
> * Support all declared operators
> * Reject unknown operators
> * Reject malformed rules
> * Never default to True
>
> Provide:
>
> * Operator table
> * Failure behavior
> * Example rejected policy
>
> Any permissive default → **REJECT**.

---

## 4️⃣ SYSTEM INVALIDATION RULES — **NO GREY STATES**

### Prompt: Invalid State Enumeration

> Enumerate **all states** in which MK10-PRO must be considered **INVALID**.
>
> Include:
>
> * Missing ingest binding
> * Missing determinism proof
> * Partial evidence
> * Policy bypass
> * Verifier ambiguity
>
> Output as a strict invalidation matrix.
>
> If any invalid state is "recoverable", **REJECT**.

---

## 5️⃣ RELEASE-BLOCKING PROMPT (FINAL GATE)

> Evaluate whether MK10-PRO can be released publicly as a truth system.
>
> Criteria:
>
> * Verifier is standalone
> * Root ingest binding enforced
> * Determinism closed
> * Invalid states explicit
>
> Output **only one** of:
>
> * **RELEASE-BLOCKED** (with exact blocking reasons)
> * **RELEASE-APPROVED**
>
> Any conditional approval → **REJECT**.

---

## USAGE INSTRUCTIONS

1. **Always prefix** with the Global Constraint Prompt
2. **Use prompts verbatim** — do not modify or interpret
3. **Apply hostile mode** — assume the implementer will try to violate axioms
4. **Reject immediately** if any axiom violation is detected
5. **No compromises** — binary pass/fail only

## PRIORITY ORDER

1. **Root Ingest Binding** (Primary Fix - Highest Priority)
2. **Verifier Authority** (Standalone Hostile Verifier)
3. **Policy Completeness** (Law, Not Config)
4. **System Invalidation Rules** (No Grey States)
5. **Release-Blocking** (Final Gate)

---

**These prompts are immutable. They define the mechanical path to system completion.**

