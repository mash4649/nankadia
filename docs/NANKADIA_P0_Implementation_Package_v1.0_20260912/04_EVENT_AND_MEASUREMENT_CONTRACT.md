# Event and Measurement Contract

## 1. Event envelope

Every proof-relevant event must contain:

- `event_id`
- `event_name`
- `event_schema_version`
- `user_id`
- `app_session_id`
- `moment_id` when applicable
- `proof_cohort_id` when enrolled
- `experiment_config_id` when enrolled
- `metric_contract_version`
- `client_occurred_at`
- `server_received_at`
- `client_version`
- `payload`

`event_id` is unique and idempotent. Server time is authoritative for metric windows.

## 2. Minimum event dictionary

### Entry / Moment

- `app_entry`
- `moment_started`
- `context_question_shown`
- `context_answered`
- `context_snapshot_created`
- `context_resolved`
- `recommendation_requested`

### Recommendation

- `recommendation_impression`
- `recommendation_accepted`
- `recommendation_skipped`
- `recommendation_no_match`
- `fallback_entered`

### Fit / Scope

- `fit_receipt_shown`
- `context_corrected`
- `scope_expanded`
- `fallback_keep_baseline`

### Execution

- `external_open`
- `action_started`
- `execution_completed`
- `execution_aborted`

### Outcome

- `outcome_prompt_shown`
- `outcome_recorded`
- `outcome_missing`

### Discovery

- `incremental_discovery_prompt_shown`
- `incremental_discovery_answered`

### Return

- `self_moment_qualified`

### Diagnostic only

- `skip_reason_prompt_shown`
- `skip_reason_recorded`
- `context_revalidation_prompt_shown`
- `context_revalidated`

Do not define Calibration-1 events for system Skip Repair, system relaxation, or per-fact TTL.

## 3. Event/state transaction rule

Proof-critical state and event must commit atomically. Examples:

- Execution moves to STARTED and `action_started` is appended in the same transaction.
- Outcome moves to RECORDED and `outcome_recorded` is appended in the same transaction.

A retry with the same event/idempotency key returns the prior result and never duplicates the event or transition.

## 4. SELF_MOMENT

Server-side rule for P0:

```text
explicit new Moment
AND entry_origin = DIRECT
AND local_date > day0_local_date
AND local_date <= day0_local_date + 14
```

Same local calendar day does not count as D14 return.

Never qualify:

- EXTERNAL_SHARE
- NOTIFICATION
- CAMPAIGN
- OTHER_DEEPLINK
- UNKNOWN

## 5. Primary measurement spine

The primary unit is unique Qualifying User and that user’s **First Qualifying Moment**.

### GAL

Numerator: Qualifying users whose First Qualifying Moment reaches:

`Accept → Action Started → Complete → GOOD`

Denominator: all Qualifying users in the cohort, excluding only documented technical Measurement Invalid cases.

Gate: **≥15%**.

### D14 Self-Initiated Return

Numerator: Qualifying users with ≥1 qualified SELF_MOMENT during local day 1–14.

Denominator: all Qualifying users in the cohort, excluding only technical Measurement Invalid cases.

Gate: **≥30%**.

### Positive Outcome

Numerator: GOOD first-qualifying completed executions.

Denominator: RECORDED outcomes for first-qualifying completed executions.

Gate: **≥60%**.

### Outcome Capture — measurement quality

`RECORDED first-qualifying completed executions / all first-qualifying completed executions`

Gate: **≥70%** measurement quality.

### Incremental Discovery

`LIKELY_NO / answered`, diagnostic only.

## 6. Failures stay in denominator

Do not exclude because of:

- No Match
- Skip
- BAD outcome
- no action
- Baseline Keep
- user scope expansion

Only technical measurement invalidity can be excluded. Every exclusion must be append-only with reason and reviewer/source.

## 7. Diagnostics added by v2.4.1

- Prompt Burden
- Context Correction Rate
- Situational Mismatch Rate
- No Match Rate
- Scope Expansion Use Rate
- Scope Expansion Yield
- Baseline Keep Rate
- Stale Moment Incident
- Direct GAL Component
- Expanded GAL Component

`Direct/Expanded GAL Component` never changes the Primary GAL definition. They explain reliance on scope expansion.
