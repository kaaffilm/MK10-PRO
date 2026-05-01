
# MK10-PRO v1.0.3 Auditor Replay

The auditor replay path is intentionally bounded.

It proves that a fresh checkout exposes the same locked public surface:

* `VERSION` is `1.0.3`;
* `PACKAGE_SURFACES.json` is locked to `1.0.3`;
* the NPM surface remains `@kaaffilm/mk10-pro@1.0.3`;
* PyPI remains the canonical runtime witness;
* NPM and PKG remain package/discovery surfaces only;
* public replay and public surface proofs pass.

## One-command replay

```bash
bash scripts/auditor-replay-proof.sh
```

## Live checks

The default auditor replay is local and deterministic after clone.

To include live registry probes:

```bash
MK10_AUDITOR_LIVE=1 bash scripts/auditor-replay-proof.sh
```

## Non-goals

Auditor replay does not certify playback, devices, venues, operators, post-delivery behavior, or business outcome.
