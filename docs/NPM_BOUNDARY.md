# MK10-PRO NPM Boundary

The NPM package is a witness launcher.

It must not become a separate implementation of MK10-PRO.

It may:

- expose `mk10-pro proof`;
- expose `mk10-pro boundary`;
- expose `mk10-pro witness`;
- guide users to the PyPI package;
- call an already installed `mk10` command when available;
- emit the package-surface contract.

It must not:

- reimplement the Python verification engine;
- add a new claim surface;
- claim playback validation;
- claim device validation;
- claim venue certification;
- hide the PyPI package as the canonical install surface.
