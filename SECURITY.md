# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Do not open public issues for security vulnerabilities.**

To report a security vulnerability, email: **security@kaaffilm.com**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes (optional)

## Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 7 days
- **Resolution target**: Within 30 days for critical issues

## Scope

### In Scope

- MTB generation and verification
- Hash computation and integrity
- Evidence recording
- Policy enforcement
- CLI security

### Out of Scope

- Third-party dependencies (report to upstream)
- Documentation errors
- Non-security bugs

## Security Model

MK10-PRO operates under these security invariants:

1. **Determinism**: Same input → same MTB hash, always
2. **Integrity**: MTB tampering is detectable
3. **Evidence chain**: All operations are recorded
4. **Policy enforcement**: Rules cannot be bypassed

Breaking any of these invariants constitutes a critical vulnerability.
