# MK10-PRO Package Surfaces

MK10-PRO has three public package surfaces.

| Surface | Role | Verification |
|---|---|---|
| PYPI | Canonical runtime witness | `pip install mk10-pro==1.0.3 && mk10 proof` |
| NPM | Public registry discovery surface | `npm view @kaaffilm/mk10-pro@1.0.3 version` |
| PKG | GitHub Packages registry surface | GitHub Packages package visibility |

## Source truth

GitHub `main` and release `v1.0.3` define the maintained source state.

## No-version-raise rule

`1.0.3` is locked.

Do not raise the public package version to repair an immutable registry artifact.

## Boundary

NPM and PKG are launcher/discovery surfaces, not canonical runtime witnesses.

They do not reimplement MK10-PRO.

They do not expand MK10-PRO's claim boundary.

They do not authorize any version raise.

The canonical runtime witness remains PyPI:

```bash
pip install mk10-pro==1.0.3
mk10 proof
````

