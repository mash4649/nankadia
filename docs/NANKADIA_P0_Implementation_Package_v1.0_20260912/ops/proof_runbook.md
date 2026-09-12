# Operator Proof Runbook

1. Validate Seed payloads against JSON schema.
2. Confirm 100% Human Review and v2.4.1 situation metadata completeness.
3. Compute/verify manifest hash.
4. Release immutable Core pool.
5. Create DRAFT experiment config referencing exact pool/policy versions.
6. Run synthetic E2E + metric fixture.
7. Activate config, create Calibration cohort, enroll 10–15 fresh users.
8. Monitor event integrity before Product metrics.
9. If material change is required: close cohort, retire config, create a new version/fresh cohort.
10. Freeze final config for Proof A; then Proof B only after A passes.
