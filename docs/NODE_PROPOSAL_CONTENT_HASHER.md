# ContentHasherNode Proposal
## MK10-PRO Execution Node Design

**Node Type:** `content_hasher`

**Purpose:** Compute cryptographic hash of content bytes and generate content address.

---

## 1. INPUT CONTRACT

### Formal Input Specification

```python
Input: List[NodeInput] where:
  - len(inputs) == 1 (exactly one input required)
  
  - inputs[0].content_address: str
    Format: Any (input content address, may be temporary or undefined)
    Example: "temp_input_123" or ""
    Note: Input content address is not used for computation, only for tracking
    
  - inputs[0].metadata: Dict[str, Any]
    Required:
      - "content_bytes": bytes (actual content to hash)
    Optional:
      - "extension": str (file extension, e.g., ".mxf", ".json")
      - "size": int (content size in bytes)
    
  - inputs[0].path: Path
    Note: Path is metadata only, not used for computation
    Filesystem is not accessed
```

### Input Validation

```python
def validate_inputs(self, inputs: List[NodeInput]) -> bool:
    """
    Validate inputs meet contract.
    
    Returns:
        True if inputs are valid, False otherwise
    """
    # Exactly 1 input required
    if len(inputs) != 1:
        return False
    
    inp = inputs[0]
    
    # Content bytes must be present
    if "content_bytes" not in inp.metadata:
        return False
    
    # Content bytes must be bytes type
    if not isinstance(inp.metadata["content_bytes"], bytes):
        return False
    
    # Content bytes must be non-empty
    if len(inp.metadata["content_bytes"]) == 0:
        return False
    
    return True
```

**Rejection Conditions:**
- ❌ More than 1 input → `ExecutionError("ContentHasherNode requires exactly 1 input, got {len(inputs)}")`
- ❌ Missing `content_bytes` → `ExecutionError("ContentHasherNode requires 'content_bytes' in metadata")`
- ❌ `content_bytes` not bytes type → `ExecutionError("ContentHasherNode: 'content_bytes' must be bytes, got {type}")`
- ❌ Empty content bytes → `ExecutionError("ContentHasherNode: content_bytes cannot be empty")`

---

## 2. OUTPUT CONTRACT

### Formal Output Specification

```python
Output: NodeOutput where:
  
  - output.content_address: str
    Format: "{hash_hex}{extension}"
    Example: "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789.mxf"
    Hash is hexadecimal string (length depends on algorithm)
    Extension from input metadata or empty string
    
  - output.metadata: Dict[str, Any]
    Required fields:
      - "hash_algorithm": str (algorithm used, e.g., "sha256")
      - "hash": str (hexadecimal hash of content)
      - "size": int (content size in bytes)
      - "extension": str (file extension, if provided)
    Optional fields:
      - "input_content_address": str (original input content address)
    
  - output.evidence: Dict[str, Any]
    Contains:
      - "node_id": str
      - "node_type": "content_hasher"
      - "inputs": [{"content_address": str, "metadata": {...}}]
      - "output": {"content_address": str, "metadata": {...}}
      - "config": Dict
      - "computation": {
          "algorithm": str,
          "input_size": int,
          "output_hash": str,
          "computation_time_ns": int (optional, for performance tracking)
        }
    
  - output.path: Path
    Note: Path is metadata only, not used for content addressing
    Filesystem is not accessed
```

### Output Generation

```python
def execute(
    self,
    inputs: List[NodeInput],
    context: ExecutionContext,
) -> NodeOutput:
    """
    Execute content hashing.
    
    Pure function: f(inputs, config) = output
    """
    # Validate inputs
    if not self.validate_inputs(inputs):
        raise ExecutionError(...)
    
    inp = inputs[0]
    content_bytes = inp.metadata["content_bytes"]
    extension = inp.metadata.get("extension", "")
    
    # Compute hash (pure function, deterministic)
    hash_value = self._compute_hash(content_bytes)
    
    # Generate content address
    content_address = f"{hash_value}{extension}"
    
    # Build output metadata
    output_metadata = {
        "hash_algorithm": self.hasher_config.hash_algorithm,
        "hash": hash_value,
        "size": len(content_bytes),
        "extension": extension,
        "input_content_address": inp.content_address,
    }
    
    # Create output
    output = NodeOutput(
        content_address=content_address,
        path=inp.path,  # Pass through, not used
        metadata=output_metadata,
        evidence={},  # Will be populated by get_evidence
    )
    
    # Generate evidence
    output.evidence = self.get_evidence(inputs, output)
    
    return output
```

