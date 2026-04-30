# MK10-PRO PyPI Release Policy

MK10-PRO v1.0.3 is the Witness Release.

## Release identity

- Version: `1.0.3`
- Name: `MK10-PRO v1.0.3 — Witness Release`
- Purpose: make MK10-PRO installable, locally provable, and evidence-producing for normal users.

## User surface

v1.0.3 exposes three canonical commands:

```bash
mk10 proof
mk10 witness
mk10 boundary
```

## Meaning

- `mk10 proof` verifies the installed/source package truth surface.
- `mk10 witness` writes a portable local evidence packet.
- `mk10 boundary` prints exact claims and non-claims.

## Publishing rule

PyPI publication is allowed only through GitHub Actions Trusted Publishing.

Manual local upload is not authorized.

## What this release does not change

- MK10-PRO remains deterministic pre-delivery truth infrastructure.
- MK10-PRO does not verify playback.
- MK10-PRO does not verify devices.
- MK10-PRO does not verify venues.
- MK10-PRO does not become a post-delivery monitor.
- MK10-PRO does not gain external integrations.
- MK10-PRO does not expand beyond pre-delivery truth.
