# Hostile Verification Sequence
## Complete Mechanical Verification Steps

**Status:** ✅ **DEFINED**

**Requirement:** Ordered, binary (pass/fail), non-interpretive verification sequence.

**No trust. No narrative. Mechanical only.**

---

## VERIFICATION SEQUENCE (ORDERED)

### STEP 1: MTB Load and Parse

**Action:**
1. Load MTB file (JSON or extract from ZIP)
2. Parse JSON structure
3. Verify JSON is well-formed

**Failure Conditions:**
- ❌ **FAIL**: File does not exist
- ❌ **FAIL**: File is not readable
- ❌ **FAIL**: ZIP file is corrupted
- ❌ **FAIL**: ZIP file contains no JSON
- ❌ **FAIL**: JSON parse error
- ❌ **FAIL**: JSON is not an object
- ❌ **FAIL**: JSON is empty

**Result:**
- ✅ **PASS**: MTB loaded and parsed successfully
- ❌ **FAIL**: Cannot proceed if load fails

**Binary:** PASS / FAIL

---

### STEP 2: Schema Structure Validation

**Action:**
1. Load schema from repository: `mtb/schema/mtb.schema.json`
2. Validate MTB against JSON Schema (Draft 7)
3. Check all required fields present
4. Validate field types
5. Validate enum constraints
6. Validate nested object structures

**Required Fields:**
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

**Failure Conditions:**
- ❌ **FAIL**: Schema file not found
- ❌ **FAIL**: Schema is invalid JSON
- ❌ **FAIL**: Any required field missing
- ❌ **FAIL**: Any field type mismatch
- ❌ **FAIL**: Any enum value invalid
- ❌ **FAIL**: Any nested structure invalid

**Result:**
- ✅ **PASS**: MTB structure valid
- ❌ **FAIL**: Structure invalid (list all errors)

**Binary:** PASS / FAIL

---

### STEP 3: Integrity Seal Verification

**Action:**
1. Extract `integrity_proof` from MTB
2. Verify `integrity_proof` structure:
   - `algorithm` field exists
   - `hash` field exists
   - `algorithm` is "sha256"
3. Remove `integrity_proof` from MTB copy
4. Compute canonical JSON hash of MTB without proof
5. Compare computed hash with stored hash

**Hash Computation:**
```python
# Remove integrity_proof
mtb_without_proof = {k: v for k, v in mtb.items() if k != "integrity_proof"}

# Canonical JSON (sorted keys, no whitespace)
canonical = json.dumps(mtb_without_proof, sort_keys=True, separators=(",", ":"))

# SHA-256 hash
computed_hash = hashlib.sha256(canonical.encode("utf-8")).hexdigest()

# Compare
if computed_hash != integrity_proof["hash"]:
    FAIL
```

**Failure Conditions:**
- ❌ **FAIL**: `integrity_proof` missing
- ❌ **FAIL**: `integrity_proof.algorithm` missing or not "sha256"
- ❌ **FAIL**: `integrity_proof.hash` missing
- ❌ **FAIL**: Computed hash != stored hash
- ❌ **FAIL**: Hash format invalid (not 64 hex chars)

**Result:**
- ✅ **PASS**: Seal valid (hashes match)
- ❌ **FAIL**: Seal invalid (hashes mismatch)

**Binary:** PASS / FAIL

---

### STEP 4: Ingest Manifest Schema Validation

**Action:**
1. Extract `ingest_manifest` from MTB
2. Load schema: `mtb/schema/ingest.schema.json`
3. Validate ingest manifest against schema
4. Verify all required fields present
5. Verify asset structure:
   - `asset_id` (string, unique)
   - `content_hash` (64 hex chars, lowercase)
   - `hash_algorithm` (enum: ["sha256"])
   - `role` (string, non-empty)
   - `metadata` (object)

**Failure Conditions:**
- ❌ **FAIL**: `ingest_manifest` missing
- ❌ **FAIL**: Schema validation fails
- ❌ **FAIL**: Any asset missing required fields
- ❌ **FAIL**: `content_hash` format invalid
- ❌ **FAIL**: `hash_algorithm` not "sha256"
- ❌ **FAIL**: `asset_id` not unique
- ❌ **FAIL**: `assets` array empty

**Result:**
- ✅ **PASS**: Ingest manifest valid
- ❌ **FAIL**: Ingest manifest invalid

**Binary:** PASS / FAIL

---

### STEP 5: Root Ingest Binding Validation

**Action:**
1. Extract `lineage_dag` from MTB
2. Extract `ingest_manifest.assets` from MTB
3. Identify root nodes (nodes with no incoming edges)
4. For each root node:
   - Determine required input roles (from `config.required_input_roles` or fallback)
   - Check if each role has matching ingest assets
   - Verify root node inputs can be traced to ingest assets