---

## 3. DETERMINISM PROOF SKETCH

### Proof: f(inputs, config) = output is deterministic

**Given:**
- `inputs1` = `inputs2` (identical)
- `config1` = `config2` (identical)
- `context1` = `context2` (identical, except deterministic timestamps)

**Prove:** `output1` = `output2` (identical)

### Step 1: Hash Computation

```
hash(content_bytes) is deterministic because:
- Cryptographic hash functions are deterministic
- Same input bytes → same hash output
- No randomness, no time, no environment
- Algorithm is fixed by config
- Implementation: hashlib.new(algorithm).update(content_bytes).hexdigest()
```

**Proof:**
- `hashlib` is deterministic (Python standard library guarantee)
- Same `content_bytes` → same `hash_value`
- Algorithm fixed by config → deterministic

### Step 2: Content Address Generation

```
content_address = f"{hash_value}{extension}"

Deterministic because:
- hash_value is deterministic (proven above)
- extension from input metadata (deterministic input)
- String formatting is deterministic
```

**Proof:**
- `hash_value` is deterministic
- `extension` from input metadata (deterministic)
- String concatenation is deterministic

### Step 3: Metadata Construction

```
metadata = {
    "hash_algorithm": config.hash_algorithm,  # From config (deterministic)
    "hash": hash_value,  # Deterministic (proven)
    "size": len(content_bytes),  # Deterministic (same input)
    "extension": extension,  # From input (deterministic)
    "input_content_address": inp.content_address,  # From input (deterministic)
}

Deterministic because:
- All values derived from inputs and config
- No external state
- No mutable state
```

**Proof:**
- All metadata fields are deterministic functions of inputs/config
- No side effects
- No external dependencies

### Step 4: Evidence Generation

```
evidence = {
    "node_id": self.node_id,  # Fixed (deterministic)
    "node_type": "content_hasher",  # Fixed (deterministic)
    "inputs": [...],  # From inputs (deterministic)
    "output": {...},  # From output (deterministic, proven above)
    "config": self.config,  # From config (deterministic)
    "computation": {
        "algorithm": config.hash_algorithm,  # Deterministic
        "input_size": len(content_bytes),  # Deterministic
        "output_hash": hash_value,  # Deterministic (proven)
    }
}

Deterministic because:
- All values derived from inputs, config, and deterministic computations
- No external state
- No time dependencies
```

**Proof:**
- All evidence fields are deterministic functions of inputs/config/computations
- No side effects
- No external dependencies

### Conclusion

**For any two executions with identical `inputs` and `config`:**
- `hash(content_bytes)` produces identical hash ✅
- `content_address` is identical ✅
- `metadata` is identical ✅
- `evidence` is identical ✅

**Therefore:** `f(inputs, config) = output` is deterministic. ✅

**Same inputs + same config = same outputs.**

---

## 4. EVIDENCE SCHEMA

### Evidence Structure

```json
{
  "node_id": "hasher_1",
  "node_type": "content_hasher",
  "inputs": [
    {
      "content_address": "temp_input_123",
      "metadata": {
        "content_bytes": "<base64 or omitted>",
        "extension": ".mxf",
        "size": 1234567
      }
    }
  ],
  "output": {
    "content_address": "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789.mxf",
    "metadata": {
      "hash_algorithm": "sha256",
      "hash": "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789",
      "size": 1234567,
      "extension": ".mxf",
      "input_content_address": "temp_input_123"
    }
  },
  "config": {
    "hash_algorithm": "sha256"
  },
  "computation": {
    "algorithm": "sha256",
    "input_size": 1234567,
    "output_hash": "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789"
  }
}
```

### Evidence Requirements

**Required Fields:**
- `node_id`: Node identifier
- `node_type`: "content_hasher"
- `inputs`: Input content addresses and metadata
- `output`: Output content address and metadata
- `config`: Node configuration
- `computation`: Computation details (algorithm, input size, output hash)

**Evidence Sealing:**
- Evidence is sealed with integrity proof (by EvidenceRecorder)
- Canonical JSON format for deterministic hashing
- All fields are deterministic

---

## 5. REJECTION CONDITIONS

### Typed Failure Modes

#### 1. ExecutionError - Input Validation

**When:** Input contract violated

