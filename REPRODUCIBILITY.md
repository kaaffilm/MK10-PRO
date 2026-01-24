# Reproducibility

## Build environment

| Component | Version | Hash verification |
|-----------|---------|-------------------|
| Python | 3.9+ | n/a |
| pip | latest | n/a |
| SHA-256 | hashlib | Standard |

## Installation verification

```bash
# Install from PyPI
pip install mk10-pro==1.0.2

# Verify package hash
pip hash mk10-pro
```

## Build from source

```bash
# Clone at specific tag
git clone --branch v1.0.2 https://github.com/kaaffilm/MK10-PRO.git
cd MK10-PRO

# Install in development mode
pip install -e .

# Run tests
pytest
```

## MTB reproducibility

Given identical:
- Input files (by path and content)
- Policy profile
- Schema version

The MTB hash will be identical.

## Non-reproducible elements

- `created_at` timestamp (by design)
- File modification times (recorded, not computed)

## Schema verification

```bash
# Verify schema hash
sha256sum mtb/schema/mtb_schema.json
```

## Offline operation

MK10-PRO requires no network access for:
- MTB generation
- MTB verification
- Policy evaluation
