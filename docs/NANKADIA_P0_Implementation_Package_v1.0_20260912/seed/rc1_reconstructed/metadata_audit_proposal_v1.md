# RC1 CORE metadata audit proposal v1

## Status

This is an operator review packet, not a release payload. It does not change `core_candidate_review_v241.csv`, Seed content, or `REVIEW_REQUIRED` status.

Basis:

- user-approved content changes through 2026-09-13;
- approved qualitative detour policy in ADR-0003;
- original RC1 candidate bodies and explicit Discovery values (`D2`–`D4`).

No field is inferred from a title alone. `PROPOSED` rows require batch human confirmation before becoming a Seed payload. `NEEDS_*` rows have missing material content and remain unresolved.

## Shared proposal rules

| Field | Proposal |
|---|---|
| `cost_bucket` | `FREE` for all candidates; no purchase is required. |
| `soft_context_requirements` | `{}` for all candidates; Calibration-1 adds no auxiliary question or passive-fact dependency. |
| `dynamic_fact_requirements` | `[]` for all candidates; no store, inventory, schedule, price, or live-weather dependency. |
| `effort_level` | `LOW` or `MEDIUM` only. |
| `indoor_outdoor` | `INDOOR`, `OUTDOOR`, or `FLEXIBLE`. |
| `weather_dependency` | `NONE` or `WEATHER_SENSITIVE`. |
| `mobility_requirement` | `NONE`, `LIGHT_MOVEMENT`, or `WALKING`. |
| `place_dependency` | `CURRENT_PLACE`, `HOME_OR_CURRENT_PLACE`, `SAFE_LOCAL_AREA`, `KNOWN_SAFE_ROUTE`, or `NONE`. |
| `situation_sensitive` | `YES` when trajectory, detour, or immediate-need rules can alter eligibility; otherwise `NO`. |

`required_resources` lists only genuinely required inputs. Optional camera or note-taking is not a hard requirement.

## Proposed matrix

### BA-01 — state shift (`semantic_cluster=state_shift`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-001 | ANY / NONE / [] | 5 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | [] | 3 | PROPOSED |
| SC-002 | ANY / NONE / [] | 3 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | [] | 3 | PROPOSED |
| SC-003 | STAYING, WAITING / NONE / [] | 10 / LOW | INDOOR / NONE / SAFE_LOCAL_AREA | safe_seat | 2 | PROPOSED |
| SC-004 | ANY / NONE / [] | 3 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | nearby_object | 3 | PROPOSED |

### BA-02 — familiar reframing (`semantic_cluster=familiar_reframing`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-006 | STAYING / NONE / [] | 5 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | storage_area | 3 | PROPOSED |
| SC-007 | ANY / NONE / [] | 4 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | music_playback | 2 | PROPOSED |
| SC-008 | STAYING / NONE / [] | 5 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | existing_drink | 2 | PROPOSED |

### BA-03 — hands-on creation (`semantic_cluster=hands_on_creation`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-009 | STAYING / NONE / [] | 10 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | paper, pen | 3 | PROPOSED |
| SC-010 | STAYING / NONE / [] | 10 / MEDIUM | INDOOR / NONE / HOME_OR_CURRENT_PLACE | three_nearby_objects | 4 | PROPOSED |
| SC-011 | STAYING / NONE / [] | 5 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | three_nearby_objects | 3 | PROPOSED |
| SC-012 | STAYING / NONE / [] | 3 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | paper, pen, nearby_object | 3 | PROPOSED |

### BA-04 — mental play (`semantic_cluster=mental_play`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-013 | TBD / TBD / TBD | 10 / TBD | TBD / TBD / TBD | TBD | 4 | NEEDS_CARD_CONTENT |
| SC-014 | STAYING / NONE / [] | 10 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | past_photo_access | 3 | PROPOSED |
| SC-016 | ANY / NONE / [] | 5 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | [] | 3 | PROPOSED |

SC-013 cannot be classified until the six card-supplied missions are written. The category labels alone (see, hear, touch, move, draw, photograph) are insufficient to determine resource, safety, trajectory, and conflict rules.

### BA-05 — neighborhood rediscovery (`semantic_cluster=neighborhood_rediscovery`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-017 | RETURNING_HOME, WAITING / SMALL / REST_NEEDED | 15 / MEDIUM | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 3 | PROPOSED |
| SC-018 | RETURNING_HOME, WAITING, OPEN_ENDED / SMALL / REST_NEEDED | 15 / MEDIUM | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 3 | PROPOSED |
| SC-019 | RETURNING_HOME, WAITING, OPEN_ENDED / SMALL / REST_NEEDED | 15 / LOW | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 4 | PROPOSED |
| SC-020 | OPEN_ENDED / OPEN / MEAL_PENDING, REST_NEEDED | 30 / MEDIUM | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 3 | PROPOSED |

