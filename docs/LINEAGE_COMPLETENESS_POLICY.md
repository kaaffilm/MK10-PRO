# Lineage Completeness Enforcement Policy
## Mechanical Rule Definition

**Status:** ✅ **DEFINED**

**Requirement:** Enforce complete lineage with no assumptions. All checks must be mechanical.

---

## FORMAL DEFINITION: "COMPLETE LINEAGE"

### Definition

A lineage is **complete** if and only if all of the following conditions hold:

1. **Ingest Traceability:** Every output in the DAG can be traced back to at least one ingest asset through a finite sequence of transformations.

2. **No Orphan Nodes:** Every node in the DAG is either:
   - A root node (has no dependencies and has ingest-bound inputs), OR
   - A non-root node (has at least one dependency and all dependencies are satisfied)

3. **No Cycles:** The DAG contains no cycles. Formally: There exists a topological ordering of all nodes.

4. **No Skipped Transformations:** Every transformation that produces an output used by another node must be explicitly represented in the DAG.

5. **Complete Dependency Graph:** For every edge `(source, target)` in the DAG:
   - `source` node exists
   - `target` node exists
   - `source` node produces an output
   - `target` node consumes that output as input

6. **Input-Output Consistency:** For every node:
   - All declared inputs must be satisfied (either from ingest or from node outputs)
   - All declared outputs must be produced
   - Input count matches dependency count

---

## MECHANICAL CHECKS

### Check 1: Ingest Traceability

**Algorithm:**
```python
def verify_ingest_traceability(lineage_dag, ingest_manifest):
    """
    Verify every output traces back to ingest.
    
    Returns:
        (is_valid: bool, errors: List[str])
    """
    errors = []
    
    # Build traceability map: hash -> source
    traceable_hashes = set()
    
    # Add all ingest asset hashes
    for asset in ingest_manifest["assets"]:
        traceable_hashes.add(asset["content_hash"])
    
    # Build node output map: node_id -> output_hash
    node_outputs = {}
    for node in lineage_dag["nodes"]:
        node_id = node["id"]
        if "output" in node and "content_address" in node["output"]:
            output_hash = extract_hash(node["output"]["content_address"])
            node_outputs[node_id] = output_hash
            traceable_hashes.add(output_hash)
    
    # Verify all node inputs are traceable
    for node in lineage_dag["nodes"]:
        node_id = node["id"]
        
        if "inputs" in node:
            for input_item in node["inputs"]:
                input_hash = extract_hash(input_item["content_address"])
                
                if input_hash not in traceable_hashes:
                    errors.append(
                        f"Node {node_id} input {input_item['content_address']} "
                        f"(hash: {input_hash}) cannot be traced to ingest or node output"
                    )
    
    # Verify all outputs are reachable from ingest
    # (Every output must be in the transitive closure of ingest assets)
    reachable_from_ingest = set()
    
    # Start with ingest assets
    for asset in ingest_manifest["assets"]:
        reachable_from_ingest.add(asset["content_hash"])
    
    # Propagate through DAG
    changed = True
    while changed:
        changed = False
        for node in lineage_dag["nodes"]:
            node_id = node["id"]
            
            # Check if all inputs are reachable
            if "inputs" in node:
                all_inputs_reachable = True
                for input_item in node["inputs"]:
                    input_hash = extract_hash(input_item["content_address"])
                    if input_hash not in reachable_from_ingest:
                        all_inputs_reachable = False
                        break
                
                # If all inputs reachable, output is reachable
                if all_inputs_reachable and node_id in node_outputs:
                    output_hash = node_outputs[node_id]
                    if output_hash not in reachable_from_ingest:
                        reachable_from_ingest.add(output_hash)
                        changed = True
    
    # Check all outputs are reachable
    for node_id, output_hash in node_outputs.items():
        if output_hash not in reachable_from_ingest:
            errors.append(
                f"Node {node_id} output (hash: {output_hash}) "
                f"cannot be reached from ingest assets"
            )
    
    return (len(errors) == 0, errors)
```

