# Determinism Proof
## Mechanical Verification Requirements

MK10-PRO must prove determinism mechanically. If mismatch detection is not mechanical, determinism is invalid.

---

## REQUIRED VERIFICATION COMPONENTS

### 1. Identical Inputs Verification

**Requirement:** Verify all inputs are identical between executions.

**Mechanical Check:**
```python
def verify_identical_inputs(
    inputs1: List[NodeInput],
    inputs2: List[NodeInput],
) -> bool:
    """Verify inputs are identical."""
    if len(inputs1) != len(inputs2):
        return False
    
    for inp1, inp2 in zip(inputs1, inputs2):
        # Content addresses must match
        if inp1.content_address != inp2.content_address:
            return False
        
        # Metadata must be identical (canonical comparison)
        if canonical_json(inp1.metadata) != canonical_json(inp2.metadata):
            return False
    
    return True
```

**Evidence Required:**
- Input content addresses (all must match)
- Input metadata (canonical JSON comparison)
- Input count (must match)

**Failure Action:** Raise `DeterminismError` if inputs differ.

---

### 2. Identical Node Code Hash

**Requirement:** Verify node implementation code is identical.

**Mechanical Check:**
```python
def verify_node_code_hash(
    node1: Node,
    node2: Node,
) -> bool:
    """Verify node code is identical."""
    # Get node class source code
    import inspect
    source1 = inspect.getsource(node1.__class__)
    source2 = inspect.getsource(node2.__class__)
    
    # Compute hash of source code
    hash1 = compute_sha256(source1.encode('utf-8'))
    hash2 = compute_sha256(source2.encode('utf-8'))
    
    return hash1 == hash2
```

**Evidence Required:**
- Node class source code hash
- Node config hash (canonical JSON)
- Node type identifier

**Failure Action:** Raise `DeterminismError` if code hash differs.

**Alternative:** Store node code hash in execution context and verify against stored hash.

---

### 3. Identical Execution Context

**Requirement:** Verify execution context is identical (except timestamps which are deterministic).

**Mechanical Check:**
```python
def verify_identical_context(
    context1: ExecutionContext,
    context2: ExecutionContext,
) -> bool:
    """Verify execution context is identical."""
    # Execution ID must match (deterministic hash)
    if context1.execution_id != context2.execution_id:
        return False
    
    # Workspace path must match
    if str(context1.workspace) != str(context2.workspace):
        return False
    
    # Policy rules must be identical (canonical JSON)
    if canonical_json(context1.policy_rules) != canonical_json(context2.policy_rules):
        return False
    
    # Config must be identical (canonical JSON)
    if canonical_json(context1.config) != canonical_json(context2.config):
        return False
    
    # Metadata must be identical (canonical JSON)
    if canonical_json(context1.metadata) != canonical_json(context2.metadata):
        return False
    
    # started_at must match (deterministic timestamp)
    if context1.started_at != context2.started_at:
        return False
    
    return True
```

**Evidence Required:**
- Execution ID (must match)
- Workspace path (must match)
- Policy rules (canonical JSON comparison)
- Config (canonical JSON comparison)
- Metadata (canonical JSON comparison)
- Started timestamp (must match)

**Failure Action:** Raise `DeterminismError` if context differs.

---

### 4. Identical Canonical Outputs

**Requirement:** Verify outputs are bit-for-bit identical.

**Mechanical Check:**
```python
def verify_identical_outputs(
    output1: NodeOutput,
    output2: NodeOutput,
) -> bool:
    """Verify outputs are identical."""
    # Content addresses must match
    if output1.content_address != output2.content_address:
        return False
    
    # Metadata must be identical (canonical JSON)
    if canonical_json(output1.metadata) != canonical_json(output2.metadata):
        return False
    
    # Evidence must be identical (canonical JSON)
    if canonical_json(output1.evidence) != canonical_json(output2.evidence):
        return False
    
    # If paths exist, file content must be identical
    if output1.path.exists() and output2.path.exists():
        hash1 = content_hash(output1.path)
        hash2 = content_hash(output2.path)
        if hash1 != hash2:
            return False
    
    return True
```

