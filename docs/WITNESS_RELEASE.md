# MK10-PRO v1.0.3 — Witness Release

v1.0.3 turns MK10-PRO into a package that can produce its own local evidence packet.

## Canonical commands

```bash
mk10 proof
mk10 boundary
mk10 witness
```

## Witness packet

`mk10 witness` writes:

- `MK10-WITNESS.json`
- `BOUNDARY.json`
- `README.md`
- `SHA256SUMS`

The witness packet is not a certificate.

It is a local evidence packet describing the installed/source truth surface.