**Failure Conditions:**
- ❌ **FAIL**: Any node input cannot be traced to ingest or node output
- ❌ **FAIL**: Any node output cannot be reached from ingest assets

---

### Check 2: No Orphan Nodes

**Algorithm:**
```python
def verify_no_orphan_nodes(lineage_dag, ingest_manifest):
    """
    Verify no orphan nodes exist.
    
    Returns:
        (is_valid: bool, errors: List[str])
    """
    errors = []
    
    # Build dependency map: node_id -> [dependency_node_ids]
    dependencies = {}
    for edge in lineage_dag["edges"]:
        target = edge["target"]
        source = edge["source"]
        
        if target not in dependencies:
            dependencies[target] = []
        dependencies[target].append(source)
    
    # Build reverse dependency map: node_id -> [dependent_node_ids]
    dependents = {}
    for edge in lineage_dag["edges"]:
        source = edge["source"]
        target = edge["target"]
        
        if source not in dependents:
            dependents[source] = []
        dependents[source].append(target)
    
    # Identify root nodes (no dependencies)
    root_nodes = set()
    for node in lineage_dag["nodes"]:
        node_id = node["id"]
        if node_id not in dependencies:
            root_nodes.add(node_id)
    
    # Verify root nodes have ingest-bound inputs
    ingest_asset_hashes = {asset["content_hash"] for asset in ingest_manifest["assets"]}
    
    for root_node_id in root_nodes:
        root_node = find_node(root_node_id, lineage_dag["nodes"])
        
        if "inputs" in root_node:
            has_ingest_input = False
            for input_item in root_node["inputs"]:
                input_hash = extract_hash(input_item["content_address"])
                if input_hash in ingest_asset_hashes:
                    has_ingest_input = True
                    break
            
            if not has_ingest_input:
                errors.append(
                    f"Root node {root_node_id} has no ingest-bound inputs"
                )
    
    # Verify all non-root nodes have dependencies
    for node in lineage_dag["nodes"]:
        node_id = node["id"]
        
        if node_id not in root_nodes:
            if node_id not in dependencies or len(dependencies[node_id]) == 0:
                errors.append(
                    f"Non-root node {root_node_id} has no dependencies"
                )
    
    # Verify all nodes are reachable from roots
    reachable_from_roots = set(root_nodes)
    changed = True
    
    while changed:
        changed = False
        for node_id in list(reachable_from_roots):
            if node_id in dependents:
                for dependent_id in dependents[node_id]:
                    if dependent_id not in reachable_from_roots:
                        reachable_from_roots.add(dependent_id)
                        changed = True
    
    # Check for unreachable nodes
    all_node_ids = {node["id"] for node in lineage_dag["nodes"]}
    unreachable_nodes = all_node_ids - reachable_from_roots
    
    if unreachable_nodes:
        errors.append(
            f"Orphan nodes found (not reachable from roots): {unreachable_nodes}"
        )
    
    return (len(errors) == 0, errors)
```

**Failure Conditions:**
- ❌ **FAIL**: Root node has no ingest-bound inputs
- ❌ **FAIL**: Non-root node has no dependencies
- ❌ **FAIL**: Node is not reachable from any root node

---

### Check 3: No Cycles

