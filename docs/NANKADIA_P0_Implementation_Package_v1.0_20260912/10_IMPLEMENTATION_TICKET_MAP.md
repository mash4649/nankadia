# Implementation Ticket Map

Goal: small vertical increments, each independently verifiable. Do not mix deferred features into these tickets.

## A1 — Proof foundation

**Build:** app user identity abstraction, experiment_config, proof_cohort, proof_enrollment, immutability.  
**Tests:** config mutation reject; user/cohort uniqueness; ownership.

## A2 — Moment + Context

**Build:** app_session, moment, 3-axis Context Snapshot, Moment Mode Resolver DTO, one-question budget, snapshot creation.  
**Tests:** resolver maps one answer→trajectory+detour; no second non-required question; snapshot immutable.

## A3 — Seed + Serving

**Build:** experiences/resolutions/core release/import contract, hard filter, A/B bucket, discovery tie-break, recommendation trace, impression.  
**Tests:** A excludes B when present; weighted score absent; unknown auxiliary doesn’t mismatch; no runtime LLM/harness.

## A4 — Fit Receipt + correction

**Build:** safe receipt DTO, correction command→new snapshot→new recommendation.  
**Tests:** old decision still references old snapshot; unsupported precision not emitted.

## A5 — Skip / No Match / Scope

**Build:** skip, finite-card behavior, No Match, Baseline Keep, explicit one-step detour expansion.  
**Tests:** skip not outcome; no silent widening; no system relaxation; one-step expansion only.

## A6 — Execution

**Build:** accept, external_open, start, complete, abort.  
**Tests:** invalid transitions; external_open never start; idempotent retry.

## A7 — Outcome + Discovery

**Build:** GOOD/NEUTRAL/BAD/MISSING + incremental discovery.  
**Tests:** complete != good; missing does not block Moment; discovery diagnostic only.

## A8 — Return

**Build:** app_entry origin + server SELF_MOMENT qualifier.  
**Tests:** DIRECT day1–14 only; same-day/external origins rejected.

## A9 — Measurement spine

**Build:** append-only event log, correction/exclusion, metric views.  
**Tests:** synthetic denominators, retry dedupe, invalid exclusion reason required.

## A10 — Seed migration/release

**Build:** v2.4.1 metadata completion, human review ledger, content hash, atomic release.  
**Tests:** unresolved review blocks release; membership mutation blocked; situation-sensitive fixture coverage.

## A11 — Calibration ops

**Build:** SQL/internal inspection for journey, no-match, exclusions, primary/diagnostic metrics.  
**Tests:** dashboard reconciles synthetic fixture.

## A12 — Slice A release gate

Run all blocking tests and manual checks. Verify deferred branches are absent by code search/event registry/state enum inspection.
