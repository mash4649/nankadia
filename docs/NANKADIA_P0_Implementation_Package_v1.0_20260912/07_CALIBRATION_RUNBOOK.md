# Calibration-1 Runbook

## 1. Goal

Calibration-1 does not prove Product success. It verifies that the kernel is understandable, measurable, and not obviously mis-specified before fresh Proof cohorts are spent.

Target: **10–15 users**.

## 2. Preflight

Must be green:

- Slice A E2E happy path
- No Match path
- scope expansion path
- Baseline Keep path
- Outcome Missing path
- later SELF_MOMENT path
- event retry/idempotency
- config/core immutability
- seed release/human review gate
- synthetic metric reconciliation
- deferred-code absence check

## 3. Observe each Moment

Capture without forcing extra UI:

- number of system questions before first card
- resolved kernel values + source
- Context correction
- A/B bucket selected
- exclusion reason counts
- card rank/exposure within Moment
- Skip/Accept/No Match
- optional sampled Skip reason
- scope expansion
- Baseline Keep
- execution + Outcome

## 4. Calibration diagnostics

### Prompt Burden
Should reveal whether the “max one non-required question” still feels intrusive.

### Context Correction Rate
High rate means inference/resolver semantics are weak.

### Situational Mismatch Rate
Use sampled Skip reason/corrections to identify TOO_FAR / WRONG_DIRECTION / TOO_LONG / NEED_ALREADY_SATISFIED / COST_MISMATCH vs pure NOT_INTERESTED.

### No Match / Scope Expansion
High expansion use indicates default scope or Seed coverage may be too narrow. Do not jump directly to system relaxation.

### Direct vs Expanded GAL Component
If most action comes only after expansion, initial Context/coverage is weak even if primary GAL looks acceptable.

## 5. Changes allowed during Calibration

Change only PROVISIONAL parameters or copy/layout that does not violate the kernel. Every material policy change receives a new config and a fresh calibration cohort if needed.

Do not add Deferred features because 1–2 users ask for them.

## 6. Calibration exit

Move to Proof A only when:

- measurement integrity is stable;
- no unexplained No Match remains;
- context corrections are understood;
- seed situation metadata is reliable;
- all release-blocking tests remain green;
- final policy/config version is frozen for Proof A.
