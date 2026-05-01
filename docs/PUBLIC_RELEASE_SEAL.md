# MK10-PRO v1.0.3 Public Release Seal

This seal is the public release discovery boundary for MK10-PRO v1.0.3.

It does not change runtime behavior, package behavior, CLI flags, or package version.

It binds the release to:

- the offline audit lock
- the airgap audit bundle
- the airgap audit negative controls
- the airgap audit digest lock
- the airgap audit release gate
- the release index

The seal is valid only when scripts/public-release-seal.sh passes from a clean checkout.
