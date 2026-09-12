# Seed Core RC1 → v2.4.1 Migration Contract

## 1. Existing asset to preserve

Existing RC1 design audit established:

- 10 Bootstrap Archetypes
- 40 Candidates
- 36 CORE-eligible pending Human Review
- 4 PARKED: `SC-005`, `SC-015`, `SC-033`, `SC-037`
- 34 canonical experience roots total / 30 CORE roots
- no exact/near duplicate rejects in the audit
- Dynamic Access dependency removed from CORE
- initial release still requires 100% Human Review

Do not re-author all 40 simply because the Context Kernel changed.

## 2. Required v2.4.1 metadata migration

For each CORE candidate, human/operator audit must fill or confirm:

- `trajectory_compatibility[]`
- `required_detour_scope`
- `need_conflicts[]`
- `soft_context_requirements`
- `expected_duration_minutes`
- `effort_level`
- `cost_bucket`
- `indoor_outdoor`
- `weather_dependency`
- `mobility_requirement`
- `place_dependency`
- `required_resources[]`
- `dynamic_fact_requirements[]`
- `semantic_cluster`
- `discovery_quality`

Do not invent a field value from title alone. If a candidate body/evidence is unavailable, mark it `REVIEW_REQUIRED` rather than guess.

## 3. Situation-sensitive coverage gate

Before Calibration-1, Seed should include enough candidates that the new kernel is actually testable:

- at least 4 of the 5 primary Moment Mode mappings must cause meaningful eligibility/bucket differences somewhere in the Core;
- target ~6–10 situation-sensitive resolutions within the 36–48 range, but count is diagnostic, not a hard Product gate;
- synthetic tests must include at least one `MEAL_PENDING` conflict case and one `REST_NEEDED` conflict case;
- do not introduce broad real-time store/inventory/price dependencies merely to satisfy situationalization.

## 4. Release gate

Release only when all are true:

```text
Human GO >= 30
AND every Bootstrap Archetype CORE >= 3
AND every Archetype Semantic Cluster >= 3
AND Hard Safety/Privacy Incident = 0
AND unresolved REVIEW = 0
AND Weighted Bootstrap Coverage >= 80%
AND v2.4.1 situation metadata complete for all released members
AND situation-sensitive synthetic coverage passes
AND content_hash matches
```

If Human Review causes one archetype to fall below readiness, gap-fill only that archetype. Do not add unrelated cards just to return to 36.

## 5. Immutable release

A released `core_pool_version` has immutable membership and immutable content versions. Changes require a new release ID and new experiment config when material.

## 6. Manifest template

See `seed/manifest-template.json` and `seed/resolution-template.json`.
