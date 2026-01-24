# Hostile Verification Audit
## Exhaustive Zero-Trust Verification

**Hostile Verifier Stance:**
- ❌ Do NOT trust: engine, author, operator, environment, documentation
- ✅ DO trust: Only cryptographic proofs and public repository code
- 🎯 Goal: Invalidate the MTB claim if possible

**Given:**
- MTB file (JSON or ZIP)
- Public MK10-PRO repository (for schemas, policy rules, verification code)

---

## VERIFICATION STEP 1: MTB Load and Parse

### Actions:
1. Load MTB file (JSON or extract from ZIP)
2. Parse JSON structure
3. Verify JSON is well-formed

### Failure Paths:
- ❌ **FAIL**: File does not exist → "File not found"
- ❌ **FAIL**: File is not readable → "File access denied"
- ❌ **FAIL**: ZIP file is corrupted → "ZIP file corrupted"
- ❌ **FAIL**: ZIP file contains no JSON → "No MTB JSON file found in ZIP"
- ❌ **FAIL**: JSON parse error → "Invalid JSON: {error}"
- ❌ **FAIL**: JSON is not an object → "MTB must be JSON object"
- ❌ **FAIL**: JSON is empty → "MTB is empty"

### Hash Computations:
- None (parsing only)

### Result:
- ✅ **PASS**: MTB loaded and parsed successfully
- ❌ **FAIL**: Cannot proceed if load fails

---

## VERIFICATION STEP 2: Schema Structure Validation

### Actions:
1. Load schema from repository: `mtb/schema/mtb.schema.json`
2. Validate MTB against JSON Schema (Draft 7)
3. Check all required fields present
4. Validate field types
5. Validate enum constraints
6. Validate nested object structures

### Required Fields (12):
```python
required_fields = [
    "mtb_version",      # String
    "title",            # String
    "version",          # String
    "state",            # Enum: ["DRAFT", "CANDIDATE", "RELEASE", "ARCHIVED"]
    "ingest_manifest",  # Object
    "lineage_dag",      # Object
    "build_evidence",   # Object
    "policy_evidence",  # Object
    "validation_evidence",  # Object
    "approval_events",  # Array
    "integrity_proof",  # Object
    "archive_declaration"  # Object
]
```

### Schema Checks:

#### Top-Level Fields:
- ✅ `mtb_version`: String (non-empty)
- ✅ `title`: String (non-empty)
- ✅ `version`: String (non-empty)
- ✅ `state`: Enum ["DRAFT", "CANDIDATE", "RELEASE", "ARCHIVED"]
- ✅ `ingest_manifest`: Object (required)
- ✅ `lineage_dag`: Object (required)
- ✅ `build_evidence`: Object (required)
- ✅ `policy_evidence`: Object (required)
- ✅ `validation_evidence`: Object (required)
- ✅ `approval_events`: Array (required)
- ✅ `integrity_proof`: Object (required)
- ✅ `archive_declaration`: Object (required)

#### ingest_manifest:
- ✅ `assets`: Array (non-empty)
- ✅ Each asset: `content_address` (string), `path` (string), `hash` (string), `size` (integer)
- ✅ `ingest_timestamp`: String (ISO 8601)

#### lineage_dag:
- ✅ `nodes`: Array
- ✅ `edges`: Array
- ✅ `execution_order`: Array of strings

#### build_evidence:
- ✅ `execution_id`: String (non-empty)
- ✅ `events`: Array (non-empty)

#### policy_evidence:
- ✅ `rule_checks`: Array
- ✅ Each check: `rule_id` (string), `passed` (boolean)

#### validation_evidence:
- ✅ `validations`: Array
- ✅ Each validation: `format_type` (string), `passed` (boolean)

#### approval_events:
- ✅ Array of objects
- ✅ Each event: `from_state` (string), `to_state` (string), `timestamp` (string)

#### integrity_proof:
- ✅ `algorithm`: String
- ✅ `hash`: String (non-empty, hex)

#### archive_declaration:
- ✅ `declared_at`: String (ISO 8601)
- ✅ `intent`: String

