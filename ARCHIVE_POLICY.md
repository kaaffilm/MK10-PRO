# Archive Policy

## Retention

| Artifact | Retention | Location |
|----------|-----------|----------|
| MTB files | User's responsibility | Local storage |
| Schema versions | Permanent | Repository |
| PyPI releases | Permanent | PyPI |
| Git tags | Immutable | GitHub |

## MK10-PRO responsibility

MK10-PRO commits to:
- Maintaining schema files indefinitely
- Never deleting released tags
- Never modifying released packages
- Preserving backward compatibility within major version

## MK10-PRO does NOT guarantee

- Package hosting beyond PyPI policies
- Repository availability
- Support or maintenance

## MTB validity after project discontinuation

MTB files remain valid if MK10-PRO:
- Is discontinued
- Repository is deleted
- PyPI package is removed

Verification requires only:
- The MTB JSON file
- The schema file (archived)
- JSON Schema validator

## Archival recommendations

Users should:
1. Store MTB files locally
2. Archive the schema version used
3. Preserve input files referenced in MTB
4. Document verification steps

## Schema migration

No migration path exists between schema versions.
Each MTB is self-contained and permanently valid per its schema version.
