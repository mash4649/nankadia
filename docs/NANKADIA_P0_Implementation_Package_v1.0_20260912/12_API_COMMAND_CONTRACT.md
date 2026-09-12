# Slice A Server Command Contract

All commands are server-authoritative and idempotent. The authenticated caller is derived at the server boundary (never accepted as an input) and must own every referenced resource. Transport may be REST/RPC/function call; semantics are fixed.

## `start_moment`

Input: `app_session_id`, idempotency key.  
Precondition: caller owns session.  
Mutation: create explicit `moment`.  
Event: `moment_started`.

## `resolve_moment_mode`

Input: `moment_id`, one Moment Mode answer, idempotency key.\
Precondition: caller owns Moment; no prior non-required question violation.  
Mutation: create new Context Snapshot resolving `trajectory_type + detour_budget`, preserve/derive need.  
Events: `context_answered`, `context_snapshot_created`, `context_resolved` when enough context exists.

## `resolve_immediate_need`

Input: `moment_id`, one allowlisted `immediate_need`, idempotency key.\
Precondition: Moment Mode non-required question was not already used in this Moment unless this is a required correction path.  
Mutation: create new Context Snapshot.  
Events: `context_answered`, `context_snapshot_created`, `context_resolved`.

## `correct_context`

Input: `moment_id`, base snapshot, allowlisted patch, idempotency key.\
Precondition: base snapshot belongs to Moment; patch does not add new axes.  
Mutation: create a new immutable Context Snapshot.  
Events: `context_corrected`, `context_snapshot_created`.

## `request_recommendation`

Input: `moment_id`, `context_snapshot_id`, idempotency key.\
Precondition: exact active config/cohort/core release are resolved server-side.  
Mutation: create immutable `recommendation_decision`; if matched, create impression when rendered/acknowledged according to UI boundary.  
Events: `recommendation_requested`, then `recommendation_no_match` or `recommendation_impression`.

Recommendation command must persist trace reason codes sufficient to reproduce exclusion/bucket choice. It must not persist hidden chain-of-thought.

## `skip_recommendation`

Input: `recommendation_impression_id`, idempotency key.\
Precondition: visible unresolved impression owned by user.  
Mutation: mark impression skipped; does not mutate profile/Outcome.  
Event: `recommendation_skipped`.

## `accept_recommendation`

Input: `recommendation_impression_id`, idempotency key.\
Precondition: valid current impression.  
Mutation: create `execution` in `ACCEPTED`.  
Event: `recommendation_accepted`.

## `record_external_open`

Input: `execution_id`, `access_route_id`, idempotency key.\
Mutation: no Execution state promotion.  
Event: `external_open`.

## `start_execution`

Input: `execution_id`, idempotency key.\
Precondition: state = ACCEPTED.  
Mutation: ACCEPTED→STARTED.  
Event: `action_started` in same transaction.

## `complete_execution`

Input: `execution_id`, idempotency key.\
Precondition: state = STARTED.  
Mutation: STARTED→COMPLETED.  
Event: `execution_completed`.

## `abort_execution`

Input: `execution_id`, idempotency key.\
Precondition: state = STARTED.  
Mutation: STARTED→ABORTED.  
Event: `execution_aborted`.

## `record_outcome`

Input: `execution_id`, GOOD/NEUTRAL/BAD value, idempotency key.\
Precondition: execution = COMPLETED.  
Mutation: Outcome→RECORDED with GOOD/NEUTRAL/BAD.  
Event: `outcome_recorded`.

Missingness is represented explicitly by a server/UX policy event/state, but it never blocks a later Moment.

## `record_incremental_discovery`

Input: `execution_id`, one allowlisted answer, idempotency key.\
Precondition: completed execution; prompt sampled/shown according to policy.  
Mutation: one answer record.  
Event: `incremental_discovery_answered`.

## `expand_scope`

Input: current snapshot ID, idempotency key.\
Precondition: explicit user action, current detour ≠ OPEN.  
Mutation: new snapshot with adjacent `detour_budget` only; all other context preserved unless separately corrected.  
Event: `scope_expanded` + `context_snapshot_created`.  
Then user may request a new recommendation.

## `keep_baseline`

Input: `moment_id`, idempotency key.\
Mutation: no fabricated outcome/action. Moment may end.  
Event: `fallback_keep_baseline`.