**Root Node Identification:**
```python
# Build dependency map
dependencies = {}
for edge in lineage_dag["edges"]:
    target = edge["target"]
    if target not in dependencies:
        dependencies[target] = []
    dependencies[target].append(edge["source"])

# Root nodes have no dependencies
root_nodes = [node_id for node_id in lineage_dag["nodes"] 
              if node_id not in dependencies]
```

**Role Matching:**
```python
# Index assets by role
assets_by_role = {}
for asset in ingest_manifest["assets"]:
    role = asset["role"]
    if role not in assets_by_role:
        assets_by_role[role] = []
    assets_by_role[role].append(asset)

# Check root node requirements
for root_node_id in root_nodes:
    node = find_node(root_node_id, lineage_dag["nodes"])
    required_roles = node.get("config", {}).get("required_input_roles", [])
    
    if not required_roles:
        # Fallback: use node_id as role
        required_roles = [root_node_id]
    
    for role in required_roles:
        if role not in assets_by_role:
            FAIL: "Root node {root_node_id} requires role '{role}' but no matching asset"
        if len(assets_by_role[role]) == 0:
            FAIL: "Root node {root_node_id} requires role '{role}' but no assets found"
```

**Failure Conditions:**
- ❌ **FAIL**: No root nodes found (invalid DAG)
- ❌ **FAIL**: Root node requires role not in ingest manifest
- ❌ **FAIL**: Root node input cannot be traced to ingest asset
- ❌ **FAIL**: Ingest asset unused by any root node

**Result:**
- ✅ **PASS**: All root nodes have ingest-bound inputs
- ❌ **FAIL**: Root input unbound (list all unbound roles)

**Binary:** PASS / FAIL

---

### STEP 6: Lineage Completeness Validation

**Action:**
1. Extract `lineage_dag` from MTB
2. Verify DAG structure:
   - All nodes referenced in edges exist
   - No cycles (topological sort possible)
   - All nodes reachable from roots
3. Verify traceability:
   - Every node input traces to ingest or node output
   - No orphan nodes (except roots)
   - No broken dependencies

**Cycle Detection:**
```python
# Topological sort
def topological_sort(nodes, edges):
    in_degree = {node_id: 0 for node_id in nodes}
    for edge in edges:
        in_degree[edge["target"]] += 1
    
    queue = [node_id for node_id, degree in in_degree.items() if degree == 0]
    result = []
    
    while queue:
        node_id = queue.pop(0)
        result.append(node_id)
        
        for edge in edges:
            if edge["source"] == node_id:
                in_degree[edge["target"]] -= 1
                if in_degree[edge["target"]] == 0:
                    queue.append(edge["target"])
    
    if len(result) != len(nodes):
        FAIL: "Cycle detected"
    
    return result
```

**Traceability Check:**
```python
# Build traceability map
traceable_hashes = set()

# Add ingest asset hashes
for asset in ingest_manifest["assets"]:
    traceable_hashes.add(asset["content_hash"])

# Add node output hashes
for node in lineage_dag["nodes"]:
    if "output" in node and "content_address" in node["output"]:
        output_hash = extract_hash(node["output"]["content_address"])
        traceable_hashes.add(output_hash)

# Check all inputs are traceable
for node in lineage_dag["nodes"]:
    if "inputs" in node:
        for input_item in node["inputs"]:
            input_hash = extract_hash(input_item["content_address"])
            if input_hash not in traceable_hashes:
                FAIL: "Node {node_id} input {input_hash} not traceable"
```

**Failure Conditions:**
- ❌ **FAIL**: Cycle detected in DAG
- ❌ **FAIL**: Node referenced in edge does not exist
- ❌ **FAIL**: Orphan node (not reachable from roots)
- ❌ **FAIL**: Node input not traceable to ingest or node output
- ❌ **FAIL**: Broken dependency chain

**Result:**
- ✅ **PASS**: Lineage complete and traceable
- ❌ **FAIL**: Lineage incomplete (list all failures)

**Binary:** PASS / FAIL

---

### STEP 7: Determinism Proof Validation

**Action:**
1. Extract `build_evidence.events` from MTB
2. Filter events: `event_type == "node_execution"`
3. For each node execution event:
   - Verify `evidence.determinism_proof` exists
   - Verify `determinism_proof.verified == true`
   - Verify `determinism_proof.method == "double_execution"`
   - Verify `determinism_proof.node_code_hash` exists and is valid SHA-256
   - Verify `determinism_proof.context_hash` exists and is valid SHA-256
   - Verify `determinism_proof.inputs_hash` exists and is valid SHA-256
   - Verify `determinism_proof.outputs_hash` exists and is valid SHA-256
   - Verify `determinism_proof.executions == 2`

