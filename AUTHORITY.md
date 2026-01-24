# Authority

## What is authoritative

- `mtb/schema/*.json` — MTB schema definitions
- `engine/` — Verification engine
- `verifier/` — Standalone verifier
- `CANONICAL.md` — Scope and purpose
- `ADVERSARIAL_FAQ.md` — Misinterpretation corrections

## What is NOT authoritative

- `docs/` — Informational only
- `examples/` — Illustrative only
- Comments in code — Not binding
- README prose — Summary only
- External references — Not controlled

## Authority chain

1. Schema files define structure
2. Engine implements schema
3. Verifier validates against schema
4. All other artifacts are derived

## Changes to authority

Changes to authoritative artifacts require:
- Explicit version bump
- Schema hash update
- Changelog entry
- No silent modification