All BA-05 rows are `WEATHER_SENSITIVE` and `situation_sensitive=YES`.

### BA-06 — light body activation (`semantic_cluster=light_body_activation`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-021 | ANY / NONE / REST_NEEDED | 10 / MEDIUM | FLEXIBLE / LIGHT_MOVEMENT / CURRENT_PLACE | music_playback | 2 | PROPOSED |
| SC-022 | RETURNING_HOME / SMALL / REST_NEEDED | 10 / MEDIUM | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 3 | PROPOSED |
| SC-023 | ANY / NONE / REST_NEEDED | 5 / MEDIUM | FLEXIBLE / LIGHT_MOVEMENT / CURRENT_PLACE | visible_moving_object | 4 | PROPOSED |
| SC-024 | ANY / NONE / REST_NEEDED | 5 / LOW | FLEXIBLE / LIGHT_MOVEMENT / CURRENT_PLACE | visible_scene | 3 | PROPOSED |

SC-022 is `WEATHER_SENSITIVE`; the other BA-06 rows have `weather_dependency=NONE`. All are `situation_sensitive=YES`.

### BA-07 — sensory shift (`semantic_cluster=sensory_shift`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-025 | STAYING / NONE / [] | 5 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | adjustable_light | 3 | PROPOSED |
| SC-026 | STAYING / NONE / [] | 5 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | three_safe_personal_items | 3 | PROPOSED |
| SC-027 | ANY / NONE / [] | 5 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | partially_occluded_objects | 3 | PROPOSED |
| SC-028 | STAYING / NONE / [] | 10 / MEDIUM | INDOOR / NONE / HOME_OR_CURRENT_PLACE | safe_light_source, nearby_object | 4 | PROPOSED |

All BA-07 rows have `weather_dependency=NONE`; STAYING rows are `situation_sensitive=YES` and SC-027 is `NO`.

### BA-08 — micro skill (`semantic_cluster=micro_skill`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-029 | STAYING / NONE / [] | 10 / MEDIUM | INDOOR / NONE / HOME_OR_CURRENT_PLACE | paper, pen, nearby_object | 3 | PROPOSED |
| SC-030 | ANY / NONE / [] | 10 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | camera | 3 | PROPOSED |
| SC-031 | ANY / NONE / [] | 1 / LOW | FLEXIBLE / NONE / CURRENT_PLACE | [] | 3 | PROPOSED |
| SC-032 | STAYING / NONE / [] | 5 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | mirror, paper, pen | 4 | PROPOSED |

All BA-08 rows have `weather_dependency=NONE`; STAYING rows are `situation_sensitive=YES` and ANY rows are `NO`.

### BA-09 — quiet immersion (`semantic_cluster=quiet_immersion`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-034 | STAYING, WAITING / NONE / [] | 15 / MEDIUM | FLEXIBLE / NONE / HOME_OR_CURRENT_PLACE | paper, pen | 4 | PROPOSED |
| SC-035 | STAYING / NONE / [] | 30 / LOW | INDOOR / NONE / HOME_OR_CURRENT_PLACE | book | 2 | PROPOSED |
| SC-036 | STAYING / NONE / [] | 40 / MEDIUM | INDOOR / NONE / HOME_OR_CURRENT_PLACE | paper, pen | 3 | PROPOSED |

All BA-09 rows have `weather_dependency=NONE` and `situation_sensitive=YES`.

### BA-10 — mini adventure (`semantic_cluster=mini_adventure`)

| ID | trajectory / detour / conflicts | duration / effort | environment / mobility / place | required resources | DQ | status |
|---|---|---|---|---|---:|---|
| SC-038 | OPEN_ENDED / OPEN / MEAL_PENDING, REST_NEEDED | TBD / MEDIUM | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 4 | NEEDS_DURATION |
| SC-039 | OPEN_ENDED / OPEN / MEAL_PENDING, REST_NEEDED | 60 / MEDIUM | OUTDOOR / WALKING / SAFE_LOCAL_AREA | [] | 4 | PROPOSED |
| SC-040 | OPEN_ENDED / NONE / MEAL_PENDING, REST_NEEDED | 75 / MEDIUM | OUTDOOR / WALKING / KNOWN_SAFE_ROUTE | [] | 3 | PROPOSED |

All BA-10 rows are `WEATHER_SENSITIVE` and `situation_sensitive=YES`. SC-038 needs a duration because the approved rewrite removed the original 75-minute value.

## Batch review required

Before canonical import, confirm or change:

1. the shared taxonomy and defaults;
2. all `PROPOSED` rows as a batch or by exception;
3. the six concrete SC-013 missions;
4. SC-038's expected duration.

Only after that may values be copied into the canonical review CSV and the `REVIEW_REQUIRED` gate be cleared.
