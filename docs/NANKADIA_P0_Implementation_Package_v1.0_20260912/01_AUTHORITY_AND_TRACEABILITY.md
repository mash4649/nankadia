# Authority and Traceability

## 1. Why this package exists

The NANKADIA design history contains several increasingly detailed artifacts. Many are still useful, but some implementation policies were superseded by the v2.4.1 complexity closure. This file prevents old rules from leaking back into the codebase.

## 2. Source reconciliation

| Source | Role now | Action in this package |
|---|---|---|
| Source of Truth v2.4.1 (2026-09-12) | **CURRENT CANONICAL** | Governs Product/P0 kernel and overrides conflicts |
| P0 Implementation SoT v1.0 (2026-09-09) | Detailed implementation precedent | Reuse identity, events, DB boundaries, measurement, ops; replace old Context/Ranking |
| P0 Slice A Implementation SoT v1.0 (2026-09-07) | Detailed Slice A precedent | Reuse runtime objects, transaction/idempotency, tests, seed integrity; replace old snapshot/policy details |
| Consumer Product Proof Measurement Contract v1 (2026-09-05) | Measurement semantics | Inherit where not superseded; concrete implementation binding from 2026-09-09 used when more specific |
| Seed Core RC1 v1.1 (2026-09-07) | Existing audited candidate set | Preserve 36 CORE-candidate + 4 PARKED state; require v2.4.1 context metadata audit before release |
| Supply Curation Harness v1 | Offline quality OS | Preserve generation/audit/serving separation; runtime never calls Harness |
| v2.1 and earlier | Historical architecture basis | Use only where v2.4.1/current package does not replace it |

## 3. Explicit supersessions

### 3.1 Context acquisition

**Superseded:** fixed Available Time question + conditional Mobility question as the primary Context Policy.  
**Current:** 3-axis kernel with `trajectory_type`, `detour_budget`, `immediate_need`; Moment Mode question resolves trajectory + detour together.

### 3.2 Snapshot ownership

**Superseded:** one immutable Context Snapshot per Moment.  
**Current:** each Recommendation Decision references an immutable snapshot; correction/scope expansion inside the same Moment creates a new snapshot.

### 3.3 Ranking

**Superseded:** fixed weighted/feature ranking such as time-fit + exposure penalties.  
**Current:** `Hard Filter → Situation Fit Bucket A/B → Discovery Tie-break`; no weighted utility score.

### 3.4 Fallback

**Superseded:** system may broadly “change conditions” after No Match.  
**Current:** low-quality candidate is never forced; user explicitly chooses one-step `detour_budget` expansion or Baseline Keep. No system-initiated relaxation.

### 3.5 Deferred behavior

Old designs discussed Skip Repair, system relaxation and per-fact TTL. In Calibration-1 these are not merely disabled. They **must not exist as runtime code/state/event**.

## 4. O-01…O-12 closure map

| Old open | Closure in this package |
|---|---|
| O-01 Database DDL / Index / Constraint | `database/0001_schema.sql` |
| O-02 Event JSON / TS types | `contracts/events.ts`, `schemas/event-envelope.schema.json` |
| O-03 Auth / Stable User ID | Product identity requirements in SoT; provider binding remains implementation choice |
| O-04 API / RPC boundary | `contracts/api.ts`; transport is replaceable |
| O-05 Seed import format/script contract | `seed/` templates + release contract |
| O-06 Context concrete type | `contracts/domain.ts`, `schemas/context-snapshot.schema.json` |
| O-07 Recommendation algorithm | `03_CONTEXT_AND_RECOMMENDATION_POLICY.md` |
| O-08 Outcome canonical values | `contracts/domain.ts`, event/measurement contract |
| O-09 SELF_MOMENT code contract | `04_EVENT_AND_MEASUREMENT_CONTRACT.md` |
| O-10 Calibration dashboard / SQL | `ops/calibration_dashboard.sql` |
| O-11 Cohort/config runbook | `05_PROOF_COHORT_RUNBOOK.md`, `ops/proof_runbook.md` |
| O-12 Bootstrap/Seed concrete audit | `06_SEED_CORE_MIGRATION_CONTRACT.md` + existing RC1, with metadata migration gate |

## 5. Rules for future implementers

- Do not revive a superseded rule because it appears in an older document.
- Do not “generalize” the 3-axis kernel during Slice A.
- Do not convert PROVISIONAL values into canonical constants without versioning.
- Do not add a new event/state for a Deferred feature until its independent design change is approved.
- Store reason codes/traces, not LLM chain-of-thought.