### Failure Paths:
- ❌ **FAIL**: Schema file not found → "Schema file not found in repository"
- ❌ **FAIL**: Schema file invalid → "Schema file is invalid JSON"
- ❌ **FAIL**: Missing required field → "Required field missing: {field}"
- ❌ **FAIL**: Wrong field type → "Field {field} has wrong type: expected {type}, got {actual}"
- ❌ **FAIL**: Invalid enum value → "Field {field} has invalid value: {value}"
- ❌ **FAIL**: Nested required field missing → "Nested required field missing: {path}"
- ❌ **FAIL**: Empty required array → "Required array {field} is empty"
- ❌ **FAIL**: Schema validation error → "Schema validation error: {error}"

### Hash Computations:
- None (structure validation only)

### Result:
- ✅ **PASS**: All schema checks pass
- ❌ **FAIL**: Cannot proceed if schema validation fails

---

## VERIFICATION STEP 3: Integrity Proof Verification

### Actions:
1. Extract `integrity_proof` from MTB
2. Extract `algorithm` (default: "sha256")
3. Extract `hash` (expected hash)
4. Remove `integrity_proof` from MTB copy
5. Compute canonical JSON of MTB without proof
6. Compute hash using declared algorithm
7. Compare computed hash with expected hash

### Hash Computation Process:

```python
# Step 1: Remove integrity_proof
mtb_without_proof = {k: v for k, v in mtb.items() if k != "integrity_proof"}

# Step 2: Canonical JSON (sorted keys, no whitespace)
canonical_json = json.dumps(
    mtb_without_proof,
    sort_keys=True,
    separators=(",", ":"),
    ensure_ascii=False,
    allow_nan=False
)

# Step 3: Compute hash
canonical_bytes = canonical_json.encode("utf-8")
hash_obj = hashlib.new(algorithm)  # algorithm from integrity_proof
hash_obj.update(canonical_bytes)
computed_hash = hash_obj.hexdigest()

# Step 4: Compare
expected_hash = integrity_proof["hash"]
seal_valid = (computed_hash == expected_hash)
```

### Failure Paths:
- ❌ **FAIL**: `integrity_proof` missing → "Integrity proof missing"
- ❌ **FAIL**: `integrity_proof` is not object → "Integrity proof must be object"
- ❌ **FAIL**: `integrity_proof.hash` missing → "Integrity proof hash missing"
- ❌ **FAIL**: `integrity_proof.hash` is not string → "Integrity proof hash must be string"
- ❌ **FAIL**: `integrity_proof.hash` is empty → "Integrity proof hash is empty"
- ❌ **FAIL**: `integrity_proof.algorithm` unsupported → "Unsupported hash algorithm: {algorithm}"
- ❌ **FAIL**: Hash length invalid → "Hash length invalid: expected {expected}, got {actual}"
- ❌ **FAIL**: Hash not hexadecimal → "Hash is not hexadecimal: {hash}"
- ❌ **FAIL**: Hash mismatch → "Integrity proof verification failed: computed={computed}, expected={expected}"
- ❌ **FAIL**: Canonical JSON computation error → "Canonical JSON error: {error}"
- ❌ **FAIL**: Hash computation error → "Hash computation error: {error}"

### Hash Computations:
- **Hash 1**: SHA-256 of canonical JSON (MTB without integrity_proof)
- **Comparison**: computed_hash == expected_hash

### Result:
- ✅ **PASS**: Seal verification passes
- ❌ **FAIL**: Cannot proceed if seal verification fails

---

## VERIFICATION STEP 4: Evidence Integrity Verification

### Actions:
1. Extract `build_evidence.events` array
2. For each event, verify `integrity_proof` present
3. For each event, recompute hash and verify
4. Check event structure and types
5. Verify event ordering

### Evidence Event Verification:

For each event in `build_evidence.events` (index i):

```python
# Step 1: Check integrity_proof present
if "integrity_proof" not in event:
    FAIL: "Event {i} missing integrity_proof"

# Step 2: Extract integrity_proof
integrity_proof = event["integrity_proof"]
expected_hash = integrity_proof.get("hash")
algorithm = integrity_proof.get("algorithm", "sha256")

# Step 3: Remove integrity_proof from event
event_without_proof = {k: v for k, v in event.items() if k != "integrity_proof"}

# Step 4: Compute canonical hash
canonical = canonical_json_bytes(event_without_proof)
computed_hash = compute_hash(canonical, algorithm)

# Step 5: Compare
if computed_hash != expected_hash:
    FAIL: "Event {i} integrity_proof mismatch: computed={computed}, expected={expected}"
```