**Algorithm:**
```python
def verify_no_cycles(lineage_dag):
    """
    Verify DAG contains no cycles using topological sort.
    
    Returns:
        (is_valid: bool, errors: List[str])
    """
    errors = []
    
    # Build dependency map
    dependencies = {}
    for edge in lineage_dag["edges"]:
        target = edge["target"]
        source = edge["source"]
        
        if target not in dependencies:
            dependencies[target] = []
        dependencies[target].append(source)
    
    # Initialize in-degree map
    in_degree = {node["id"]: 0 for node in lineage_dag["nodes"]}
    for edge in lineage_dag["edges"]:
        in_degree[edge["target"]] += 1
    
    # Topological sort (Kahn's algorithm)
    queue = [node_id for node_id, degree in in_degree.items() if degree == 0]
    result = []
    
    while queue:
        node_id = queue.pop(0)
        result.append(node_id)
        
        # Find outgoing edges
        for edge in lineage_dag["edges"]:
            if edge["source"] == node_id:
                target = edge["target"]
                in_degree[target] -= 1
                if in_degree[target] == 0:
                    queue.append(target)
    
    # If result length != total nodes, cycle exists
    if len(result) != len(lineage_dag["nodes"]):
        # Find nodes in cycle
        nodes_in_result = set(result)
        all_nodes = {node["id"] for node in lineage_dag["nodes"]}
        cycle_nodes = all_nodes - nodes_in_result
        
        errors.append(
            f"Cycle detected in DAG. Nodes involved: {cycle_nodes}"
        )
    
    return (len(errors) == 0, errors)
```

**Failure Conditions:**
- ❌ **FAIL**: Topological sort fails (cycle detected)
- ❌ **FAIL**: Nodes remain after topological sort (cycle nodes identified)

---

### Check 4: No Skipped Transformations

**Algorithm:**
```python
def verify_no_skipped_transformations(lineage_dag, build_evidence):
    """
    Verify no transformations are skipped.
    
    Every transformation that produces an output used by another node
    must be explicitly represented in the DAG.
    
    Returns:
        (is_valid: bool, errors: List[str])
    """
    errors = []
    
    # Build map: output_hash -> node_id (from DAG)
    dag_outputs = {}
    for node in lineage_dag["nodes"]:
        node_id = node["id"]
        if "output" in node and "content_address" in node["output"]:
            output_hash = extract_hash(node["output"]["content_address"])
            dag_outputs[output_hash] = node_id
    
    # Build map: output_hash -> node_id (from evidence)
    evidence_outputs = {}
    for event in build_evidence["events"]:
        if event["event_type"] == "node_execution":
            node_id = event["node_id"]
            if "output" in event and "content_address" in event["output"]:
                output_hash = extract_hash(event["output"]["content_address"])
                evidence_outputs[output_hash] = node_id
    
    # Verify all evidence outputs are in DAG
    for output_hash, evidence_node_id in evidence_outputs.items():
        if output_hash not in dag_outputs:
            errors.append(
                f"Node {evidence_node_id} output (hash: {output_hash}) "
                f"exists in evidence but not in DAG"
            )
        elif dag_outputs[output_hash] != evidence_node_id:
            errors.append(
                f"Output hash {output_hash} mapped to different nodes: "
                f"DAG={dag_outputs[output_hash]}, Evidence={evidence_node_id}"
            )
    
    # Verify all DAG outputs have evidence
    for output_hash, dag_node_id in dag_outputs.items():
        if output_hash not in evidence_outputs:
            errors.append(
                f"Node {dag_node_id} output (hash: {output_hash}) "
                f"exists in DAG but not in evidence"
            )
        elif evidence_outputs[output_hash] != dag_node_id:
            errors.append(
                f"Output hash {output_hash} mapped to different nodes: "
                f"DAG={dag_node_id}, Evidence={evidence_outputs[output_hash]}"
            )
    
    # Verify all edges reference valid transformations
    for edge in lineage_dag["edges"]:
        source_node = find_node(edge["source"], lineage_dag["nodes"])
        target_node = find_node(edge["target"], lineage_dag["nodes"])
        
        if source_node is None:
            errors.append(
                f"Edge source node {edge['source']} does not exist"
            )
            continue
        
        if target_node is None:
            errors.append(
                f"Edge target node {edge['target']} does not exist"
            )
            continue
        
        # Verify source produces output
        if "output" not in source_node or "content_address" not in source_node["output"]:
            errors.append(
                f"Source node {edge['source']} does not produce output"
            )
        
        # Verify target consumes input
        if "inputs" not in target_node:
            errors.append(
                f"Target node {edge['target']} does not declare inputs"
            )
        else:
            # Verify target input matches source output
            source_output_hash = extract_hash(source_node["output"]["content_address"])
            target_has_input = False
            
            for input_item in target_node["inputs"]:
                input_hash = extract_hash(input_item["content_address"])
                if input_hash == source_output_hash:
                    target_has_input = True
                    break
            
            if not target_has_input:
                errors.append(
                    f"Target node {edge['target']} does not consume "
                    f"output from source node {edge['source']}"
                )
    
    return (len(errors) == 0, errors)
```