**Determinism Proof Structure:**
```json
{
  "event_type": "node_execution",
  "evidence": {
    "determinism_proof": {
      "verified": true,
      "method": "double_execution",
      "node_code_hash": "sha256:...",
      "context_hash": "sha256:...",
      "inputs_hash": "sha256:...",
      "outputs_hash": "sha256:...",
      "executions": 2
    }
  }
}
```

**Hash Validation:**
```python
def is_valid_sha256_hash(hash_str: str) -> bool:
    # Remove "sha256:" prefix if present
    hash_value = hash_str.replace("sha256:", "")
    # Check format: 64 hex chars, lowercase
    return len(hash_value) == 64 and all(c in '0123456789abcdef' for c in hash_value)
```

**Failure Conditions:**
- ❌ **FAIL**: No node execution events found
- ❌ **FAIL**: Any node execution event missing `determinism_proof`
- ❌ **FAIL**: Any `determinism_proof.verified != true`
- ❌ **FAIL**: Any `determinism_proof.method != "double_execution"`
- ❌ **FAIL**: Any hash field missing or invalid format
- ❌ **FAIL**: Any `determinism_proof.executions != 2`

**Result:**
- ✅ **PASS**: All nodes have valid determinism proofs
- ❌ **FAIL**: Determinism proof missing or invalid (list all failures)

**Binary:** PASS / FAIL

---

### STEP 8: Policy Satisfaction Validation

**Action:**
1. Extract `policy_evidence.rule_checks` from MTB
2. Load policy rules from repository: `engine/policy/rules.yaml` (or schema)
3. For each required rule:
   - Verify rule check exists in `policy_evidence`
   - Verify `rule_checks[].rule_id` matches required rule
   - Verify `rule_checks[].passed == true`
4. Verify state transitions are valid:
   - Extract `approval_events` from MTB
   - Verify each transition follows policy rules
   - Verify required validations passed before promotion

**Required Rules (from policy):**
```python
required_rules = [
    "determinism_required",
    "evidence_required",
    "format_validation_required",
    "policy_compliance_required"
]
```

**Policy Check Validation:**
```python
for required_rule in required_rules:
    rule_check = find_rule_check(required_rule, policy_evidence["rule_checks"])
    
    if rule_check is None:
        FAIL: "Required rule check missing: {required_rule}"
    
    if rule_check["passed"] != True:
        FAIL: "Required rule check failed: {required_rule}"
```

**State Transition Validation:**
```python
# Extract state transitions from approval_events
for event in approval_events:
    if event["event_type"] == "state_transition":
        from_state = event["from_state"]
        to_state = event["to_state"]
        
        # Verify transition is allowed by policy
        if not is_valid_transition(from_state, to_state, policy_rules):
            FAIL: "Invalid state transition: {from_state} -> {to_state}"
        
        # Verify required validations passed
        required_validations = get_required_validations(to_state, policy_rules)
        for validation in required_validations:
            if not validation_passed(validation, policy_evidence):
                FAIL: "Required validation not passed for transition: {validation}"
```

**Failure Conditions:**
- ❌ **FAIL**: Required rule check missing
- ❌ **FAIL**: Required rule check failed (`passed != true`)
- ❌ **FAIL**: Invalid state transition
- ❌ **FAIL**: Required validation not passed before promotion

**Result:**
- ✅ **PASS**: All policy rules satisfied
- ❌ **FAIL**: Policy violation (list all violations)

**Binary:** PASS / FAIL

---

### STEP 9: Validation Evidence Completeness

**Action:**
1. Extract `validation_evidence.validations` from MTB
2. Verify all required format validations performed:
   - DCP validation (if DCP format)
   - Other format validations as required
3. Verify all validations passed:
   - `validation.passed == true`
   - `validation.details` present
4. Verify validation evidence is sealed (if applicable)

**Required Validations:**
```python
# Based on format/state requirements
required_validations = [
    "format_validation",  # Always required
    "spec_conformance",    # If applicable
]
```

**Validation Check:**
```python
for required_validation in required_validations:
    validation = find_validation(required_validation, validation_evidence["validations"])
    
    if validation is None:
        FAIL: "Required validation missing: {required_validation}"
    
    if validation["passed"] != True:
        FAIL: "Required validation failed: {required_validation}"
    
    if "details" not in validation or not validation["details"]:
        FAIL: "Validation details missing: {required_validation}"
```

