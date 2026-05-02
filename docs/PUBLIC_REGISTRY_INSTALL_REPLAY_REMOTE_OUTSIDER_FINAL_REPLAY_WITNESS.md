# MK10-PRO v1.0.3 Public Registry Install Replay — Remote Outsider Final Replay Witness

This witness binds the public finality index to a clean remote replay.

It verifies that an outsider can clone the public repository, check out the finality tag, replay the finality index, and confirm the public npm artifact without relying on local founder workspace state.

## Bound objects

- Version tag: `v1.0.3`
- Base replay seal: `mk10-pro-v1.0.3-public-registry-install-replay-seal`
- Release object git witness seal: `mk10-pro-v1.0.3-public-registry-install-replay-release-object-git-witness-seal`
- Finality index seal: `mk10-pro-v1.0.3-public-registry-install-replay-finality-index-seal`
- Public package: `@kaaffilm/mk10-pro@1.0.3`

## Replay command

```bash
REMOTE_OUTSIDER_LIVE_REPLAY=1 bash scripts/public-registry-install-replay-remote-outsider-final-replay-witness.sh
````