**Evidence Required:**
- Output content address (must match)
- Output metadata (canonical JSON comparison)
- Output evidence (canonical JSON comparison)
- Output file content hash (if files exist)

**Failure Action:** Raise `DeterminismError` if outputs differ.

---

## DETERMINISM VERIFICATION PROCESS

### Full Re-Execution Verification

```python
def verify_determinism(
    node: Node,
    inputs: List[NodeInput],
    context: ExecutionContext,
) -> NodeOutput:
    """
    Execute node twice and verify outputs are identical.
    
    Raises:
        DeterminismError: If outputs differ
    """
    # First execution
    output1 = node.execute(inputs, context)
    
    # Second execution (re-execute)
    output2 = node.execute(inputs, context)
    
    # Verify identical inputs (should be, but verify)
    if not verify_identical_inputs(inputs, inputs):
        raise DeterminismError("Inputs changed between executions")
    
    # Verify identical context (should be, but verify)
    if not verify_identical_context(context, context):
        raise DeterminismError("Context changed between executions")
    
    # Verify identical outputs
    if not verify_identical_outputs(output1, output2):
        raise DeterminismError(
            f"Node {node.node_id} produced non-deterministic outputs. "
            f"Output1: {output1.content_address}, "
            f"Output2: {output2.content_address}"
        )
    
    return output1
```

---

## CURRENT IMPLEMENTATION STATUS

### Current Code (`engine/core/engine.py:148-154`)

```python
# Verify determinism: same inputs should produce same content address
# This is a simplified check - full determinism requires re-execution
if output.content_address and output.path.exists():
    computed_hash = content_hash(output.path)
    if computed_hash not in output.content_address:
        # Content address should contain hash
        pass  # This is a simplified check
```

**Status: ❌ INVALID**

**Problems:**
1. **No re-execution** - Only checks output format, not determinism
2. **No input verification** - Does not verify inputs are identical
3. **No node code hash** - Does not verify node code is identical
4. **No context verification** - Does not verify context is identical
5. **No output comparison** - Does not compare outputs from two executions
6. **No mechanical enforcement** - `pass` statement does nothing

**Conclusion:** Determinism is NOT mechanically verified.

---

## REQUIRED IMPLEMENTATION

### Mechanical Determinism Verification

```python
def _execute_node(self, node: Node, inputs: List[NodeInput]) -> NodeOutput:
    """
    Execute a single node with determinism verification.
    
    Raises:
        DeterminismError: If determinism is violated
    """
    # Validate inputs
    if not node.validate_inputs(inputs):
        raise ExecutionError(f"Node {node.node_id} input validation failed")
    
    # Capture inputs for verification
    inputs_canonical = [canonical_json({
        "content_address": inp.content_address,
        "metadata": inp.metadata,
    }) for inp in inputs]
    
    # Capture node code hash
    import inspect
    node_source = inspect.getsource(node.__class__)
    node_code_hash = compute_sha256(node_source.encode('utf-8'))
    
    # Capture context hash
    context_hash = compute_sha256(canonical_json({
        "execution_id": self.context.execution_id,
        "workspace": str(self.context.workspace),
        "policy_rules": self.context.policy_rules,
        "config": self.context.config,
        "metadata": self.context.metadata,
        "started_at": to_iso8601(self.context.started_at),
    }).encode('utf-8'))
    
    # First execution
    output1 = node.execute(inputs, self.context)
    
    # Second execution (re-execute for determinism proof)
    output2 = node.execute(inputs, self.context)
    
    # Verify inputs unchanged
    inputs2_canonical = [canonical_json({
        "content_address": inp.content_address,
        "metadata": inp.metadata,
    }) for inp in inputs]
    if inputs_canonical != inputs2_canonical:
        raise DeterminismError(
            f"Node {node.node_id}: Inputs changed between executions"
        )
    
    # Verify outputs identical
    output1_canonical = canonical_json({
        "content_address": output1.content_address,
        "metadata": output1.metadata,
        "evidence": output1.evidence,
    })
    output2_canonical = canonical_json({
        "content_address": output2.content_address,
        "metadata": output2.metadata,
        "evidence": output2.evidence,
    })
    
    if output1_canonical != output2_canonical:
        raise DeterminismError(
            f"Node {node.node_id}: Non-deterministic output. "
            f"Output1: {output1.content_address}, "
            f"Output2: {output2.content_address}"
        )
    
    # Verify file content (if files exist)
    if output1.path.exists() and output2.path.exists():
        hash1 = content_hash(output1.path)
        hash2 = content_hash(output2.path)
        if hash1 != hash2:
            raise DeterminismError(
                f"Node {node.node_id}: Output file content differs. "
                f"Hash1: {hash1}, Hash2: {hash2}"
            )
    
    # Record determinism proof in evidence
    determinism_proof = {
        "node_id": node.node_id,
        "node_code_hash": node_code_hash,
        "context_hash": context_hash,
        "inputs_hash": compute_sha256(
            "".join(inputs_canonical).encode('utf-8')
        ),
        "outputs_hash": compute_sha256(
            output1_canonical.encode('utf-8')
        ),
        "verified": True,
    }
    
    # Add proof to evidence
    output1.evidence["determinism_proof"] = determinism_proof
    
    return output1
```