**Failure Conditions:**
- ❌ **FAIL**: Required validation missing
- ❌ **FAIL**: Required validation failed (`passed != true`)
- ❌ **FAIL**: Validation details missing
- ❌ **FAIL**: Validation evidence incomplete

**Result:**
- ✅ **PASS**: All validations complete and passed
- ❌ **FAIL**: Validation incomplete or failed

**Binary:** PASS / FAIL

---

### STEP 10: Evidence Integrity Verification

**Action:**
1. Extract `build_evidence.events` from MTB
2. For each event:
   - Verify event structure (required fields present)
   - Verify event integrity proof (if present)
   - Verify event timestamp format (ISO 8601)
3. Verify evidence completeness:
   - `execution_start` event exists
   - `execution_complete` event exists
   - All node executions have corresponding events
4. Verify evidence ordering:
   - Events are chronologically ordered (by timestamp)
   - No gaps in execution sequence

**Event Structure Check:**
```python
required_event_fields = {
    "execution_start": ["event_type", "execution_id", "timestamp"],
    "node_execution": ["event_type", "node_id", "timestamp", "evidence"],
    "execution_complete": ["event_type", "execution_id", "timestamp"]
}

for event in build_evidence["events"]:
    event_type = event["event_type"]
    required_fields = required_event_fields.get(event_type, [])
    
    for field in required_fields:
        if field not in event:
            FAIL: "Event missing required field: {field}"
```

**Evidence Completeness:**
```python
event_types = [event["event_type"] for event in build_evidence["events"]]

if "execution_start" not in event_types:
    FAIL: "Missing execution_start event"

if "execution_complete" not in event_types:
    FAIL: "Missing execution_complete event"

# Verify all nodes have execution events
node_executions = [e for e in build_evidence["events"] if e["event_type"] == "node_execution"]
node_ids_in_events = {e["node_id"] for e in node_executions}
node_ids_in_dag = {node["id"] for node in lineage_dag["nodes"]}

if node_ids_in_events != node_ids_in_dag:
    FAIL: "Node execution events incomplete"
```

**Failure Conditions:**
- ❌ **FAIL**: Event missing required fields
- ❌ **FAIL**: Event integrity proof invalid
- ❌ **FAIL**: Event timestamp format invalid
- ❌ **FAIL**: Missing `execution_start` event
- ❌ **FAIL**: Missing `execution_complete` event
- ❌ **FAIL**: Node execution events incomplete
- ❌ **FAIL**: Events not chronologically ordered

**Result:**
- ✅ **PASS**: Evidence complete and valid
- ❌ **FAIL**: Evidence incomplete or invalid

**Binary:** PASS / FAIL

---

## FINAL VERIFICATION RESULT

**All steps must PASS for MTB to be valid.**

**Result:**
- ✅ **PASS**: All 10 steps passed → MTB is valid
- ❌ **FAIL**: Any step failed → MTB is invalid

**Binary:** PASS / FAIL (no partial validity)

---

## VERIFICATION SUMMARY

| Step | Check | Binary |
|------|-------|--------|
| 1 | MTB Load and Parse | PASS / FAIL |
| 2 | Schema Structure Validation | PASS / FAIL |
| 3 | Integrity Seal Verification | PASS / FAIL |
| 4 | Ingest Manifest Schema Validation | PASS / FAIL |
| 5 | Root Ingest Binding Validation | PASS / FAIL |
| 6 | Lineage Completeness Validation | PASS / FAIL |
| 7 | Determinism Proof Validation | PASS / FAIL |
| 8 | Policy Satisfaction Validation | PASS / FAIL |
| 9 | Validation Evidence Completeness | PASS / FAIL |
| 10 | Evidence Integrity Verification | PASS / FAIL |

**All steps are:**
- ✅ Ordered (sequential execution)
- ✅ Binary (pass/fail only)
- ✅ Non-interpretive (mechanical checks only)
- ✅ No trust required (all checks are cryptographic or structural)

---

## REJECTION CONDITIONS

**If any step relies on:**
- Trust in operator → ❌ **REJECTED**
- Trust in author → ❌ **REJECTED**
- Interpretation of intent → ❌ **REJECTED**
- Narrative explanation → ❌ **REJECTED**
- Default assumptions → ❌ **REJECTED**

**All checks are mechanical and cryptographic.**

---

## STATUS

**Verification Sequence:** ✅ **COMPLETE**

**Ordered:** ✅ **10 STEPS**

**Binary:** ✅ **PASS / FAIL ONLY**

**Non-Interpretive:** ✅ **MECHANICAL CHECKS ONLY**

**No Trust Required:** ✅ **CRYPTOGRAPHIC PROOFS ONLY**

