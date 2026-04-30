# MK10-PRO Package Surfaces

MK10-PRO has one source truth and three public package surfaces.

## Source truth

```text
https://github.com/kaaffilm/MK10-PRO
```

GitHub `main` and signed releases define the maintained source boundary.

## PYPI

Python install surface.

```bash
pip install mk10-pro==1.0.3
mk10 proof
mk10 boundary
mk10 witness
```

## NPM

JavaScript registry discovery and launcher surface.

This is not a second MK10-PRO implementation.

It is a thin launcher that points users to the canonical installed witness commands.

```bash
npx @kaaffilm/mk10-pro proof
npx @kaaffilm/mk10-pro boundary
npx @kaaffilm/mk10-pro witness
```

## PKG

GitHub Packages registry surface.

```bash
npm install @kaaffilm/mk10-pro --registry=https://npm.pkg.github.com
npx @kaaffilm/mk10-pro proof
```

## Boundary

MK10-PRO verifies deterministic pre-delivery truth.

It does not verify playback, devices, venues, operators, post-delivery behavior, or business outcomes.
