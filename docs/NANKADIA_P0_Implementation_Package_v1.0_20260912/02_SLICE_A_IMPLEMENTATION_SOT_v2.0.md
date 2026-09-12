# NANKADIA P0 Slice A Implementation Source of Truth v2.0

**Parent:** Source of Truth v2.4.1  
**Compiled:** 2026-09-12  
**Scope:** Core Proof Runtime + Measurement Spine + Seed Release + Calibration Readiness

## 0. Decision

Slice A proves one thing: a user can begin an authentic “なんかない？” Moment, receive one situation-fit experience with minimal friction, actually start and complete it, return an Outcome, and later choose NANKADIA again in a self-initiated Moment — with measurement strong enough to trust the result.

The implementation must optimize for **auditability and simplicity**, not algorithmic sophistication.

## 1. Runtime path

```text
App Entry
→ explicit Moment Start
→ resolve minimal Context Kernel
→ immutable Context Snapshot
→ Recommendation Decision
→ one Card Impression
→ Accept / Skip / No Match
→ Execution
→ Outcome
→ later DIRECT explicit Moment
→ SELF_MOMENT qualification
```

## 2. Runtime objects

Required:

- `app_user`
- `app_session`
- `experiment_config`
- `proof_cohort`
- `proof_enrollment`
- `moment`
- `context_snapshot`
- `experience`
- `resolution`
- `core_pool_release`
- `core_pool_member`
- `recommendation_decision`
- `recommendation_impression`
- `execution`
- `outcome`
- `incremental_discovery`
- append-only `event_log`
- append-only `measurement_exclusion` / `event_correction`

Optional/nullable in Slice A:

- `entity`
- `entity_fact`
- `access_route`
- `access_route_fact`

Do not create Slice B objects as a Slice A runtime dependency.

## 3. Identity

- A stable opaque `user_id` is required through D14.
- Email, phone, social login, DOB, occupation and exact income are not required.
- Identity loss is not repaired by fingerprinting or heuristic linking.
- User timezone is stored; initial default for the Japan P0 is `Asia/Tokyo` unless the application obtains a trusted user/device setting.

## 4. Proof enrollment

```text
app_user
  ↓
proof_enrollment
  ├─ proof_cohort_id
  └─ experiment_config_id
```

A user belongs to one calibration/proof cohort for the evaluation period. Calibration users are not reused in Proof A; Proof A users are not reused in Proof B.

## 5. Experiment configuration

Minimum material policy references:

- `core_pool_version`
- `ranking_policy_version`
- `fallback_policy_version`
- `moment_policy_version`
- `context_policy_version`
- `profile_policy_version`
- `ui_variant_version`
- `access_route_policy_version`
- `outcome_prompt_version`
- `metric_contract_version`

`ACTIVE` configs are immutable. Material change = retire old config, create new config, enroll a fresh cohort.

Material change includes Core membership, eligibility, bucket/tie-break logic, Context question or resolver, snapshot reference semantics, fallback/scope expansion, Profile use, primary CTA, Execution friction/boundary, Outcome content/timing.

## 6. Moment and Context

### 6.1 Moment

A Moment starts only when the user explicitly starts a new “なんかない？” opportunity. App resume/navigation alone does not create a new Moment.

### 6.2 Context Kernel

Exactly three runtime kernel axes:

- `trajectory_type`
- `detour_budget`
- `immediate_need`

Auxiliary passive facts may inform Situation Fit only when already available. They cannot create a new pre-card question.

### 6.3 Question budget

- Required safety/legal/executability questions: outside budget.
- Non-required system question before first card: **max 1 per Moment**.
- Priority: Required → Moment Mode → Immediate Need.
- Never ask a second non-required question just to improve confidence.

### 6.4 Snapshot

Each Recommendation Decision references exactly one immutable `context_snapshot_id`. Corrections or explicit scope expansion create a new snapshot in the same Moment. Never mutate the prior snapshot.

## 7. Recommendation

Runtime algorithm is fixed to three stages:

1. Hard Filter
2. Situation Fit Bucket
3. Discovery Tie-break

No runtime LLM, no weighted user utility score, no online model learning during proof.

