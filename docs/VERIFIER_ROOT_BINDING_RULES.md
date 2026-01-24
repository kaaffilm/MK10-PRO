# Verifier Root Binding Rules
## Standalone Hostile Verification

**Status:** ✅ **DEFINED**

**Requirement:** Verifier must reject any MTB with unresolved root inputs.

**Dependencies:** MTB + Schema only. No engine required.

---

## REJECTION CONDITIONS

### 1. Root DAG Node Has No Ingest-Bound Inputs

**Condition:** A root DAG node (node with no dependencies) has no corresponding ingest assets.

**Rejection:** `ROOT_INPUT_UNBOUND`

---

### 2. Ingest Asset Is Unused

**Condition:** An ingest asset exists in the manifest but is not referenced by any root DAG node.

**Rejection:** `INGEST_ASSET_UNUSED`

---

### 3. DAG Input Cannot Be Traced to Ingest

**Condition:** A DAG node input's content address cannot be traced back to an ingest asset.

**Rejection:** `DAG_INPUT_UNTraceABLE`

---

## VERIFICATION ALGORITHM (PSEUDOCODE)

```pseudocode
FUNCTION verify_root_binding(mtb: MTB) -> VerificationResult:
    """
    Verify that all root DAG nodes have ingest-bound inputs.
    
    Returns:
        VerificationResult with valid=true if all checks pass,
        valid=false with errors if any check fails.
    """
    
    result = VerificationResult(valid=true, errors=[])
    
    // Step 1: Extract required data structures
    ingest_manifest = mtb.ingest_manifest
    lineage_dag = mtb.lineage_dag
    
    IF ingest_manifest IS NULL:
        result.errors.append("Missing ingest_manifest in MTB")
        result.valid = false
        RETURN result
    
    IF lineage_dag IS NULL:
        result.errors.append("Missing lineage_dag in MTB")
        result.valid = false
        RETURN result
    
    // Step 2: Build ingest asset index by role
    ingest_assets_by_role = {}
    ingest_asset_hashes = {}
    
    FOR EACH asset IN ingest_manifest.assets:
        role = asset.role
        content_hash = asset.content_hash
        
        IF role NOT IN ingest_assets_by_role:
            ingest_assets_by_role[role] = []
        ingest_assets_by_role[role].append(asset)
        
        ingest_asset_hashes[content_hash] = asset
    
    // Step 3: Identify root nodes (nodes with no incoming edges)
    root_nodes = []
    node_dependencies = {}
    
    FOR EACH edge IN lineage_dag.edges:
        target = edge.target
        IF target NOT IN node_dependencies:
            node_dependencies[target] = []
        node_dependencies[target].append(edge.source)
    
    FOR EACH node_id IN lineage_dag.nodes:
        IF node_id NOT IN node_dependencies:
            root_nodes.append(node_id)
    
    // Step 4: Verify each root node has ingest-bound inputs
    FOR EACH root_node_id IN root_nodes:
        root_node = FIND node IN lineage_dag.nodes WHERE node.id == root_node_id
        
        IF root_node IS NULL:
            result.errors.append(f"Root node {root_node_id} not found in lineage_dag.nodes")
            result.valid = false
            CONTINUE
        
        // Determine required input roles for this root node
        required_roles = root_node.config.required_input_roles
        
        IF required_roles IS EMPTY:
            // Try metadata fallback
            required_roles = root_node.config.metadata.input_roles
            
        IF required_roles IS EMPTY:
            // Last resort: use node_id as role
            required_roles = [root_node_id]
        
        // Check if each required role has matching ingest assets
        FOR EACH role IN required_roles:
            IF role NOT IN ingest_assets_by_role:
                result.errors.append(
                    f"Root node {root_node_id} requires role '{role}', " +
                    f"but no matching asset in ingest manifest"
                )
                result.valid = false
                CONTINUE
            
            matching_assets = ingest_assets_by_role[role]
            
            IF matching_assets IS EMPTY:
                result.errors.append(
                    f"Root node {root_node_id} requires role '{role}', " +
                    f"but no matching assets found"
                )
                result.valid = false
                CONTINUE
        
        // Verify root node inputs can be traced to ingest
        root_node_inputs = root_node.inputs
        
        FOR EACH input IN root_node_inputs:
            input_content_address = input.content_address
            
            // Extract hash from content address (format: "hash" or "hash.ext")
            input_hash = EXTRACT_HASH_FROM_CONTENT_ADDRESS(input_content_address)
            
            IF input_hash NOT IN ingest_asset_hashes:
                result.errors.append(
                    f"Root node {root_node_id} input {input_content_address} " +
                    f"cannot be traced to ingest manifest"
                )
                result.valid = false
    
    // Step 5: Verify all ingest assets are used
    used_asset_hashes = {}
    
    FOR EACH root_node_id IN root_nodes:
        root_node = FIND node IN lineage_dag.nodes WHERE node.id == root_node_id
        root_node_inputs = root_node.inputs
        
        FOR EACH input IN root_node_inputs:
            input_hash = EXTRACT_HASH_FROM_CONTENT_ADDRESS(input.content_address)
            used_asset_hashes[input_hash] = true
    
    FOR EACH asset IN ingest_manifest.assets:
        asset_hash = asset.content_hash
        
        IF asset_hash NOT IN used_asset_hashes:
            result.errors.append(
                f"Ingest asset {asset.asset_id} (role: {asset.role}, hash: {asset_hash}) " +
                f"is not used by any root DAG node"
            )
            result.valid = false
    
    // Step 6: Verify all DAG inputs can be traced to ingest
    // (This includes non-root nodes that depend on root outputs)
    all_node_inputs = {}
    
    FOR EACH node IN lineage_dag.nodes:
        FOR EACH input IN node.inputs:
            input_hash = EXTRACT_HASH_FROM_CONTENT_ADDRESS(input.content_address)
            all_node_inputs[input_hash] = {
                node_id: node.id,
                input: input
            }
    
    // Build traceability map: hash -> source (ingest or node output)
    traceable_hashes = COPY ingest_asset_hashes
    
    // Add node outputs to traceable hashes
    FOR EACH node IN lineage_dag.nodes:
        node_output = node.output
        IF node_output IS NOT NULL:
            output_hash = EXTRACT_HASH_FROM_CONTENT_ADDRESS(node_output.content_address)
            traceable_hashes[output_hash] = {
                source_type: "node_output",
                node_id: node.id
            }
    
    // Verify all inputs are traceable
    FOR EACH input_hash, input_info IN all_node_inputs:
        IF input_hash NOT IN traceable_hashes:
            node_id = input_info.node_id
            result.errors.append(
                f"Node {node_id} input {input_info.input.content_address} " +
                f"(hash: {input_hash}) cannot be traced to ingest or node output"
            )
            result.valid = false
    
    RETURN result


FUNCTION EXTRACT_HASH_FROM_CONTENT_ADDRESS(content_address: string) -> string:
    """
    Extract hash from content address.
    
    Content address format: "hash" or "hash.ext"
    Returns: hash portion only
    """
    
    // Split by '.' to separate hash from extension
    parts = content_address.split('.')
    hash_part = parts[0]
    
    // Verify hash format (64 hex chars for SHA-256)
    IF hash_part MATCHES PATTERN "^[a-f0-9]{64}$":
        RETURN hash_part
    ELSE:
        // If not standard format, return as-is (will fail traceability check)
        RETURN hash_part
```