**Examples:**
```python
ExecutionError("ContentHasherNode hasher_1: Invalid inputs. Expected 1 input, got 2")
ExecutionError("ContentHasherNode hasher_1: 'content_bytes' not provided in metadata")
ExecutionError("ContentHasherNode hasher_1: 'content_bytes' must be bytes, got <class 'str'>")
ExecutionError("ContentHasherNode hasher_1: content_bytes cannot be empty")
```

**Recovery:** Fix input structure, retry

#### 2. ExecutionError - Configuration

**When:** Invalid configuration

**Examples:**
```python
ExecutionError("ContentHasherNode hasher_1: Invalid config: {error}")
ExecutionError("ContentHasherNode hasher_1: Unsupported hash algorithm: md5")
```

**Recovery:** Fix configuration, retry

#### 3. ExecutionError - Hash Computation

**When:** Hash computation fails (should not happen, but defensive)

**Examples:**
```python
ExecutionError("ContentHasherNode hasher_1: Hash computation failed: {error}")
```

**Recovery:** Check content bytes, retry

---

## AXIOM COMPLIANCE VERIFICATION

### ✅ Pure Function
- No side effects
- No mutable state
- No external I/O
- **Proof:** All operations are pure computations

### ✅ Content-Addressed I/O
- Input: content_address (tracking only)
- Output: content_address (hash-based)
- **Proof:** Output content_address is `{hash}{extension}`

### ✅ No Side Effects
- No file system writes
- No network calls
- No state mutation
- **Proof:** Only in-memory computations

### ✅ No Filesystem Assumptions
- Path is metadata only
- No `path.exists()` checks
- No file reads/writes
- **Proof:** All operations on `content_bytes` in memory

### ✅ No Environment Access
- No `os.environ`
- No `os.getenv()`
- No system calls
- **Proof:** Only uses `hashlib` (pure computation)

### ✅ No Clock Usage
- No `time.time()`
- No `datetime.now()`
- No time dependencies
- **Proof:** No time-related operations

### ✅ No Randomness
- No `random.random()`
- No `uuid.uuid4()`
- No non-deterministic operations
- **Proof:** Only deterministic hash computation

### ✅ Typed Failure Modes
- `ExecutionError` for all failures
- Explicit error messages
- **Proof:** All failures raise typed exceptions

### ✅ Evidence Emission
- Evidence generated for every execution
- Evidence includes all computation details
- Evidence is sealed with integrity proof
- **Proof:** `get_evidence()` method returns complete evidence

---

## IMPLEMENTATION NOTES

### Configuration

```python
@dataclass(frozen=True)
class ContentHasherConfig:
    """Immutable configuration for ContentHasher node."""
    hash_algorithm: str = "sha256"  # sha256, sha512, etc.
```

**Supported Algorithms:**
- `sha256` (default)
- `sha512`
- Any algorithm supported by `hashlib`

### Hash Computation

```python
def _compute_hash(self, content_bytes: bytes) -> str:
    """
    Compute hash of content bytes.
    
    Pure function: f(bytes) = str
    Deterministic: Same bytes → same hash
    """
    hash_obj = hashlib.new(self.hasher_config.hash_algorithm)
    hash_obj.update(content_bytes)
    return hash_obj.hexdigest()
```

**Determinism Guarantee:**
- `hashlib` is deterministic (Python standard library)
- Same `content_bytes` → same hash
- No randomness, no time, no environment

---

## USAGE EXAMPLE

```python
from engine.core.nodes import ContentHasherNode
from engine.core.node import NodeInput
from engine.core.context import ExecutionContext
from pathlib import Path

# Create node
node = ContentHasherNode(
    node_id="hasher_1",
    config={
        "hash_algorithm": "sha256",
    }
)

# Prepare input
content_bytes = b"test content"
input_data = NodeInput(
    content_address="temp_input",  # Temporary address
    path=Path("input.bin"),  # Metadata only
    metadata={
        "content_bytes": content_bytes,
        "extension": ".bin",
        "size": len(content_bytes),
    }
)

# Execute (pure function)
output = node.execute([input_data], context)

# Output is deterministic
assert output.content_address.startswith(compute_sha256(content_bytes))
assert output.metadata["hash"] == compute_sha256(content_bytes)
assert output.metadata["size"] == len(content_bytes)
```

---

## CONCLUSION

**ContentHasherNode meets all mandatory requirements:**

✅ Pure function  
✅ Content-addressed inputs and outputs  
✅ No side effects  
✅ No filesystem assumptions  
✅ No environment access  
✅ No clock usage  
✅ No randomness  
✅ Typed failure modes  
✅ Evidence emission  

**The node is axiom-compliant and can exist in MK10-PRO.**