### Event Type Checks:

Required event types (in order):
1. `execution_start` - Exactly one
2. `node_execution` - One per node (count must match lineage_dag.nodes)
3. `execution_complete` - Exactly one
4. `execution_failure` - Must be absent (if present, execution failed)

### Event Structure Checks:

#### execution_start:
- ✅ `event_type`: "execution_start"
- ✅ `execution_id`: String (matches build_evidence.execution_id)
- ✅ `dag_id`: String
- ✅ `node_order`: Array
- ✅ `timestamp`: String (ISO 8601)
- ✅ `integrity_proof`: Object

#### node_execution:
- ✅ `event_type`: "node_execution"
- ✅ `node_id`: String
- ✅ `node_type`: String
- ✅ `inputs`: Array of content addresses
- ✅ `output`: Content address
- ✅ `evidence`: Object
- ✅ `timestamp`: String (ISO 8601)
- ✅ `integrity_proof`: Object

#### execution_complete:
- ✅ `event_type`: "execution_complete"
- ✅ `execution_id`: String (matches build_evidence.execution_id)
- ✅ `outputs`: Object mapping node_id to content_address
- ✅ `timestamp`: String (ISO 8601)
- ✅ `integrity_proof`: Object

### Failure Paths:
- ❌ **FAIL**: `build_evidence.events` missing → "Build evidence events missing"
- ❌ **FAIL**: `build_evidence.events` is not array → "Build evidence events must be array"
- ❌ **FAIL**: `build_evidence.events` is empty → "Build evidence events is empty"
- ❌ **FAIL**: Event missing `integrity_proof` → "Event {i} missing integrity_proof"
- ❌ **FAIL**: Event hash mismatch → "Event {i} integrity_proof mismatch"
- ❌ **FAIL**: Missing `execution_start` → "Missing execution_start event"
- ❌ **FAIL**: Multiple `execution_start` → "Multiple execution_start events"
- ❌ **FAIL**: Missing `execution_complete` → "Missing execution_complete event"
- ❌ **FAIL**: Multiple `execution_complete` → "Multiple execution_complete events"
- ❌ **FAIL**: `execution_failure` present → "Execution failure event present"
- ❌ **FAIL**: Event count mismatch → "Event count mismatch: expected {expected}, got {actual}"
- ❌ **FAIL**: Invalid event type → "Invalid event type: {type}"
- ❌ **FAIL**: Event structure invalid → "Event {i} structure invalid: {error}"

### Hash Computations:
- **Hash per event**: SHA-256 of canonical JSON (event without integrity_proof)
- **Total hashes**: N events = N hash computations

### Result:
- ✅ **PASS**: All evidence events have valid integrity proofs
- ❌ **FAIL**: Cannot proceed if any event fails verification

---

## VERIFICATION STEP 5: Lineage DAG Verification

### Actions:
1. Extract `lineage_dag`
2. Verify DAG structure (nodes, edges, execution_order)
3. Check for cycles (DAG must be acyclic)
4. Verify execution_order matches topological sort
5. Verify all outputs trace to ingest
6. Verify node IDs are unique

### DAG Structure Checks:

```python
# Step 1: Extract components
nodes = lineage_dag["nodes"]
edges = lineage_dag["edges"]
execution_order = lineage_dag["execution_order"]

# Step 2: Check node IDs match execution_order
node_ids = {node["id"] for node in nodes}
if set(execution_order) != node_ids:
    FAIL: "Execution order doesn't match node IDs"

# Step 3: Check for cycles (DFS)
visited = set()
rec_stack = set()

def has_cycle(node_id):
    visited.add(node_id)
    rec_stack.add(node_id)
    for edge in edges:
        if edge["source"] == node_id:
            target = edge["target"]
            if target not in visited:
                if has_cycle(target):
                    return True
            elif target in rec_stack:
                return True  # Cycle detected
    rec_stack.remove(node_id)
    return False

for node_id in node_ids:
    if node_id not in visited:
        if has_cycle(node_id):
            FAIL: "Lineage DAG contains cycles"
```

### Lineage Traceability:

