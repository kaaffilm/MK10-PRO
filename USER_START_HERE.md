# MK10-PRO — Start Here

MK10-PRO is deterministic pre-delivery truth infrastructure for audiovisual mastering.

v1.0.3 is the Witness Release.

## Installed package path

```bash
pip install mk10-pro==1.0.3
mk10 proof
mk10 boundary
mk10 witness
```

## Source checkout path

```bash
git clone https://github.com/kaaffilm/MK10-PRO.git
cd MK10-PRO
bash scripts/release-proof.sh
```

## Command meanings

| Command | Meaning |
|---|---|
| `mk10 proof` | Verifies the package/source truth surface. |
| `mk10 boundary` | Prints exact claims and non-claims. |
| `mk10 witness` | Writes a portable local evidence packet. |

## Success lines

```text
MK10-PRO PROOF: PASS
MK10-PRO BOUNDARY: PASS
MK10-PRO WITNESS: PASS
MK10-PRO RELEASE PROOF: PASS
```

## What MK10-PRO is not

MK10-PRO is not a playback validator, device compatibility checker, venue certification system, post-delivery monitor, general media pipeline framework, or trust badge.

MK10-PRO stops at deterministic pre-delivery truth.
