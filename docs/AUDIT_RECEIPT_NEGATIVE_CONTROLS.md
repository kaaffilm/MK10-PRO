# MK10-PRO v1.0.3 Audit Receipt Negative Controls

This layer proves that the audit receipt verifier is not merely accepting happy-path receipts.

The negative controls mutate a valid generated receipt and assert rejection for:

- raised public version
- raised locked version
- canonical witness drift
- disabled no-version-raise rule
- NPM promoted to canonical runtime witness
- failed proof-chain state
- invalid SHA-256 binding
- wrong source release
- failed receipt status
- expanded claim boundary

Run:

    bash scripts/audit-receipt-negative-proof.sh

The verifier must accept the valid generated receipt and reject every mutated receipt.