```python
# Step 1: Get all ingest assets
ingest_assets = {asset["content_address"] for asset in ingest_manifest["assets"]}

# Step 2: Get all node outputs from events
node_outputs = {}
for event in build_evidence["events"]:
    if event["event_type"] == "node_execution":
        node_id = event["node_id"]
        output = event["output"]
        node_outputs[node_id] = output

# Step 3: Verify all outputs trace to ingest or previous nodes
for node_id in execution_order:
    node = next(n for n in nodes if n["id"] == node_id)
    dependencies = [e["target"] for e in edges if e["source"] == node_id]
    
    if not dependencies:
        # Root node - must trace to ingest
        inputs = event["inputs"]  # From node_execution event
        for inp in inputs:
            if inp not in ingest_assets:
                FAIL: "Root node input not in ingest: {inp}"
    else:
        # Dependent node - must trace to dependencies
        for dep_id in dependencies:
            if dep_id not in node_outputs:
                FAIL: "Dependency output missing: {dep_id}"
```

### Failure Paths:
- ❌ **FAIL**: Missing `nodes` → "Lineage DAG missing nodes"
- ❌ **FAIL**: Missing `edges` → "Lineage DAG missing edges"
- ❌ **FAIL**: Missing `execution_order` → "Lineage DAG missing execution_order"
- ❌ **FAIL**: `nodes` is not array → "Lineage DAG nodes must be array"
- ❌ **FAIL**: `edges` is not array → "Lineage DAG edges must be array"
- ❌ **FAIL**: `execution_order` is not array → "Lineage DAG execution_order must be array"
- ❌ **FAIL**: Cycle detected → "Lineage DAG contains cycles"
- ❌ **FAIL**: Execution order mismatch → "Execution order doesn't match nodes"
- ❌ **FAIL**: Duplicate node IDs → "Duplicate node IDs in lineage DAG"
- ❌ **FAIL**: Orphan output → "Output cannot be traced to ingest: {output}"
- ❌ **FAIL**: Missing dependency → "Dependency output missing: {dep_id}"
- ❌ **FAIL**: Invalid edge reference → "Edge references non-existent node: {node_id}"

### Hash Computations:
- None (structure validation only)

### Result:
- ✅ **PASS**: Lineage DAG is valid and complete
- ❌ **FAIL**: Cannot proceed if lineage invalid

---

## VERIFICATION STEP 6: Policy Evidence Verification

### Actions:
1. Extract `policy_evidence.rule_checks`
2. Load policy rules from repository: `engine/policy/rules.yaml`
3. Verify all rules have checks
4. Verify all checks passed
5. Check rule IDs match policy

### Policy Rule Verification:

```python
# Step 1: Load policy rules
policy_rules = load_policy_rules("engine/policy/rules.yaml")
rule_ids = {rule["id"] for rule in policy_rules}

# Step 2: Extract rule checks
rule_checks = policy_evidence["rule_checks"]
check_rule_ids = {check["rule_id"] for check in rule_checks}

# Step 3: Verify all rules checked
if rule_ids != check_rule_ids:
    missing = rule_ids - check_rule_ids
    FAIL: "Policy rules not checked: {missing}"

# Step 4: Verify all checks passed
for check in rule_checks:
    if not check["passed"]:
        FAIL: "Policy rule failed: {check['rule_id']}"
```

### Required Policy Rules (from repository):

From `engine/policy/rules.yaml`:
- `determinism_required` - Must pass
- `evidence_required` - Must pass
- `lineage_required` - Must pass
- `validation_required` - Must pass
- `immutability_required` - Must pass
- `playability_required` - Must pass

### Failure Paths:
- ❌ **FAIL**: Policy rules file not found → "Cannot load policy rules"
- ❌ **FAIL**: Policy rules file invalid → "Policy rules file is invalid YAML"
- ❌ **FAIL**: Missing rule check → "Policy rule not checked: {rule_id}"
- ❌ **FAIL**: Rule check failed → "Policy rule failed: {rule_id}"
- ❌ **FAIL**: Invalid rule ID → "Invalid rule ID: {rule_id}"
- ❌ **FAIL**: Duplicate rule checks → "Duplicate rule check: {rule_id}"
- ❌ **FAIL**: Rule check structure invalid → "Rule check structure invalid: {error}"

### Hash Computations:
- None (policy check validation only)

### Result:
- ✅ **PASS**: All policy rules checked and passed
- ❌ **FAIL**: Cannot proceed if policy fails

