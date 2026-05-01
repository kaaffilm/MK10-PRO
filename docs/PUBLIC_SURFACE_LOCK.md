# MK10-PRO v1.0.3 Public Surface Lock

This document records the final public surface completion lock for MK10-PRO v1.0.3.

## Locked version

```text
1.0.3
```

## Rule

Do not raise the public package version to repair an immutable registry artifact.

## Canonical runtime witness

PyPI remains the canonical runtime witness:

```bash
pip install mk10-pro==1.0.3
mk10 proof
```

## Non-canonical public package surfaces

NPM and PKG are not canonical runtime witnesses.

They are public package/discovery surfaces only.

## Completion lock

The completion lock is valid only while all public surfaces remain at `1.0.3`.
