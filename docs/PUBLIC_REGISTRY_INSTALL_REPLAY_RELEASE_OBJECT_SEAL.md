# MK10-PRO v1.0.3 Public Registry Install Replay Release Object Seal

This witness binds the GitHub release object for the public registry install replay seal to:

- merged main head
- annotated seal tag target
- original v1.0.3 release tag target
- public npm package digest
- PR merge record

The GitHub release object is intentionally not treated as the sole durable authority. The durable authority is the git witness plus the seal tag target and public registry digest.