---

## VERIFICATION STEP 7: Validation Evidence Verification

### Actions:
1. Extract `validation_evidence.validations`
2. Verify all validations passed
3. Verify format types are declared
4. Check validation structure

### Validation Verification:

```python
# Step 1: Extract validations
validations = validation_evidence["validations"]

# Step 2: Verify all passed
for validation in validations:
    if not validation["passed"]:
        FAIL: "Validation failed: {validation['format_type']}"
    
    # Step 3: Verify structure
    if "format_type" not in validation:
        FAIL: "Validation missing format_type"
    if "details" not in validation:
        FAIL: "Validation missing details"
```

### Failure Paths:
- ❌ **FAIL**: `validations` missing → "Validation evidence validations missing"
- ❌ **FAIL**: `validations` is not array → "Validation evidence validations must be array"
- ❌ **FAIL**: Validation failed → "Validation failed: {format_type}"
- ❌ **FAIL**: Missing `format_type` → "Validation missing format_type"
- ❌ **FAIL**: Missing `details` → "Validation missing details"
- ❌ **FAIL**: No validations → "No validation evidence"
- ❌ **FAIL**: Duplicate format types → "Duplicate validation for format: {format_type}"

### Hash Computations:
- None (validation check only)

### Result:
- ✅ **PASS**: All validations passed
- ❌ **FAIL**: Cannot proceed if validation fails

---

## VERIFICATION STEP 8: State Transition Verification

### Actions:
1. Extract `approval_events`
2. Verify state transitions are valid
3. Check transition requirements met
4. Verify signatures (if required)
5. Verify state matches final transition

### State Transition Checks:

```python
# Step 1: Load state definitions
states = load_states("engine/policy/states.yaml")

# Step 2: Verify transitions
current_state = mtb["state"]
for event in approval_events:
    from_state = event["from_state"]
    to_state = event["to_state"]
    
    # Check transition is allowed
    if not is_transition_allowed(from_state, to_state, states):
        FAIL: "Invalid state transition: {from_state} -> {to_state}"
    
    # Check requirements met (from policy)
    if to_state == "RELEASE":
        # Must have signature
        if "signer" not in event:
            FAIL: "RELEASE transition missing signer"
```

### Valid State Transitions (from policy):

- DRAFT → CANDIDATE (requires: execution_complete, validation_passed)
- CANDIDATE → RELEASE (requires: policy_approved, signed_approval)
- RELEASE → ARCHIVED (requires: archive_declaration)
- ARCHIVED → (no transitions allowed)

### Failure Paths:
- ❌ **FAIL**: `approval_events` missing → "Approval events missing"
- ❌ **FAIL**: `approval_events` is not array → "Approval events must be array"
- ❌ **FAIL**: Invalid transition → "Invalid state transition: {from} -> {to}"
- ❌ **FAIL**: Missing signature → "RELEASE transition missing signature"
- ❌ **FAIL**: Invalid signature → "Signature verification failed"
- ❌ **FAIL**: Transition requirements not met → "Transition requirements not met"
- ❌ **FAIL**: State mismatch → "State {state} doesn't match final transition {to_state}"

### Hash Computations:
- Signature verification (if signatures present): RSA-PSS-SHA256 verification

### Result:
- ✅ **PASS**: All state transitions valid
- ❌ **FAIL**: Cannot proceed if transitions invalid

---

## VERIFICATION STEP 9: Content Address Verification

### Actions:
1. Extract all content addresses from ingest_manifest
2. Extract all content addresses from node outputs
3. Verify content addresses are valid (hash-based)
4. Check for duplicates
5. Verify hash format

### Content Address Format:

Content addresses must be: `{hash_hex}{extension}`

Example: `a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789.mxf`

### Verification:

```python
# Step 1: Extract all content addresses
ingest_addresses = {asset["content_address"] for asset in ingest_manifest["assets"]}

node_addresses = set()
for event in build_evidence["events"]:
    if event["event_type"] == "node_execution":
        node_addresses.add(event["output"])

# Step 2: Verify format
for addr in ingest_addresses | node_addresses:
    # Extract hash and extension
    if '.' in addr:
        hash_part = addr[:addr.rfind('.')]
        ext = addr[addr.rfind('.'):]
    else:
        hash_part = addr
        ext = ""
    
    # Verify hash is hex
    try:
        int(hash_part, 16)
    except ValueError:
        FAIL: "Invalid content address format: {addr}"
    
    # Verify hash length (SHA-256 = 64 hex chars)
    if len(hash_part) != 64:
        FAIL: "Invalid hash length in content address: {addr}"
```