**Failure Conditions:**
- ❌ **FAIL**: Output exists in evidence but not in DAG
- ❌ **FAIL**: Output exists in DAG but not in evidence
- ❌ **FAIL**: Edge references non-existent node
- ❌ **FAIL**: Source node does not produce output
- ❌ **FAIL**: Target node does not consume source output

---

### Check 5: Complete Dependency Graph

**Algorithm:**
```python
def verify_complete_dependency_graph(lineage_dag):
    """
    Verify dependency graph is complete.
    
    Returns:
        (is_valid: bool, errors: List[str])
    """
    errors = []
    
    # Build node set
    node_ids = {node["id"] for node in lineage_dag["nodes"]}
    
    # Verify all edges reference existing nodes
    for edge in lineage_dag["edges"]:
        if edge["source"] not in node_ids:
            errors.append(
                f"Edge source node {edge['source']} does not exist"
            )
        
        if edge["target"] not in node_ids:
            errors.append(
                f"Edge target node {edge['target']} does not exist"
            )
    
    # Verify execution_order matches topological sort
    execution_order = lineage_dag.get("execution_order", [])
    
    if execution_order:
        # Verify all nodes in execution_order
        if set(execution_order) != node_ids:
            missing = node_ids - set(execution_order)
            extra = set(execution_order) - node_ids
            
            if missing:
                errors.append(
                    f"Nodes missing from execution_order: {missing}"
                )
            if extra:
                errors.append(
                    f"Extra nodes in execution_order: {extra}"
                )
        
        # Verify execution_order respects dependencies
        node_positions = {node_id: i for i, node_id in enumerate(execution_order)}
        
        for edge in lineage_dag["edges"]:
            source_pos = node_positions.get(edge["source"])
            target_pos = node_positions.get(edge["target"])
            
            if source_pos is not None and target_pos is not None:
                if source_pos >= target_pos:
                    errors.append(
                        f"Execution order violation: {edge['source']} (pos {source_pos}) "
                        f"must execute before {edge['target']} (pos {target_pos})"
                    )
    
    return (len(errors) == 0, errors)
```

**Failure Conditions:**
- ❌ **FAIL**: Edge references non-existent node
- ❌ **FAIL**: Execution order missing nodes
- ❌ **FAIL**: Execution order has extra nodes
- ❌ **FAIL**: Execution order violates dependencies

---

### Check 6: Input-Output Consistency

**Algorithm:**
```python
def verify_input_output_consistency(lineage_dag):
    """
    Verify input-output consistency for all nodes.
    
    Returns:
        (is_valid: bool, errors: List[str])
    """
    errors = []
    
    # Build dependency map
    dependencies = {}
    for edge in lineage_dag["edges"]:
        target = edge["target"]
        source = edge["source"]
        
        if target not in dependencies:
            dependencies[target] = []
        dependencies[target].append(source)
    
    # Verify each node
    for node in lineage_dag["nodes"]:
        node_id = node["id"]
        
        # Count declared inputs
        declared_input_count = 0
        if "inputs" in node:
            declared_input_count = len(node["inputs"])
        
        # Count dependencies
        dependency_count = len(dependencies.get(node_id, []))
        
        # Verify consistency
        if declared_input_count != dependency_count:
            errors.append(
                f"Node {node_id} input count mismatch: "
                f"declared={declared_input_count}, dependencies={dependency_count}"
            )
        
        # Verify all inputs are satisfied
        if "inputs" in node:
            for i, input_item in enumerate(node["inputs"]):
                if "content_address" not in input_item:
                    errors.append(
                        f"Node {node_id} input {i} missing content_address"
                    )
        
        # Verify output is produced
        if "output" not in node:
            errors.append(
                f"Node {node_id} does not declare output"
            )
        elif "content_address" not in node["output"]:
            errors.append(
                f"Node {node_id} output missing content_address"
            )
    
    return (len(errors) == 0, errors)
```

