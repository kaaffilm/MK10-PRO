# MK10-PRO v1.0.3 Offline Audit Lock

This layer separates the external audit gate from live network availability.

The external audit gate may prove live package surfaces. The offline audit lock proves that a checked-out repository contains a bounded, local, machine-readable audit surface that can be inspected without fetching packages, querying registries, calling GitHub APIs, or installing dependencies.

## Boundary

Canonical source:

- repository checkout at the audited commit

Non-canonical live surfaces:

- npm registry
- PyPI registry
- GitHub Actions live status
- GitHub API
- network package installers

## Offline verifier

Run:

```sh
bash scripts/offline-audit-lock.sh
````

The verifier checks:

* version remains locked at `1.0.3`
* audit-layer files exist
* audit-layer declarations remain bounded
* offline proof script avoids network/package-install commands
* Node package smoke path remains local
* no registry result is promoted to canonical truth

A successful offline lock does not claim live publication. It claims that the repository checkout contains a self-describing audit perimeter that can be inspected locally after clone/checkout.
