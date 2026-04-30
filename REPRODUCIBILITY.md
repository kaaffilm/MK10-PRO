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

<!-- MK10-PRO PACKAGE SURFACE RECONCILIATION -->
## Package surface reconciliation

`mk10-pro` 1.0.2 on PyPI is a historical published package artifact.

Current repository source state:

- `VERSION`: `1.0.2`
- `pyproject.toml` license metadata: `Apache-2.0`
- `PYPI_DISABLED`: present
- Publishing workflow: absent
- Package rebuilds from source are for verification only, not publication.

A verifier must not infer that the PyPI page is the current governance surface. PyPI reflects upload-time package metadata. GitHub `main` reflects the maintained source boundary.

<!-- END MK10-PRO PACKAGE SURFACE RECONCILIATION -->
