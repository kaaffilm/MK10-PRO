# Authoritative Index

## This repository

MK10-PRO is the **authoritative source** for:
- MTB schema definitions
- MTB generation logic
- MTB verification logic
- Policy enforcement rules

## Authoritative files

| File | Authority |
|------|-----------|
| `mtb/schema/mtb_schema.json` | MTB structure definition |
| `engine/policy/policy.py` | Policy evaluation logic |
| `verifier/verify.py` | Verification implementation |
| `CANONICAL.md` | Scope and purpose |
| `ADVERSARIAL_FAQ.md` | Misinterpretation corrections |

## Related systems

| System | Relationship |
|--------|--------------|
| CICULLIS | Enforces policy at CI time |

## Non-authoritative

- Documentation in `docs/`
- Examples in `examples/`
- Test fixtures (illustrative only)
- README prose

## Verification

```bash
# Verify schema hash
sha256sum mtb/schema/mtb_schema.json
```
