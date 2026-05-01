# MK10-PRO v1.0.3 Public Package Install Replay

This boundary proves that the sealed public release surface can be replayed from the packaged npm artifact.

The replay packs `packages/npm`, installs the resulting tarball into a clean temporary consumer project, blocks registry use, verifies the installed package identity, verifies the binary surface, and preserves the upstream public release seal.

This is not a publish action. It is the last local-public replay boundary before live package registry publication.
