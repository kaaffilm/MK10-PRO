# Schema Hashes — MK10-PRO v1.0
## Immutable Schema Lock

**Version:** 1.0.0  
**Date:** Release Lock

---

## SCHEMA HASHES

### MTB Schema

**File:** `mtb/schema/mtb.schema.json`  
**Hash (SHA-256):** `8caab7508b463e7f8678598500832aee2981c51aaf0b704fb119277d8134254a`

**Verifier Rule:** MTB must reference this exact schema hash. Mismatch → REJECT.

---

### Evidence Schema

**File:** `mtb/schema/evidence.schema.json`  
**Hash (SHA-256):** `28a7e8b87a1b50a8e90147249a13e248eee57f6db42261ad85d8506676bef7d6`

**Verifier Rule:** Evidence events must conform to this schema. Mismatch → REJECT.

---

### Ingest Manifest Schema

**File:** `mtb/schema/ingest.schema.json`  
**Hash (SHA-256):** `feddd89417b5e1ae0e00dfae0a33f053dc45004e73c3b2822b82bcf84fcc63a5`

**Verifier Rule:** Ingest manifest must conform to this schema. Mismatch → REJECT.

---

## POLICY HASH

**File:** `engine/policy/rules.yaml`  
**Hash (SHA-256):** `dd8abfc6b6d3ff51ec72b6e14d6a86821c62940169b6b2c765da1379621fc5b3`

**Rule:** Policy changes = major version bump. This hash is locked for v1.0.

---

## VERIFIER HASH

**File:** `verifier/verify.py`  
**Hash (SHA-256):** `63367e4207c2b26c8ed474ddbded4400faa142f6260384cd3170cbb6abd5d56c`

**Note:** Verifier code hash for reference. Verifier is standalone and does not require engine.

---

## LOCK RULES

1. **Schema Changes:** Any schema modification requires new major version
2. **Policy Changes:** Any policy rule modification requires new major version
3. **Verifier Changes:** Verifier logic changes require new major version
4. **Hash Verification:** Verifier must reject MTBs with mismatched schema references

---

## STATUS

**Locked:** ✅ **v1.0.0**

**All schemas and policy are hash-locked.**

**No modifications allowed without version bump.**

