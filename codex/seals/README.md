# Seals Directory

This directory contains the cryptographic seals and binding records for the ATUM_ATOM Triadic Seal system.

## Contents

### seal_20260621_103610.txt
State snapshot (Pillar III) capturing the Codex state at binding time.
- **Status:** Triadic-stable (v4.1)
- **Drift:** None detected
- **Timestamp:** 2026-06-21T10:36:10

### triadic_seal_20260621_104332.txt
Meta-seal (v5) consolidating all three pillars into a single verifiable event.
- **Status:** Triadic-stable
- **Timestamp:** 2026-06-21T10:43:32.2439408-07:00
- **Content:** Binding composition, drift report, operator attestation

## Seal Verification

To verify any seal:

```bash
# Check seal hash
sha256sum triadic_seal_20260621_104332.txt

# Expected:
# 58B16B0280F3DF2B4A463A1647AE606E85B11E460FDD7092717A5D4BDF9145FD

# Verify signature (requires operator public key)
openssl dgst -sha256 -verify pub.pem -signature seal.sig seal.txt
```

## Binding Cycle Schedule

- **Initial Binding:** 2026-06-21
- **Next Verification:** 2026-07-21 (Monthly)
- **Operator:** James Paul Stanley Jr
- **Key:** EDDSA F9B445CFDBA1ECD6ECC1899CB58390F86B642281

## References

- Main governance: `TRIADIC_SEAL.md` (root)
- Manifest: `.triadic/manifest.txt`
- Governance protocol: `.triadic/governance.md`
