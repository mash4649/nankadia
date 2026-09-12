# NANKADIA P0 Implementation Package v1.0

**Date:** 2026-09-12  
**Canonical parent:** `NANKADIA_総合事業・プロダクト設計正本_v2.4.1_20260912.docx`  
**Scope:** P0 / Slice A / Consumer Product Proof / Calibration-1  
**Status:** Implementation package — detailed binding for the v2.4.1 simplified runtime kernel

## 1. Purpose

This package converts the current NANKADIA architecture into an implementation-ready Slice A contract. It consolidates the previously distributed implementation bindings, event/measurement rules, seed release rules, and calibration operations, while replacing superseded Context/Recommendation logic with the v2.4.1 kernel.

The package is deliberately **not** a feature backlog. If behavior is not defined here or in the canonical parent, implementation must not silently invent a new Product rule.

## 2. Authority order

1. `source/NANKADIA_総合事業・プロダクト設計正本_v2.4.1_20260912.docx`
2. `02_SLICE_A_IMPLEMENTATION_SOT_v2.0.md`
3. Machine contracts under `database/`, `contracts/`, `schemas/`, `ops/`, `tests/`, `seed/`
4. `01_AUTHORITY_AND_TRACEABILITY.md` for migration/history only

If a machine contract conflicts with #1 or #2, fix the machine contract before implementation.

## 3. Slice A runtime in one diagram

```text
Explicit new Moment
  ↓
Resolve 3-axis Context Kernel
  trajectory_type / detour_budget / immediate_need
  ↓
At most 1 non-required system question
  ↓
Immutable Context Snapshot
  ↓
HARD FILTER
  ↓
SITUATION FIT BUCKET (A or B; no weighted score)
  ↓
DISCOVERY TIE-BREAK
  ↓
1 Resolution + Fit Receipt
  ↓
Accept / Skip / No Match
  ↓
[No Match: Baseline Keep OR user-initiated one-step scope expansion]
  ↓
Execution: ACCEPTED → STARTED → COMPLETED | ABORTED
  ↓
Outcome: GOOD / NEUTRAL / BAD / MISSING
  ↓
Later DIRECT explicit new Moment → SELF_MOMENT qualification
```

## 4. What is implemented in Calibration-1

- stable user identity sufficient for D14 observation
- proof cohort + immutable experiment config
- explicit Moment lifecycle
- v2.4.1 Context Kernel and Moment Mode Resolver
- immutable Context Snapshots
- deterministic 3-stage serving from frozen Core
- Fit Receipt and explicit correction
- one-card UX, Skip, No Match, user-initiated scope expansion, Baseline Keep
- Accept / External Open / Action Started / Complete / Abort separation
- Outcome and Incremental Discovery
- SELF_MOMENT attribution
- append-only proof events + idempotency
- Seed Core import/release integrity
- minimal SQL dashboard and synthetic measurement audit

## 5. Explicitly not implemented in Calibration-1

Do not add dead code or feature flags for:

- system-triggered Skip Repair
- system-initiated constraint relaxation
- per-fact TTL/drift state machine
- Discovery Appetite question
- runtime LLM / runtime generation / runtime Supply Harness
- UGC/Public Share/Growth Loop as Slice A dependency
- Sponsored/B2B/Creator Economy

## 6. Files

| Path | Purpose |
|---|---|
| `01_AUTHORITY_AND_TRACEABILITY.md` | old/new source reconciliation and supersession map |
| `02_SLICE_A_IMPLEMENTATION_SOT_v2.0.md` | detailed runtime/measurement implementation SoT |
| `03_CONTEXT_AND_RECOMMENDATION_POLICY.md` | exact context resolver + serving algorithm |
| `04_EVENT_AND_MEASUREMENT_CONTRACT.md` | event semantics + metric denominator rules |
| `05_PROOF_COHORT_RUNBOOK.md` | config/cohort lifecycle and material change operation |
| `06_SEED_CORE_MIGRATION_CONTRACT.md` | migrate RC1 to v2.4.1 metadata without inventing content |
| `07_CALIBRATION_RUNBOOK.md` | 10–15 user calibration operating procedure |
| `08_SECURITY_RELIABILITY_GUARDRAILS.md` | trust boundaries and failure isolation |
| `09_DEFERRED_AND_PROVISIONAL_REGISTER.md` | what remains empirical/deferred |
| `10_IMPLEMENTATION_TICKET_MAP.md` | ordered work packages and verification |
| `11_TECHNOLOGY_AND_BOUNDARY_BINDING.md` | required technical properties vs replaceable vendor choices |
| `12_API_COMMAND_CONTRACT.md` | server-authoritative command semantics and transitions |
| `13_PACKAGE_COMPLETENESS_AND_EXTERNAL_GATES.md` | what is closed vs what still requires human/runtime evidence |
| `database/0001_schema.sql` | portable PostgreSQL schema + invariants |
| `database/0002_policy_helpers.sql` | helper functions/checks; no vendor-specific auth binding |
| `contracts/*.ts` | canonical TypeScript contracts |
| `schemas/*.schema.json` | machine-validatable JSON schemas |
| `ops/calibration_dashboard.sql` | minimal diagnostic SQL |
| `ops/proof_runbook.md` | concise operator commands/checklist |
| `tests/acceptance_matrix.md` | release-blocking behavioral tests |
| `seed/*` | release templates and migration checklist |

## 7. Implementation gate

Slice A is ready for Calibration-1 only when:

1. all `tests/acceptance_matrix.md` **BLOCKING** cases pass;
2. synthetic journey can be rebuilt from events;
3. active config and released pool are immutable;
4. Seed Core has completed required human review and v2.4.1 metadata audit;
5. no deferred runtime branch/event/state exists;
6. primary metric SQL and denominator audit reconcile with synthetic fixtures.

## 8. Verification status of this package

Performed in the packaging environment:

- JSON/JSON-Schema files parse successfully.
- TypeScript contracts compile under strict `tsc --noEmit`.
- Deferred event/state identifiers are absent from normative runtime code contracts.
- Weighted-score anti-pattern scan passes for machine contracts.
- Package hashes are generated in `PACKAGE_MANIFEST.sha256`.

Not performed here because a PostgreSQL/Supabase runtime is not installed in this artifact environment:

- executing DDL migrations against PostgreSQL;
- trigger/RLS/RPC smoke tests.

Those are release-blocking implementation-repository checks, not optional QA.
