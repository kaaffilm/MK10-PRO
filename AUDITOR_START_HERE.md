# MK10-PRO v1.0.3 — Auditor Start Here

This is the outsider replay entrypoint for MK10-PRO v1.0.3.

## Fixed public surface

```text
Source truth: https://github.com/kaaffilm/MK10-PRO
Release:      v1.0.3
PyPI:         mk10-pro==1.0.3
NPM:          @kaaffilm/mk10-pro@1.0.3
PKG:          @kaaffilm/mk10-pro on GitHub Packages
Version rule: do not raise the public package version to repair an immutable registry artifact
````

## Canonical runtime witness

```bash
pip install mk10-pro==1.0.3
mk10 proof
mk10 boundary
mk10 witness
```

## Repository replay

```bash
git clone https://github.com/kaaffilm/MK10-PRO
cd MK10-PRO
bash scripts/auditor-replay-proof.sh
```

## Boundary

MK10-PRO verifies deterministic pre-delivery truth infrastructure.

It does not verify playback, device compatibility, venue certification, operator trustworthiness, post-delivery behavior, or business outcome.