The result is one Resolution or explicit No Match.

## 8. Fit Receipt

The card may show 1–3 coarse fit facts such as `帰り道 / 寄り道小さめ / +7分`. A user correction creates a new Context Snapshot and Recommendation Decision.

Never display unsupported precision or raw exact location.

## 9. Skip / No Match

- Skip means “not selected now”; it is not an Outcome and not persistent dislike.
- A normal Skip advances to another eligible non-repeated candidate in the same Moment, subject to `max_cards_per_moment` PROVISIONAL policy.
- No Match is valid behavior; do not synthesize a weak card.
- No Match exposes Baseline Keep and may expose user-initiated one-step detour expansion.
- Expansion is `NONE→SMALL→OPEN`, one adjacent step per explicit user action, creating a new snapshot.
- System-initiated relaxation is absent.

## 10. Execution

State machine:

```text
ACCEPTED → STARTED → COMPLETED
                  ↘ ABORTED
```

`external_open` is an event, not a state. Accept and External Open do not imply Action Started. Server validates transitions.

## 11. Outcome

Outcome:

- `GOOD`
- `NEUTRAL`
- `BAD`
- `MISSING`

Complete ≠ Positive Outcome. Missing Outcome never blocks a later Moment.

Incremental Discovery is asked independently for completed experiences:

- `LIKELY_YES`
- `UNCERTAIN`
- `LIKELY_NO`
- `SKIP`

It is diagnostic, not a Primary Gate.

## 12. Return / SELF_MOMENT

P0 qualification is intentionally conservative:

```text
explicit new Moment
AND entry_origin = DIRECT
AND local calendar date > Day0 local date
AND local calendar date <= Day0 + 14
```

External Share / Notification / Campaign / Other Deeplink / Unknown are not SELF_MOMENT. Same-calendar-day reuse does not count toward D14.

## 13. Measurement

Primary user-level spine is the **First Qualifying Moment** so repeat-heavy users do not overweight first-value proof.

- GAL: Qualifying users whose first qualifying Moment achieves Accept→Start→Complete→GOOD. Gate ≥15%.
- D14 Self-Initiated Return: Qualifying users with ≥1 SELF_MOMENT on day 1–14. Gate ≥30%.
- Positive Outcome: GOOD / RECORDED among first qualifying completed executions. Gate ≥60%.
- Outcome Capture: RECORDED / COMPLETED among first qualifying completed executions. Measurement Quality gate ≥70%.
- Incremental Discovery: LIKELY_NO / answered. Diagnostic.

No Match / Skip / BAD / no action remain in the denominator. Only technical measurement invalidity can be excluded, with append-only reason.

## 14. Transaction and event integrity

- Proof-critical state mutation and its proof event occur in the same server transaction.
- `event_id` is unique and retry-safe.
- Client timestamps are stored for diagnostic ordering; server time governs metric windows.
- Event log is append-only. Corrections/exclusions are new records.
- Client is not a security or measurement authority.

## 15. Seed Core

Existing RC1 is preserved as historical candidate content: 40 candidates, 36 CORE-eligible pending human review, 4 PARKED. Human review remains a release gate.

Before release under v2.4.1, each CORE candidate must receive the new machine-evaluable situation metadata defined in `06_SEED_CORE_MIGRATION_CONTRACT.md` and pass the situation-sensitive coverage audit.

## 16. Operations minimum

Before Calibration-1, operators must be able to:

- import/inspect seed release
- create/activate/retire experiment config
- create/close proof cohort
- enroll a user
- inspect user journey
- inspect raw events
- inspect No Match/exclusion reasons
- inspect measurement exclusions/corrections
- compute primary and diagnostic metrics

SQL/scripts/internal page are sufficient. Do not build a large admin console first.

## 17. Slice A Definition of Done

Slice A is done only when:

- one production-equivalent user can traverse Moment→Recommendation→Execution→Outcome and later SELF_MOMENT;
- the journey can be reconstructed from append-only events;
- all blocking acceptance tests pass;
- active config/core pool are immutable;
- Seed release gate is complete;
- synthetic metrics reconcile exactly;
- deferred runtime branches do not exist.