---

## VERIFICATION STEPS (ORDERED)

1. **Load MTB Structure**
   - Extract `ingest_manifest`
   - Extract `lineage_dag`
   - Reject if either is missing

2. **Build Ingest Index**
   - Index assets by role
   - Index assets by content hash
   - Reject if no assets exist

3. **Identify Root Nodes**
   - Find nodes with no incoming edges
   - Reject if no root nodes found (invalid DAG)

4. **Verify Root Node Binding**
   - For each root node, determine required roles
   - Check if roles have matching ingest assets
   - Reject if any role is unbound

5. **Verify Ingest Asset Usage**
   - Check if all ingest assets are used by root nodes
   - Reject if any asset is unused

6. **Verify Traceability**
   - Build traceability map (ingest + node outputs)
   - Check if all DAG inputs are traceable
   - Reject if any input is untraceable

---

## REJECTION ERROR CODES

| Error Code | Condition | Fatal? |
|------------|-----------|--------|
| `ROOT_INPUT_UNBOUND` | Root node has no ingest-bound inputs | ✅ YES |
| `INGEST_ASSET_UNUSED` | Ingest asset not used by any root node | ✅ YES |
| `DAG_INPUT_UNTraceABLE` | DAG input cannot be traced to ingest | ✅ YES |
| `MISSING_INGEST_MANIFEST` | MTB missing ingest_manifest | ✅ YES |
| `MISSING_LINEAGE_DAG` | MTB missing lineage_dag | ✅ YES |
| `NO_ROOT_NODES` | DAG has no root nodes | ✅ YES |

