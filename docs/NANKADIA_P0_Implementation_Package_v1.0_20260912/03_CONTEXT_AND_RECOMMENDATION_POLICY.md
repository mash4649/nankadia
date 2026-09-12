# Context and Recommendation Policy — Calibration-1

## 1. Enums

### trajectory_type

`RETURNING_HOME | EN_ROUTE_FIXED | STAYING | WAITING | OPEN_ENDED | UNKNOWN`

### detour_budget

`NONE | SMALL | OPEN`

This is an ordinal scope only. **Exact minute/distance boundaries are PROVISIONAL** and must live in the versioned context policy, not the enum.

### immediate_need

`NONE | MEAL_PENDING | REST_NEEDED | UNKNOWN`

This is a closed, single-value allowlist for Calibration-1. Do not add new hard needs without repeated observed mismatch + new policy version + new cohort.

## 2. Moment Mode Resolver

Only show if `trajectory_type` or `detour_budget` is material and unresolved.

Suggested semantic mapping (copy is PROVISIONAL):

| User answer intent | trajectory_type | detour_budget |
|---|---|---|
| 帰り道で少しだけ | RETURNING_HOME | SMALL |
| 予定を崩せない移動中 | EN_ROUTE_FIXED | NONE |
| 今いる場所で少し時間がある | WAITING | SMALL |
| 家・今いる場所で過ごしたい | STAYING | NONE |
| 特に予定なし | OPEN_ENDED | OPEN |

Do not persist a `moment_mode` domain object. Persist only resolved Context fields plus source/confidence.

## 3. Context question algorithm

```text
required = missing required safety/legal/executability info?
if required:
  ask required question (outside normal budget)

if no non-required question used:
  if trajectory or detour is material and unresolved:
    ask Moment Mode once
  elif top candidate validity materially depends on immediate_need:
    ask Immediate Need once

stop asking non-required questions
```

## 4. Context source/confidence

Each kernel field stores:

- `value`
- `source`: `USER_EXPLICIT | SYSTEM_INFERRED | DEFAULT_SAFE | UNKNOWN`
- `confidence`: optional 0..1 diagnostic only

Confidence must not become a hidden scoring axis in Calibration-1.

## 5. Unknown handling

- Never interpret `UNKNOWN` as `OPEN`.
- A candidate may be served under UNKNOWN only when it is safe for that unknown state.
- Unknown passive auxiliary facts never create a mismatch by themselves.
- Do not ask extra questions just to fill an auxiliary value.

## 6. Candidate situation metadata

Minimum fields per Resolution:

```text
trajectory_compatibility[]    # enum values or ANY
max_detour_budget             # NONE | SMALL | OPEN (scope needed by candidate)
need_conflicts[]              # immediate_need values that invalidate this candidate
soft_context_requirements     # optional passive facts for A/B bucket
expected_duration_minutes?    # coarse/verified; not Context Kernel
cost_bucket?                  # passive metadata, not pre-card question in Calibration-1
indoor_outdoor?
weather_dependency?
mobility_requirement?
required_resources[]
dynamic_fact_requirements[]
semantic_cluster
discovery_quality
```

Name note: `max_detour_budget` here means “minimum scope the user must allow to execute this candidate” in code. Prefer the clearer TypeScript name `required_detour_scope`.

## 7. Hard Filter

A Resolution is ineligible if any known hard rule fails:

1. not a member of the exact frozen Core release bound to config;
2. serving state is not CORE or is PAUSED/DEPRECATED;
3. hard safety/legal rule fails;
4. required dynamic fact is UNKNOWN/STALE;
5. `trajectory_type` is known and incompatible;
6. required detour scope exceeds current `detour_budget`;
7. current `immediate_need` is in `need_conflicts`;
8. required resource is known absent;
9. it has already been shown in the current Moment and policy forbids repeat.

Persistent preference must never rescue a hard-failed candidate.

## 8. Situation Fit Bucket

Only hard-pass candidates reach this stage.

- `A_DIRECT_FIT`: zero known soft mismatches.
- `B_ACCEPTABLE`: one or more known soft mismatches.

If A has ≥1 candidate, B is not considered. If A=0, B may be considered.

Rules:

- Unknown auxiliary fact = no mismatch.
- No continuous situation score.
- No weighted sum.
- Bucket assignment reason codes must be traceable.

## 9. Discovery Tie-break

Within the selected bucket only, select one using deterministic rules. Allowed signals:

- discovery quality
- explicit novel signal already present in the Moment
- confirmed persistent preference as tie-break only
- exposure de-duplication
- deterministic stable hash as final tie

Disallowed:

- revenue/sponsor/affiliate value
- unversioned online learning
- runtime LLM judgment
- hidden composite utility weights

If the tie-break policy changes materially, create a new `ranking_policy_version` and new cohort.

## 10. Recommendation trace

Persist at least:

- `recommendation_decision_id`
- `moment_id`
- `context_snapshot_id`
- `experiment_config_id`
- `core_pool_version`
- `ranking_policy_version`
- `selected_resolution_id?`
- `eligible_candidate_count`
- `selected_bucket?`
- `excluded_reason_counts`
- `candidate_trace` (reason codes only; no chain-of-thought)

## 11. Fit Receipt

Shown data must be derived from actually resolved or verified facts.

Examples:

- `帰り道`
- `寄り道小さめ`
- `+7分` only if a valid route/time computation exists; otherwise use a coarse label.

Correction flow:

```text
Fit Receipt correction
→ create new immutable context_snapshot
→ create new recommendation_decision
→ old decision remains tied to old snapshot
```

## 12. No Match and scope expansion

No Match = eligible candidates = 0 after current snapshot/policy.

Allowed user choice:

- Keep Baseline / End
- Explicitly “少し広げる”

Expansion:

- NONE→SMALL
- SMALL→OPEN
- OPEN→no further expansion

Each expansion creates a new snapshot and new recommendation decision. It must emit `scope_expanded`.

System must not propose spending more, exerting more effort, changing immediate need, or weakening safety/accessibility/legal constraints.

### Storage convention for `ANY`

The portable PostgreSQL schema stores `trajectory_compatibility = []` to mean `ANY`, because `ANY` is not a user Context enum value. Seed JSON may use the human-readable token `ANY`; the importer normalizes `['ANY']` to an empty DB array. Mixed `ANY + specific values` is invalid.

## 13. Calibration-1 soft auxiliary allowlist

To stop `auxiliary_facts` from becoming hidden Context axes, **Situation Fit may read only these soft facts in Calibration-1**:

- `daypart` — derived from trusted time: `MORNING | DAY | EVENING | NIGHT`;
- `weatherState` — `DRY | RAIN | SNOW | EXTREME | UNKNOWN`, only when coarse-area weather is already legitimately available.

Candidate soft requirements may only express `allowedDayparts[]` and `allowedWeatherStates[]` in Calibration-1. Missing/UNKNOWN auxiliary facts produce **zero soft mismatch** and never trigger a question. Adding another serving-relevant auxiliary key requires a new `ranking_policy_version`/`context_policy_version` as appropriate and a fresh cohort.

`contracts/policy.ts` is the executable reference for detour ordering, trajectory/need compatibility, hard exclusion reason codes, and A/B bucket classification.
