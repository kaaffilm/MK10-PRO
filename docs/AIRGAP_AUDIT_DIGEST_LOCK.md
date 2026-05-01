# MK10-PRO v1.0.3 Airgap Audit Digest Lock

This lock adds a deterministic SHA-256 digest layer over the v1.0.3 offline and airgap audit perimeter.

It does not raise the package version.

## Boundary

The canonical source is repository checkout.

After checkout, the verifier:

1. runs the offline audit lock,
2. runs the airgap audit bundle,
3. runs the airgap audit negative controls,
4. computes SHA-256 digests for the required critical files,
5. emits `MK10_PRO_AIRGAP_AUDIT_DIGEST_LOCK_RECEIPT.json`,
6. rejects receipt tampering through internal negative controls.

## Forbidden dependency

The digest lock must not depend on registry lookup, package installation, GitHub API fetch, or network package fetch after checkout.

## Command

```sh
bash scripts/airgap-audit-digest-lock.sh
````

