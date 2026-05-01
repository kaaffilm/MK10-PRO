# MK10-PRO v1.0.3 Audit Receipt Schema

`AUDIT_RECEIPT_SCHEMA.json` defines the machine-readable acceptance shape for the MK10-PRO v1.0.3 audit receipt.

The schema fixes:

- receipt type
- PASS status
- version 1.0.3
- locked version 1.0.3
- PyPI as canonical runtime witness
- NPM and PKG as non-canonical public surfaces
- no-version-raise rule
- proof-chain PASS states
- SHA-256 file bindings
- claim boundary exclusions

Validate a receipt with:

    node scripts/verify-audit-receipt.cjs /path/to/MK10_PRO_AUDIT_RECEIPT.json

Or generate and verify a receipt with:

    bash scripts/audit-receipt-schema-proof.sh

The schema does not expand MK10-PRO's claim boundary.
