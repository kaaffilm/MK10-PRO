# MK10-PRO v1.0.3 External Audit Packet

This packet is the public auditor compression layer for MK10-PRO v1.0.3.

It exists so an outside reviewer can verify the public replay perimeter without relying on founder narration.

## Canonical state

MK10-PRO version: 1.0.3

Canonical runtime witness: PyPI

PyPI package: mk10-pro==1.0.3

NPM package page: @kaaffilm/mk10-pro@1.0.3

GitHub source truth: kaaffilm/MK10-PRO main and release v1.0.3

## Auditor replay command

Run:

    bash scripts/audit-packet-proof.sh

A valid replay proves:

- version remains 1.0.3
- PACKAGE_SURFACES.json remains locked to 1.0.3
- PyPI remains canonical runtime witness
- NPM remains public registry discovery surface only
- PKG remains GitHub Packages surface only
- public surface proof passes
- public replay perimeter proof passes
- auditor replay proof passes

## No-version-raise rule

Do not raise the public package version to repair an immutable registry artifact.

The public package surface is locked at 1.0.3.

## Scope boundary

MK10-PRO verifies deterministic pre-delivery truth infrastructure.

It does not verify:

- playback
- device compatibility
- venue certification
- operator trustworthiness
- post-delivery behavior
- business outcome

## Acceptance condition

This packet is valid only if:

- scripts/audit-packet-proof.sh exits 0
- tests/test_audit_packet.py passes
- scripts/public-surface-proof.sh exits 0
- scripts/public-replay-proof.sh exits 0
- scripts/auditor-replay-proof.sh exits 0
- PACKAGE_SURFACES.json version_lock.locked_version == 1.0.3
- packages/npm/package.json version == 1.0.3
