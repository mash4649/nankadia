# Slice A Acceptance Matrix

All **BLOCKING** cases must pass before Calibration-1.

| ID | Severity | Case | Pass condition |
|---|---|---|---|
| A-01 | BLOCKING | Happy path | Moment→snapshot→decision→impression→accept→start→complete→outcome is transactionally consistent |
| A-02 | BLOCKING | Moment Mode Resolver | one answer resolves trajectory+detour; no persistent moment_mode object |
| A-03 | BLOCKING | Question budget | max 1 non-required pre-card question; no Need question after Moment Mode |
| A-04 | BLOCKING | Snapshot immutability | correction creates v2; prior decision remains on v1 |
| A-05 | BLOCKING | Hard filter trajectory | incompatible trajectory is excluded with reason |
| A-06 | BLOCKING | Hard filter detour | required scope above budget is excluded |
| A-07 | BLOCKING | Immediate Need | conflict excludes; no multi-hard-need input accepted |
| A-08 | BLOCKING | Unknown auxiliary | unknown passive auxiliary does not create mismatch/question |
| A-09 | BLOCKING | Situation bucket | if any A exists, B is not served |
| A-10 | BLOCKING | No weighted score | recommendation path has no weighted/continuous situation utility |
| A-11 | BLOCKING | Deterministic tie | same frozen inputs/policy resolve deterministically at final tie |
| A-12 | BLOCKING | Fit Receipt truthfulness | no unsupported exact time/distance/location shown |
| A-13 | BLOCKING | Context correction | new snapshot + new decision; old history preserved |
| A-14 | BLOCKING | Skip isolation | Skip is not Outcome/persistent dislike; next eligible candidate may show |
| A-15 | BLOCKING | No Match | zero eligible returns explicit No Match, not weak generated card |
| A-16 | BLOCKING | Baseline Keep | user can end/keep baseline; event recorded |
| A-17 | BLOCKING | Scope expansion | explicit only, adjacent NONE→SMALL→OPEN, new snapshot |
| A-18 | BLOCKING | No silent widening | system never expands scope without user action |
| A-19 | BLOCKING | Accept boundary | accept does not create STARTED |
| A-20 | BLOCKING | External open boundary | external_open alone never creates STARTED |
| A-21 | BLOCKING | Invalid execution transition | ACCEPTED→COMPLETED rejected |
| A-22 | BLOCKING | Outcome Missing | next Moment remains available |
| A-23 | BLOCKING | Complete vs GOOD | Complete alone does not count Positive Outcome |
| A-24 | BLOCKING | SELF_MOMENT direct | DIRECT explicit day1–14 qualifies when other rules pass |
| A-25 | BLOCKING | Same-day return | does not count toward D14 |
| A-26 | BLOCKING | External origin | share/notification/campaign/deeplink/unknown never qualifies |
| A-27 | BLOCKING | Event retry | same event_id results in one event and one state transition |
| A-28 | BLOCKING | Event append-only | event UPDATE/DELETE rejected |
| A-29 | BLOCKING | State/event transaction | proof state cannot commit without matching event |
| A-30 | BLOCKING | ACTIVE config immutable | policy/core fields cannot mutate; retirement only |
| A-31 | BLOCKING | RELEASED pool immutable | membership/content-version change rejected |
| A-32 | BLOCKING | Runtime dependency | no Heavy LLM/Harness call on serving path |
| A-33 | BLOCKING | Deferred code absence | no runtime branch/state/event for system repair/relaxation/per-fact TTL |
| A-34 | BLOCKING | Seed Human Review | unresolved human review blocks release |
| A-35 | BLOCKING | Seed situation metadata | all released members satisfy v2.4.1 schema |
| A-36 | BLOCKING | Situation-sensitive fixture | at least 4/5 Moment Modes + meal/rest synthetic cases exercise differences |
| A-37 | BLOCKING | Metric denominator | Skip/No Match/BAD/no-action not excluded |
| A-38 | BLOCKING | Measurement invalid | only technical case with append-only reason can exclude |
| A-39 | BLOCKING | GAL synthetic | fixture SQL exactly matches expected user-level GAL |
| A-40 | BLOCKING | D14 synthetic | fixture SELF_MOMENT qualification matches expected day/origin rules |
| A-41 | BLOCKING | Outcome quality | Outcome Capture computed and gateable independently |
| A-42 | DIAGNOSTIC | Direct vs Expanded GAL | diagnostic split sums consistently without redefining Primary GAL |
| A-43 | DIAGNOSTIC | Prompt burden | question count can be computed per Moment |
| A-44 | DIAGNOSTIC | Correction rate | context correction can be computed |
| A-45 | DIAGNOSTIC | No Match / scope | rates and yield can be computed |
