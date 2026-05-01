# MK10-PRO v1.0.3 Public Replay Perimeter

MK10-PRO v1.0.3 is locked as a public replayable package surface.

## Canonical version

```text
1.0.3
````

No public package version may be raised to repair an immutable registry artifact.

## Source of truth

```text
https://github.com/kaaffilm/MK10-PRO
```

GitHub `main` and release `v1.0.3` define the maintained source state.

## Canonical runtime witness

```text
PyPI: mk10-pro==1.0.3
```

Canonical runtime proof:

```bash
pip install mk10-pro==1.0.3
mk10 proof
mk10 boundary
mk10 witness
```

## Public package surfaces

| Surface | Role                                   | Replay command                                                         |
| ------- | -------------------------------------- | ---------------------------------------------------------------------- |
| PyPI    | canonical runtime witness              | `pip install mk10-pro==1.0.3 && mk10 proof`                            |
| NPM     | public registry discovery surface      | `npm view @kaaffilm/mk10-pro@1.0.3 version`                            |
| PKG     | GitHub Packages package-surface mirror | `npm install @kaaffilm/mk10-pro --registry=https://npm.pkg.github.com` |

## Replay boundary

The public replay perimeter proves only the bounded MK10-PRO claim:

```text
deterministic_pre_delivery_truth_infrastructure
```

It verifies:

* bounded evidence shape
* package resource presence
* policy/schema availability
* local proof surface coherence
* witness packet generation
* public package-surface version lock
* source/package/replay documentation coherence

It does not verify:

* playback
* device compatibility
* venue certification
* operator trustworthiness
* post-delivery behavior
* business outcome

## Replay artifacts

The replay perimeter is enforced by:

```text
PACKAGE_SURFACES.json
PUBLIC_SURFACE.md
docs/PUBLIC_SURFACE_LOCK.md
docs/PUBLIC_REPLAY_PERIMETER.md
scripts/public-surface-proof.sh
scripts/public-replay-proof.sh
tests/test_public_surface_lock.py
tests/test_public_replay_perimeter.py
.github/workflows/public-surface-lock.yml
.github/workflows/public-replay-perimeter.yml
```

## Refusal rule

If any surface tries to make NPM or PKG the canonical runtime witness, the replay perimeter fails.

If any surface raises the public package version above `1.0.3` to repair a registry artifact, the replay perimeter fails.

If any public package surface contradicts `PACKAGE_SURFACES.json`, the replay perimeter fails.

## Completion statement

MK10-PRO v1.0.3 is complete only while all replay surfaces remain locked to `1.0.3`, PyPI remains the canonical runtime witness, and NPM/PKG remain public package surfaces only.
