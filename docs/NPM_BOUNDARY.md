
# MK10-PRO NPM Boundary

NPM surface:

```text
@kaaffilm/mk10-pro
```

Version:

```text
1.0.3
```

## Role

The NPM package is a public registry discovery surface.

It is not the canonical runtime witness.

It does not reimplement MK10-PRO.

It does not expand MK10-PRO's claim boundary.

## Canonical runtime proof

```bash
pip install mk10-pro==1.0.3
mk10 proof
```

## NPM visibility proof

```bash
npm view @kaaffilm/mk10-pro@1.0.3 version
```

## No-version-raise rule

Do not raise the public package version to repair an immutable NPM artifact.
