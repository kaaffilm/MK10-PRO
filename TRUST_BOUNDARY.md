# Trust Boundary

## Trusted components

| Component | Trust basis |
|-----------|-------------|
| Python runtime | User's environment |
| Cryptographic libraries | `cryptography`, `pycryptodome` |
| Schema validation | `jsonschema` |
| File system | User's OS |

## Untrusted components

| Component | Handling |
|-----------|----------|
| Input files | Hash-verified, not content-validated |
| User-provided metadata | Recorded as-is, not validated |
| External timestamps | Not used; system time only |

## Attack surface

- Malformed input files → Schema validation rejects
- Hash collision → Cryptographically infeasible (SHA-256)
- Tampered MTB → Verification fails
- Modified engine → Hash mismatch detectable

## What MK10-PRO does NOT protect against

- Malicious content disguised as valid
- Incorrect user input
- Compromised runtime environment
- Pre-existing file corruption
- Social engineering