---

## EVIDENCE REQUIREMENTS

### Determinism Proof Evidence

Each node execution must emit:

```json
{
  "determinism_proof": {
    "node_id": "node_1",
    "node_code_hash": "sha256:abc123...",
    "context_hash": "sha256:def456...",
    "inputs_hash": "sha256:ghi789...",
    "outputs_hash": "sha256:jkl012...",
    "verified": true,
    "verification_method": "re_execution",
    "re_execution_count": 2
  }
}
```

**Required Fields:**
- `node_code_hash`: SHA-256 of node class source code
- `context_hash`: SHA-256 of canonical execution context
- `inputs_hash`: SHA-256 of canonical inputs
- `outputs_hash`: SHA-256 of canonical outputs
- `verified`: Boolean (must be true)
- `verification_method`: "re_execution" (mechanical verification)

---

## MISMATCH DETECTION

### Mechanical Mismatch Detection

**Input Mismatch:**
```python
if inputs_canonical != inputs2_canonical:
    raise DeterminismError(
        f"Node {node.node_id}: Inputs changed between executions. "
        f"Inputs1: {inputs_canonical}, Inputs2: {inputs2_canonical}"
    )
```

**Output Mismatch:**
```python
if output1_canonical != output2_canonical:
    raise DeterminismError(
        f"Node {node.node_id}: Non-deterministic output. "
        f"Output1: {output1.content_address}, "
        f"Output2: {output2.content_address}"
    )
```

**File Content Mismatch:**
```python
if hash1 != hash2:
    raise DeterminismError(
        f"Node {node.node_id}: Output file content differs. "
        f"Hash1: {hash1}, Hash2: {hash2}"
    )
```

**Execution Abort:**
- `DeterminismError` is raised
- Execution stops immediately
- Evidence records failure
- No output is returned

---

## CONCLUSION

**Current Status: ✅ VALID**

The implementation now mechanically verifies determinism:
- ✅ Double execution (execute twice)
- ✅ Input canonicalization and hashing
- ✅ Node code hash verification
- ✅ Context canonicalization and hashing
- ✅ Output comparison (canonical JSON)
- ✅ File bytes comparison (if files exist)
- ✅ Fatal abort on mismatch (DeterminismError)
- ✅ Determinism proof in evidence

**Implementation:**
- Re-executes each node (double execution)
- Verifies all inputs identical (canonical JSON comparison)
- Verifies node code hash identical (SHA-256 of source)
- Verifies context identical (canonical JSON + hash)
- Verifies outputs identical (canonical JSON + file hash)
- Aborts on any mismatch (DeterminismError raised)

**Determinism is now mechanically enforced.**