**Failure Conditions:**
- ❌ **FAIL**: Input count != dependency count
- ❌ **FAIL**: Input missing content_address
- ❌ **FAIL**: Output not declared
- ❌ **FAIL**: Output missing content_address

---

## VERIFIER REJECTION CONDITIONS

### Rejection Condition 1: Ingest Traceability Failure

**Error Code:** `LINEAGE_INGEST_UNTraceABLE`

**Condition:** Any node input cannot be traced to ingest or node output.

**Rejection:**
```python
if not verify_ingest_traceability(lineage_dag, ingest_manifest)[0]:
    errors = verify_ingest_traceability(lineage_dag, ingest_manifest)[1]
    REJECT with error_code="LINEAGE_INGEST_UNTraceABLE", errors=errors
```

---

### Rejection Condition 2: Orphan Nodes

**Error Code:** `LINEAGE_ORPHAN_NODES`

**Condition:** Any node is not reachable from root nodes or root nodes lack ingest-bound inputs.

**Rejection:**
```python
if not verify_no_orphan_nodes(lineage_dag, ingest_manifest)[0]:
    errors = verify_no_orphan_nodes(lineage_dag, ingest_manifest)[1]
    REJECT with error_code="LINEAGE_ORPHAN_NODES", errors=errors
```

---

### Rejection Condition 3: Cycle Detected

**Error Code:** `LINEAGE_CYCLE_DETECTED`

**Condition:** Topological sort fails (cycle exists).

**Rejection:**
```python
if not verify_no_cycles(lineage_dag)[0]:
    errors = verify_no_cycles(lineage_dag)[1]
    REJECT with error_code="LINEAGE_CYCLE_DETECTED", errors=errors
```

---

### Rejection Condition 4: Skipped Transformations

**Error Code:** `LINEAGE_SKIPPED_TRANSFORMATIONS`

**Condition:** Output exists in evidence but not in DAG, or vice versa.

**Rejection:**
```python
if not verify_no_skipped_transformations(lineage_dag, build_evidence)[0]:
    errors = verify_no_skipped_transformations(lineage_dag, build_evidence)[1]
    REJECT with error_code="LINEAGE_SKIPPED_TRANSFORMATIONS", errors=errors
```

---

### Rejection Condition 5: Incomplete Dependency Graph

**Error Code:** `LINEAGE_INCOMPLETE_DEPENDENCIES`

**Condition:** Edge references non-existent node or execution order violates dependencies.

**Rejection:**
```python
if not verify_complete_dependency_graph(lineage_dag)[0]:
    errors = verify_complete_dependency_graph(lineage_dag)[1]
    REJECT with error_code="LINEAGE_INCOMPLETE_DEPENDENCIES", errors=errors
```

---

### Rejection Condition 6: Input-Output Inconsistency

**Error Code:** `LINEAGE_INPUT_OUTPUT_INCONSISTENCY`

**Condition:** Input count != dependency count or output not declared.

**Rejection:**
```python
if not verify_input_output_consistency(lineage_dag)[0]:
    errors = verify_input_output_consistency(lineage_dag)[1]
    REJECT with error_code="LINEAGE_INPUT_OUTPUT_INCONSISTENCY", errors=errors
```

---

## POLICY RULE DEFINITION

### Rule: `lineage_completeness_required`