### Failure Paths:
- ❌ **FAIL**: Invalid format → "Invalid content address format: {addr}"
- ❌ **FAIL**: Invalid hash length → "Invalid hash length: {addr}"
- ❌ **FAIL**: Non-hex hash → "Content address hash not hexadecimal: {addr}"
- ❌ **FAIL**: Missing content address → "Asset missing content_address"

### Hash Computations:
- None (format validation only)

### Result:
- ✅ **PASS**: All content addresses valid
- ❌ **FAIL**: Cannot proceed if addresses invalid

---

## VERIFICATION STEP 10: Ingest Manifest Verification

### Actions:
1. Extract ingest_manifest.assets
2. Verify all assets have required fields
3. Verify hash matches content_address
4. Verify size matches content_address (if derivable)

### Ingest Asset Verification:

```python
for asset in ingest_manifest["assets"]:
    # Step 1: Check required fields
    required = ["content_address", "path", "hash", "size"]
    for field in required:
        if field not in asset:
            FAIL: "Asset missing required field: {field}"
    
    # Step 2: Verify hash matches content_address
    content_addr = asset["content_address"]
    hash_value = asset["hash"]
    
    # Extract hash from content address
    if '.' in content_addr:
        addr_hash = content_addr[:content_addr.rfind('.')]
    else:
        addr_hash = content_addr
    
    if addr_hash != hash_value:
        FAIL: "Asset hash mismatch: content_address={content_addr}, hash={hash_value}"
    
    # Step 3: Verify size is non-negative
    if asset["size"] < 0:
        FAIL: "Asset size invalid: {asset['size']}"
```

### Failure Paths:
- ❌ **FAIL**: Missing required field → "Asset missing field: {field}"
- ❌ **FAIL**: Hash mismatch → "Asset hash mismatch: {asset}"
- ❌ **FAIL**: Invalid size → "Asset size invalid: {size}"
- ❌ **FAIL**: Empty assets array → "Ingest manifest assets is empty"

### Hash Computations:
- None (comparison only)

### Result:
- ✅ **PASS**: All ingest assets valid
- ❌ **FAIL**: Cannot proceed if assets invalid

---

## VERIFICATION STEP 11: Execution ID Verification

### Actions:
1. Extract execution_id from build_evidence
2. Verify execution_id is deterministic format
3. Verify execution_id matches across events

### Execution ID Verification:

```python
# Step 1: Extract execution_id
execution_id = build_evidence["execution_id"]

# Step 2: Verify format (should be hash-based)
if not is_hex_string(execution_id):
    FAIL: "Execution ID not deterministic format"

# Step 3: Verify matches across events
for event in build_evidence["events"]:
    if event.get("execution_id") and event["execution_id"] != execution_id:
        FAIL: "Execution ID mismatch in event: {event}"
```

### Failure Paths:
- ❌ **FAIL**: Execution ID missing → "Execution ID missing"
- ❌ **FAIL**: Execution ID not deterministic → "Execution ID not deterministic format"
- ❌ **FAIL**: Execution ID mismatch → "Execution ID mismatch in event"

### Hash Computations:
- None (format validation only)

### Result:
- ✅ **PASS**: Execution ID is valid
- ❌ **FAIL**: Cannot proceed if execution ID invalid

---

## VERIFICATION STEP 12: Final Comprehensive Check

### Actions:
1. Verify all required sections present and non-empty
2. Verify no contradictions in evidence
3. Verify temporal consistency (if applicable)
4. Final integrity check

### Comprehensive Checks:

```python
# Step 1: Required sections
required_sections = [
    "ingest_manifest",
    "lineage_dag",
    "build_evidence",
    "policy_evidence",
    "validation_evidence",
    "approval_events",
    "integrity_proof",
    "archive_declaration"
]

for section in required_sections:
    if section not in mtb:
        FAIL: "Required section missing: {section}"
    if not mtb[section]:
        FAIL: "Required section empty: {section}"

# Step 2: Check for contradictions
# - execution_complete and execution_failure cannot both be present
# - state must match final approval_event.to_state
# - All node outputs must be in execution_complete.outputs

# Step 3: Final integrity proof re-verification
if not verify_seal(mtb):
    FAIL: "Final seal verification failed"
```

