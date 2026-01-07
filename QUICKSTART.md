# Quick Start Guide

## Installation

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install package
pip install -e .
```

## Basic Usage

### 1. Ingest Assets

```bash
mk10 ingest --source /path/to/source/assets --output ingest_manifest.yaml
```

This creates an ingest manifest with cryptographic hashes of all source assets.

### 2. Execute Pipeline

Create a DAG definition file (see `examples/simple_dag.yaml`):

```yaml
id: "my_pipeline"
nodes:
  - id: "node1"
    type: "passthrough"
    config: {}
edges: []
```

Execute:

```bash
mk10 execute --dag pipeline.yaml --workspace .workspace
```

### 3. Promote to Release

```bash
mk10 promote --title "MyTitle" --version "v1.0" --state RELEASE
```

### 4. Verify MTB

```bash
mk10 verify --mtb /path/to/mtb.zip
```

## Building an MTB

```python
from mtb.builder import MTBBuilder
from pathlib import Path

builder = MTBBuilder("MyTitle", "v1.0")

# Add ingest assets
builder.add_ingest_asset(
    content_address="abc123.mxf",
    path=Path("source.mxf"),
    hash_value="abc123...",
    size=1000000,
)

# Set build evidence
builder.set_build_evidence("exec-1", [
    {"event_type": "execution_complete", ...}
])

# Add policy checks
builder.add_policy_check("determinism_required", True)

# Add validations
builder.add_validation("DCP", True)

# Build and seal
mtb = builder.build_and_seal()

# Save
builder.save(Path("output.mtb.json"), sealed=True)
```

## Verification

MTB verification can be performed independently:

```python
from mtb.verify import verify_mtb
from pathlib import Path

results = verify_mtb(Path("output.mtb.json"))
if results["valid"]:
    print("MTB is valid")
else:
    print(f"Errors: {results['errors']}")
```

## Testing

```bash
# Run all tests
pytest

# Run specific test
pytest tests/test_determinism.py

# With coverage
pytest --cov=engine --cov=mtb tests/
```

## Configuration

Edit `mk10.config.yaml` to customize:
- Workspace paths
- Policy rule file locations (rules themselves cannot be overridden)
- Evidence settings
- Format validation

**Note:** Policy rules cannot be overridden. Policy is law. Configuration only specifies where to find policy files, not what the rules are.

