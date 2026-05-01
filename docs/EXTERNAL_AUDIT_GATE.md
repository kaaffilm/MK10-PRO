# MK10-PRO v1.0.3 External Audit Gate

This is the one-command audit gate for MK10-PRO v1.0.3.

Run:

    bash scripts/external-audit-gate.sh

The gate verifies:

- public surface lock
- public replay perimeter
- auditor replay entrypoint
- external audit packet
- machine-readable audit receipt
- audit receipt schema verifier
- audit receipt negative controls
- targeted audit tests
- NPM package discovery surface smoke and dry-run pack

Boundary:

- PyPI remains the canonical runtime witness.
- NPM and GitHub Packages remain package/discovery surfaces only.
- The public package version remains locked at 1.0.3.
- The no-version-raise rule remains active.