### Failure Paths:
- ❌ **FAIL**: Section missing → "Required section missing: {section}"
- ❌ **FAIL**: Section empty → "Required section empty: {section}"
- ❌ **FAIL**: Contradiction → "Evidence contradiction: {description}"
- ❌ **FAIL**: Final seal fails → "Final seal verification failed"

### Hash Computations:
- **Final hash**: Re-compute MTB seal hash (same as Step 3)

### Result:
- ✅ **PASS**: All comprehensive checks pass
- ❌ **FAIL**: Cannot accept if any check fails

---

## SUMMARY: All Hash Computations

### Total Hash Computations:

1. **MTB Integrity Proof**: 1 hash
   - Algorithm: SHA-256 (or declared algorithm)
   - Input: Canonical JSON of MTB (without integrity_proof)
   - Output: 64-character hex string

2. **Evidence Events**: N hashes (N = number of events)
   - Algorithm: SHA-256 (per event integrity_proof)
   - Input: Canonical JSON of each event (without integrity_proof)
   - Output: 64-character hex string per event

3. **Signature Verifications**: M verifications (M = number of signatures)
   - Algorithm: RSA-PSS-SHA256
   - Input: Canonical JSON of signed data
   - Output: Boolean (signature valid/invalid)

**Total**: 1 + N + M cryptographic operations

---

## FINAL VERDICT

### If All Verification Steps Pass:

**CLAIM MUST BE ACCEPTED**

**Reasoning:**
1. **Structure Valid**: MTB conforms to schema (proven by JSON Schema validation)
2. **Integrity Proven**: Seal verification passes (cryptographic proof)
3. **Evidence Sealed**: All evidence events have valid integrity proofs
4. **Lineage Complete**: All outputs trace to ingest (proven by DAG verification)
5. **Policy Compliant**: All policy rules checked and passed
6. **Validations Passed**: All format validations passed
7. **Transitions Valid**: All state transitions are policy-compliant
8. **Deterministic**: Execution appears deterministic

**Conclusion**: The MTB claim is **cryptographically provable** and **structurally valid**. As a hostile verifier, I cannot invalidate the claim because:
- All cryptographic proofs verify
- All structural constraints satisfied
- All policy requirements met
- All evidence is sealed and verifiable

**The claim stands.**

### If Any Verification Step Fails:

**CLAIM INVALIDATED**

**Precise Invariant Violation:**

The specific invariant violated depends on which step fails:

1. **Step 1-2 Failure**: "Structure Invalid" → Violates MTB schema requirement
2. **Step 3 Failure**: "Integrity Proof Invalid" → Violates immutability requirement
3. **Step 4 Failure**: "Evidence Invalid" → Violates evidence requirement
4. **Step 5 Failure**: "Lineage Invalid" → Violates lineage requirement
5. **Step 6 Failure**: "Policy Violation" → Violates policy requirement
6. **Step 7 Failure**: "Validation Failed" → Violates validation requirement
7. **Step 8 Failure**: "State Transition Invalid" → Violates state transition rules
8. **Step 9 Failure**: "Content Address Invalid" → Violates content addressing requirement
9. **Step 10 Failure**: "Ingest Invalid" → Violates ingest manifest requirement
10. **Step 11 Failure**: "Execution ID Invalid" → Violates determinism requirement
11. **Step 12 Failure**: "Comprehensive Check Failed" → Violates overall MTB validity

**Conclusion**: The MTB claim is **invalid** because the specific invariant listed above is violated. The claim cannot be accepted.

---

## HOSTILE VERIFICATION PRINCIPLES

As a hostile verifier, I:
- ✅ Trust only cryptographic proofs
- ✅ Trust only public repository code
- ✅ Verify all hashes independently
- ✅ Check all constraints
- ✅ Accept only if all proofs verify
- ❌ Do NOT trust the engine
- ❌ Do NOT trust the operator
- ❌ Do NOT trust the author
- ❌ Do NOT trust the environment

**If verification succeeds, the claim is cryptographically proven and must be accepted.**
**If verification fails, the claim is invalid and must be rejected.**

