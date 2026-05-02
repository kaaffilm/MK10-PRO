# MK10-PRO v1.0.3 Public Registry Install Replay

This layer proves that a clean outside npm consumer can install the already-published public registry artifact:

`@kaaffilm/mk10-pro@1.0.3`

The replay verifies:

- the installed package version is `1.0.3`;
- the installed package lock integrity matches `PUBLIC_REGISTRY_ARTIFACT_LOCK.json`;
- the resolved tarball matches the locked public npm tarball;
- the installed binary emits the locked public surface pins;
- the replay does not substitute a local tarball.

Run:

```bash
bash scripts/public-registry-install-replay.sh
````

Expected terminal seal:

```text
MK10-PRO v1.0.3 PUBLIC REGISTRY INSTALL REPLAY: PASS
```

