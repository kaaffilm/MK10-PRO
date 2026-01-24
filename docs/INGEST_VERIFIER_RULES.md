# Ingest Manifest Verifier Rules
## Rejection Conditions (Mechanical Enforcement)

**Status:** These rules must be enforced by the verifier. No exceptions. No warnings. Fatal rejection only.

---

## 1. SCHEMA VALIDATION

### REJECT if:
- Manifest does not validate against `ingest.schema.json`
- Missing required fields: `manifest_version`, `ingest_timestamp`, `assets`
- `assets` array is empty
- Any asset missing required fields: `asset_id`, `content_hash`, `hash_algorithm`, `role`, `metadata`
- `content_hash` does not match pattern `^[a-f0-9]{64}$` (SHA-256 hex)
- `hash_algorithm` is not `"sha256"`
- `asset_id` contains invalid characters (must match `^[a-zA-Z0-9_-]+$`)
- `asset_id` is not unique across all assets
- `ingest_timestamp` is not valid ISO 8601
- `manifest_version` does not match semver pattern

**Error:** `INGEST_SCHEMA_INVALID`

---

## 2. ROOT DAG INPUT BINDING

### REJECT if:
- Any root DAG node has an input requirement that is not satisfied by an ingest asset
- A root DAG node expects a role that does not exist in the ingest manifest
- A root DAG node expects multiple assets with the same role, but only one exists
- A root DAG node expects a specific asset count, but the count does not match

**Error:** `ROOT_INPUT_UNBOUND`

**Verification Logic:**
```
FOR EACH root_node IN dag.root_nodes:
    FOR EACH required_input IN root_node.required_inputs:
        IF NOT EXISTS asset IN ingest.assets WHERE asset.role == required_input.role:
            REJECT with ROOT_INPUT_UNBOUND
        IF required_input.count IS SPECIFIED:
            IF COUNT(assets WHERE role == required_input.role) != required_input.count:
                REJECT with ROOT_INPUT_UNBOUND
```

---

## 3. INGEST ASSET USAGE

### REJECT if:
- An ingest asset exists but is not referenced by any root DAG node
- An ingest asset's role does not match any root DAG node's input requirements

**Error:** `INGEST_ASSET_UNUSED`

**Note:** This is a warning condition in some systems, but MK10-PRO rejects it because:
- Unused assets indicate incomplete DAG definition
- Truth requires explicit binding
- No inference allowed

**Verification Logic:**
```
FOR EACH asset IN ingest.assets:
    IF NOT EXISTS root_node IN dag.root_nodes WHERE root_node.requires_role(asset.role):
        REJECT with INGEST_ASSET_UNUSED
```

---

## 4. CONTENT HASH VERIFICATION

### REJECT if:
- An asset's declared `content_hash` does not match the actual content hash
- Hash algorithm mismatch (declared vs computed)

**Error:** `CONTENT_HASH_MISMATCH`

**Verification Logic:**
```
FOR EACH asset IN ingest.assets:
    actual_hash = compute_sha256(asset.content_bytes)
    IF actual_hash != asset.content_hash:
        REJECT with CONTENT_HASH_MISMATCH
```

**Note:** This requires the verifier to have access to asset content. If content is not available, this check is skipped, but the MTB must record that content verification was not performed.

---

## 5. METADATA COMPLETENESS

### REJECT if:
- Metadata is missing required fields for the declared role
- Metadata contains fields that are not declared in the schema
- Metadata is not canonical JSON

**Error:** `METADATA_INVALID`

**Note:** Role-specific metadata requirements must be defined in policy. The verifier checks against policy-defined requirements.

---

## 6. DETERMINISM REQUIREMENTS

### REJECT if:
- `ingest_timestamp` is not deterministic (varies across executions)
- Asset ordering in `assets` array is not canonical (must be sorted by `asset_id`)
- JSON serialization is not canonical (must use sorted keys, no whitespace)

**Error:** `INGEST_NON_DETERMINISTIC`

**Verification Logic:**
```
IF ingest.assets IS NOT sorted by asset_id:
    REJECT with INGEST_NON_DETERMINISTIC

IF ingest JSON is not canonical (sorted keys, no whitespace):
    REJECT with INGEST_NON_DETERMINISTIC
```

---

## 7. ROOT INPUT TRACEABILITY

### REJECT if:
- A root DAG node's input cannot be traced to an ingest asset
- The trace path is ambiguous (multiple possible sources)
- The trace path is incomplete (missing intermediate steps)

**Error:** `ROOT_INPUT_UNTraceABLE`

**Verification Logic:**
```
FOR EACH root_node IN dag.root_nodes:
    FOR EACH input IN root_node.inputs:
        IF input.content_address IS NOT IN [asset.content_hash FOR asset IN ingest.assets]:
            REJECT with ROOT_INPUT_UNTraceABLE
```

---

## SUMMARY: BINARY REJECTION CONDITIONS

| Condition | Error Code | Fatal? |
|-----------|------------|--------|
| Schema invalid | `INGEST_SCHEMA_INVALID` | ✅ YES |
| Root input unbound | `ROOT_INPUT_UNBOUND` | ✅ YES |
| Ingest asset unused | `INGEST_ASSET_UNUSED` | ✅ YES |
| Content hash mismatch | `CONTENT_HASH_MISMATCH` | ✅ YES |
| Metadata invalid | `METADATA_INVALID` | ✅ YES |
| Non-deterministic | `INGEST_NON_DETERMINISTIC` | ✅ YES |
| Root input untraceable | `ROOT_INPUT_UNTraceABLE` | ✅ YES |

**All rejections are fatal. No warnings. No recovery. No fallback.**

---

## VERIFIER IMPLEMENTATION REQUIREMENTS

The verifier must:

1. Load `ingest.schema.json`
2. Validate manifest against schema
3. Load DAG definition
4. Identify all root nodes
5. For each root node, verify all inputs are bound to ingest assets
6. Verify all ingest assets are used
7. Verify content hashes (if content available)
8. Verify metadata completeness
9. Verify determinism (canonical JSON, sorted assets)
10. Verify traceability

**If any step fails → REJECT immediately.**

**No partial acceptance. No conditional validation. Binary only.**

