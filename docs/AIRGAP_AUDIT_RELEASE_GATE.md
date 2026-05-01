# MK10-PRO v1.0.3 Airgap Audit Release Gate

This gate is the release-level admissibility check for the v1.0.3 airgap audit stack.

It does not raise the package version.

It requires local replay of:

- `OFFLINE_AUDIT_LOCK`
- `AIRGAP_AUDIT_BUNDLE`
- `AIRGAP_AUDIT_NEGATIVE_CONTROLS`
- `AIRGAP_AUDIT_DIGEST_LOCK`

Boundary:

- canonical source: repository checkout
- network after checkout: forbidden
- registry lookup: not required
- package installation: not required
- digest algorithm: SHA-256
- public package surface: witness only

Run:

```sh
bash scripts/airgap-audit-release-gate.sh
````

Passing output emits:

```text
MK10-PRO v1.0.3 AIRGAP AUDIT RELEASE GATE: PASS
```

