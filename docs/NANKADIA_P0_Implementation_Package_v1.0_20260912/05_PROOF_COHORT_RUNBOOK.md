# Proof Cohort / Experiment Config Runbook

## 1. Cohort sequence

```text
Calibration C01: 10–15 users (not proof denominator)
↓ only after reliability + policy calibration
Proof A: 50 fresh users
↓ only if all primary + measurement quality gates pass
Proof B: 50 fresh users on same material config
↓
Final GO requires A PASS and B PASS separately
```

Do not average A+B to hide a failed B.

## 2. User reuse

- Calibration users cannot enter Proof A/B denominator.
- Proof A users cannot be reused in Proof B.
- A user belongs to one active cohort evaluation path.

## 3. Config lifecycle

`DRAFT → ACTIVE → RETIRED`

- `ACTIVE` is immutable.
- Core pool release referenced by ACTIVE is immutable.
- Material change: RETIRE → new DRAFT → activate new config → create fresh cohort.

## 4. Material change checklist

A new config/cohort is required if any changes:

- Core membership
- eligibility/hard-filter rule
- A/B bucket logic
- tie-break policy
- Moment Mode choices/semantics
- Context question order/trigger
- Snapshot reference semantics
- Fit Receipt behavior that can change user action
- scope expansion/fallback policy
- Profile influence
- primary CTA
- Action Started boundary or Execution friction
- Outcome prompt content/timing

Usually non-material:

- typo with no behavior impact
- internal refactor with exact behavior preserved
- performance optimization

Metric computation bug is handled by new `metric_contract_version` and correction records, not by pretending Product config changed.

## 5. Stop conditions

Stop adding users immediately when:

- proof-critical event missingness or unexplained duplication appears
- SELF_MOMENT false positives/negatives are found
- Action Started boundary is ambiguous
- ACTIVE config mutates
- Core membership mutates
- routine DB hand-editing is needed to keep the flow alive
- No Match reason cannot be reconstructed
- major privacy/security incident occurs
- synthetic metric reconstruction does not match SQL result

Metric weakness is not itself a reason to corrupt the experiment. First prove the metric is trustworthy.

## 6. Strong pivot diagnostics

Historical implementation guidance treated high coverage + healthy measurement with very low GAL (<8%) or D14 (<15%) as a strong Pivot signal. These are diagnostics, not replacements for the Primary Gates.