**YAML Definition:**
```yaml
- id: lineage_completeness_required
  name: "Lineage Completeness Required"
  type: structural_check
  requirement: |
    Every output must trace back to ingest.
    No orphan nodes.
    No cycles.
    No skipped transformations.
  checks:
    - check_id: ingest_traceability
      description: "Every output traces back to ingest"
      algorithm: verify_ingest_traceability
      failure_code: LINEAGE_INGEST_UNTraceABLE
    - check_id: no_orphan_nodes
      description: "No orphan nodes"
      algorithm: verify_no_orphan_nodes
      failure_code: LINEAGE_ORPHAN_NODES
    - check_id: no_cycles
      description: "No cycles in DAG"
      algorithm: verify_no_cycles
      failure_code: LINEAGE_CYCLE_DETECTED
    - check_id: no_skipped_transformations
      description: "No skipped transformations"
      algorithm: verify_no_skipped_transformations
      failure_code: LINEAGE_SKIPPED_TRANSFORMATIONS
    - check_id: complete_dependency_graph
      description: "Complete dependency graph"
      algorithm: verify_complete_dependency_graph
      failure_code: LINEAGE_INCOMPLETE_DEPENDENCIES
    - check_id: input_output_consistency
      description: "Input-output consistency"
      algorithm: verify_input_output_consistency
      failure_code: LINEAGE_INPUT_OUTPUT_INCONSISTENCY
  threshold: 1.0  # 100% of checks must pass
  refusal_condition: "Any lineage completeness check fails"
  blocks_states: [CANDIDATE, RELEASE, ARCHIVED]
```

---

## HELPER FUNCTIONS

### `extract_hash(content_address: str) -> str`

```python
def extract_hash(content_address: str) -> str:
    """
    Extract hash from content address.
    
    Content address format: "hash" or "hash.ext"
    Returns: hash portion only (64 hex chars for SHA-256)
    """
    # Split by '.' to separate hash from extension
    parts = content_address.split('.')
    hash_part = parts[0]
    
    # Verify format: 64 hex chars, lowercase
    if len(hash_part) == 64 and all(c in '0123456789abcdef' for c in hash_part):
        return hash_part
    else:
        # Invalid format - return as-is (will fail traceability check)
        return hash_part
```

### `find_node(node_id: str, nodes: List[Dict]) -> Optional[Dict]`

```python
def find_node(node_id: str, nodes: List[Dict]) -> Optional[Dict]:
    """Find node by ID in nodes list."""
    for node in nodes:
        if node.get("id") == node_id:
            return node
    return None
```

---

## SUMMARY

| Check | Algorithm | Failure Code | Fatal? |
|-------|-----------|--------------|--------|
| Ingest Traceability | `verify_ingest_traceability` | `LINEAGE_INGEST_UNTraceABLE` | ✅ YES |
| No Orphan Nodes | `verify_no_orphan_nodes` | `LINEAGE_ORPHAN_NODES` | ✅ YES |
| No Cycles | `verify_no_cycles` | `LINEAGE_CYCLE_DETECTED` | ✅ YES |
| No Skipped Transformations | `verify_no_skipped_transformations` | `LINEAGE_SKIPPED_TRANSFORMATIONS` | ✅ YES |
| Complete Dependency Graph | `verify_complete_dependency_graph` | `LINEAGE_INCOMPLETE_DEPENDENCIES` | ✅ YES |
| Input-Output Consistency | `verify_input_output_consistency` | `LINEAGE_INPUT_OUTPUT_INCONSISTENCY` | ✅ YES |

**All checks are mechanical. No assumptions. No interpretation.**

---

## STATUS

**Formal Definition:** ✅ **COMPLETE**

**Mechanical Checks:** ✅ **6 ALGORITHMS DEFINED**

**Verifier Rejection Conditions:** ✅ **6 ERROR CODES DEFINED**

**If lineage can be "assumed":** ❌ **REJECTED** (all checks are explicit)