**All rejections are fatal. No warnings. No recovery.**

---

## IMPLEMENTATION REQUIREMENTS

### Dependencies

**Allowed:**
- `json` (standard library)
- `hashlib` (standard library)
- `jsonschema` (for schema validation)

**Forbidden:**
- Any import from `engine/`
- Any import from `mtb/` (except schema)
- Any filesystem access beyond reading MTB
- Any network access
- Any execution of nodes

### Input

- MTB file path (or MTB JSON object)
- Schema files (ingest.schema.json, mtb.schema.json)

### Output

- `VerificationResult` object with:
  - `valid: bool`
  - `errors: List[str]`
  - `warnings: List[str]` (empty - no warnings allowed)

---

## BINARY DECISION LOGIC

```pseudocode
FUNCTION is_mtb_valid(mtb: MTB) -> bool:
    """
    Binary validity check.
    
    Returns:
        true if MTB is valid (all checks pass)
        false if MTB is invalid (any check fails)
    """
    
    result = verify_root_binding(mtb)
    
    IF result.valid == false:
        RETURN false
    
    // Additional checks (determinism, seal, etc.)
    // ...
    
    RETURN true
```

**No partial validity. No conditional acceptance. Binary only.**

---

## EXAMPLE REJECTION SCENARIOS

### Scenario 1: Root Node Missing Role

```json
{
  "ingest_manifest": {
    "assets": [
      {"role": "source_video", "content_hash": "abc123..."}
    ]
  },
  "lineage_dag": {
    "nodes": [
      {
        "id": "root_node_1",
        "config": {
          "required_input_roles": ["source_audio"]  // Missing in ingest
        }
      }
    ]
  }
}
```

**Rejection:** `ROOT_INPUT_UNBOUND` - Root node requires 'source_audio' but no matching asset

---

### Scenario 2: Unused Ingest Asset

```json
{
  "ingest_manifest": {
    "assets": [
      {"role": "source_video", "content_hash": "abc123..."},
      {"role": "unused_asset", "content_hash": "def456..."}  // Not used
    ]
  },
  "lineage_dag": {
    "nodes": [
      {
        "id": "root_node_1",
        "config": {
          "required_input_roles": ["source_video"]
        }
      }
    ]
  }
}
```

**Rejection:** `INGEST_ASSET_UNUSED` - Asset 'unused_asset' not used by any root node

---

### Scenario 3: Untraceable Input

```json
{
  "ingest_manifest": {
    "assets": [
      {"role": "source_video", "content_hash": "abc123..."}
    ]
  },
  "lineage_dag": {
    "nodes": [
      {
        "id": "root_node_1",
        "inputs": [
          {"content_address": "unknown_hash..."}  // Not in ingest
        ]
      }
    ]
  }
}
```

**Rejection:** `DAG_INPUT_UNTraceABLE` - Input 'unknown_hash...' cannot be traced to ingest

---

## STATUS

**Verification Logic:** ✅ **DEFINED**

**Standalone:** ✅ **NO ENGINE REQUIRED**

**Fail Closed:** ✅ **ALL REJECTIONS FATAL**

**Binary Decision:** ✅ **PASS/FAIL ONLY**

**If verifier can accept MTB with unresolved roots:** ❌ **REJECTED**

The verifier will reject any MTB where root inputs are not bound to ingest.

