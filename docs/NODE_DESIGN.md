# ContentVerifierNode Design Specification

## Overview

The `ContentVerifierNode` is a pure, deterministic execution node that verifies content integrity and extracts deterministic metadata from content-addressed inputs.

## Axiom Compliance

✅ **Pure Function**: No side effects  
✅ **Content-Addressed I/O**: All inputs/outputs content-addressed  
✅ **Deterministic**: Same input = same output  
✅ **No Filesystem State**: Works with content bytes only  
✅ **No Environment**: No env vars, no system calls  
✅ **No Clock**: No time dependencies  
✅ **No Randomness**: Pure computation only  

## Formal Input Contract

```python
Input: List[NodeInput] where:
  - len(inputs) == 1 (exactly one input required)
  - inputs[0].content_address: str
    Format: "{hash_hex}{extension}"
    Example: "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789.mxf"
    Hash is hexadecimal string (length depends on algorithm)
    Extension starts with '.' or is empty
  
  - inputs[0].metadata: Dict[str, Any]
    Required:
      - "content_bytes": bytes (actual content to verify)
    Optional:
      - "size": int
      - "mime_type": str
```

## Formal Output Contract

```python
Output: NodeOutput where:
  - output.content_address: str
    If verified: same as input.content_address
    If invalid: "invalid_{computed_hash}{extension}"
  
  - output.metadata: Dict[str, Any]
    Required fields:
      - "verified": bool (integrity verification result)
      - "hash_algorithm": str (algorithm used, e.g., "sha256")
      - "computed_hash": str (hash computed from content)
      - "expected_hash": str (hash from content address)
      - "size": int (content size in bytes)
      - "metadata_extracted": Dict (deterministic metadata)
        Contains:
          - "size": int
          - "extension": str
          - "detected_type": str (MIME type from magic bytes)
          - "non_empty": bool
          - "byte_range": {"min": int, "max": int}
  
  - output.evidence: Dict[str, Any]
    Contains:
      - "node_id": str
      - "node_type": "content_verifier"
      - "inputs": [{"content_address": str, "metadata": Dict}]
      - "output": {"content_address": str, "metadata": Dict}
      - "config": Dict
      - "verification": {
          "algorithm": str,
          "computed_hash": str,
          "expected_hash": str,
          "verified": bool,
          "content_size": int
        }
```

## Determinism Proof Sketch

### 1. Hash Computation
```
hash(content_bytes) is deterministic because:
- Cryptographic hash functions are deterministic
- Same input → same output
- No randomness, no time, no environment
- Algorithm is fixed by config
```

### 2. Metadata Extraction
```
extract_metadata(content_bytes) is deterministic because:
- Based on content bytes only (magic bytes, size)
- No time dependencies
- No environment variables
- No randomness
- Same content → same metadata
```

### 3. Verification
```
verify(computed_hash, expected_hash) is deterministic because:
- Pure boolean comparison
- No side effects
- No external state
```

### 4. Output Construction
```
build_output(inputs, computed_hash, metadata) is deterministic because:
- All values derived from inputs and config
- No external state
- No mutable state
```

**Conclusion**: `f(inputs, config) = output` is deterministic.

**Proof**: For any two executions with identical `inputs` and `config`:
- `hash(content_bytes)` produces identical hash
- `extract_metadata(content_bytes)` produces identical metadata
- `verify()` produces identical boolean result
- `build_output()` produces identical output structure

Therefore: Same inputs + same config = same outputs. ✅

## Evidence Emitted

```json
{
  "node_id": "verifier_1",
  "node_type": "content_verifier",
  "inputs": [
    {
      "content_address": "a1b2c3...mxf",
      "metadata": {
        "content_bytes": "<base64 or omitted>",
        "size": 1234567
      }
    }
  ],
  "output": {
    "content_address": "a1b2c3...mxf",
    "metadata": {
      "verified": true,
      "hash_algorithm": "sha256",
      "computed_hash": "a1b2c3...",
      "expected_hash": "a1b2c3...",
      "size": 1234567,
      "metadata_extracted": {
        "size": 1234567,
        "extension": ".mxf",
        "detected_type": "video/container",
        "non_empty": true,
        "byte_range": {"min": 0, "max": 255}
      }
    }
  },
  "config": {
    "hash_algorithm": "sha256",
    "verify_integrity": true,
    "extract_metadata": true
  },
  "verification": {
    "algorithm": "sha256",
    "computed_hash": "a1b2c3...",
    "expected_hash": "a1b2c3...",
    "verified": true,
    "content_size": 1234567
  }
}
```

## Failure Modes (Typed, Explicit)

### 1. ExecutionError - Input Validation

**When**: Invalid input structure

**Examples**:
```python
ExecutionError("ContentVerifier verifier_1: Invalid inputs. Expected 1 input, got 2")
ExecutionError("ContentVerifier verifier_1: content_bytes not provided in metadata")
```

**Recovery**: Fix input structure, retry

### 2. ValidationError - Integrity Mismatch

**When**: Content hash doesn't match content address

**Example**:
```python
ValidationError(
    "ContentVerifier verifier_1: Integrity mismatch. "
    "Expected hash: a1b2c3..., computed: d4e5f6..."
)
```

**Recovery**: Verify content source, check for corruption

### 3. ExecutionError - Configuration

**When**: Invalid configuration

**Examples**:
```python
ExecutionError("Invalid ContentVerifier config: {error}")
ExecutionError("Unsupported hash algorithm: md5")
```

**Recovery**: Fix configuration, retry

## Usage Example

```python
from engine.core.nodes import ContentVerifierNode
from engine.core.node import NodeInput
from engine.core.context import ExecutionContext
from pathlib import Path

# Create node
node = ContentVerifierNode(
    node_id="verify_asset_1",
    config={
        "hash_algorithm": "sha256",
        "verify_integrity": True,
        "extract_metadata": True,
    }
)

# Prepare input
content_bytes = b"test content"
content_hash = hashlib.sha256(content_bytes).hexdigest()
content_address = f"{content_hash}.mxf"

input_data = NodeInput(
    content_address=content_address,
    path=Path("asset.mxf"),  # Metadata only
    metadata={
        "content_bytes": content_bytes,
        "size": len(content_bytes),
    }
)

# Execute (pure function)
output = node.execute([input_data], context)

# Output is deterministic
assert output.metadata["verified"] == True
assert output.content_address == content_address
```

## Axiom Verification Checklist

- [x] Pure function: No side effects
- [x] Content-addressed inputs: Input has content_address
- [x] Content-addressed outputs: Output has content_address
- [x] No side effects: No file I/O, no network, no state mutation
- [x] No implicit filesystem state: Works with bytes only
- [x] No environment dependency: No env vars, no system calls
- [x] No clock usage: No time() calls, no datetime.now()
- [x] No randomness: No random(), no uuid(), deterministic only
- [x] Deterministic: Same inputs = same outputs (proven)
- [x] Evidence emitted: All execution details in evidence
- [x] Typed failures: ExecutionError, ValidationError
- [x] Explicit failures: No silent failures

## Status

✅ **VALID** - All requirements satisfied. Node is axiom-compliant.

