# Security, Privacy, Reliability Guardrails

## 1. Boundaries

- Server validates ownership, state transition, config version, event shape, object references and serving eligibility.
- Client cannot directly establish proof-critical state.
- Secrets stay server-side.
- Raw PII/private reflection/exact GPS are not analytics payloads.
- External inputs are schema validated; user-generated HTML is never rendered raw.

## 2. Data minimization

Slice A should not collect exact location simply because trajectory is useful. `trajectory_type` is qualitative. If coarse location/weather is later used, it must have a separate permission and necessity rationale.

## 3. Event integrity

- append-only event log
- unique event ID/idempotency
- corrections/exclusions as new records
- server timestamp authoritative
- proof-critical state + event same transaction

## 4. Immutability

- ACTIVE experiment config cannot mutate
- RELEASED core pool membership cannot mutate
- Context Snapshot cannot mutate after referenced by a Recommendation Decision

## 5. Failure isolation

| Failure | Degraded behavior |
|---|---|
| Recommendation service error | retry/error UX; never runtime-generate unreviewed card |
| Event submission retry | same event ID; prior result returned |
| irrecoverable technical measurement failure | mark Measurement Invalid with reason |
| Offline Harness down | existing frozen Core continues |
| Dynamic fact stale | only affected Resolution excluded |
| Critical supply issue | target Resolution paused; service not globally stopped |

## 6. Logging

Trace by IDs (`request_id`, `user_id`, `moment_id`, `context_snapshot_id`, `recommendation_decision_id`, `proof_cohort_id`, `experiment_config_id`) without logging tokens, raw private context, exact coordinates or chain-of-thought.

## 7. Auth technology

The Product contract requires stable opaque identity and authorization, not a particular login UX/provider. If Supabase Anonymous Auth is retained from the prior technical binding, treat it as an implementation binding that can be replaced without changing domain contracts.
