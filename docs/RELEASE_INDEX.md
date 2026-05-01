# MK10-PRO v1.0.3 Release Index

This document is the human-readable companion to RELEASE_INDEX.json.

The release index gives an outside auditor one canonical place to locate the v1.0.3 audit chain.

Required verifier order:

1. offline audit lock
2. airgap audit bundle
3. airgap audit negative controls
4. airgap audit digest lock
5. airgap audit release gate
6. public release seal

The public release seal is discovery and binding only. It must not mutate package behavior or raise the version.
