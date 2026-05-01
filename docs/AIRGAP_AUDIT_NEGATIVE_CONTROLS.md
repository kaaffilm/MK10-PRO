# MK10-PRO v1.0.3 Airgap Audit Negative Controls

This layer proves the airgap audit bundle is not merely a happy-path receipt generator.

It must reject local mutations that weaken:

- v1.0.3 immutability
- required airgap contract files
- offline audit lock inheritance
- workflow wiring
- forbidden network access after checkout
- forbidden package-install dependency after checkout

Run:

```sh
bash scripts/airgap-audit-negative-controls.sh
````

Expected result:

```text
MK10-PRO v1.0.3 AIRGAP AUDIT NEGATIVE CONTROLS: PASS
```

Boundary: public package surfaces remain witness-only. The repository checkout remains canonical.
