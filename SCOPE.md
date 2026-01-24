# Scope

## Hard inclusions

- Pre-delivery verification for audiovisual mastering
- Deterministic hash computation
- Policy check recording
- MTB generation and sealing
- MTB verification

## Hard exclusions

- Cinema playback verification
- Device compatibility testing
- Operator trust evaluation
- Content quality assessment
- Human review substitution
- DRM or encryption handling
- File storage or hosting
- Network transmission verification
- Real-time monitoring
- Post-delivery tracking

## Boundary conditions

- Input must be local filesystem
- Output is MTB JSON only
- No external service dependencies
- No state persistence between runs
- No configuration beyond CLI flags

## Non-goals

- General-purpose hashing tool
- CI/CD integration framework
- Blockchain notarization
- Legal document generator
- Audit trail system (beyond MTB)
