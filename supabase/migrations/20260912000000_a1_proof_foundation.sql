-- NANKADIA P0 Slice A portable PostgreSQL schema contract v1.0
-- Vendor-specific auth/RLS may wrap this schema; Product/domain invariants stay the same.

create extension if not exists pgcrypto;

create type experiment_config_state as enum ('DRAFT','ACTIVE','RETIRED');
create type cohort_stage as enum ('CALIBRATION','PROOF_A','PROOF_B');
create type trajectory_type as enum ('RETURNING_HOME','EN_ROUTE_FIXED','STAYING','WAITING','OPEN_ENDED','UNKNOWN');
create type detour_budget as enum ('NONE','SMALL','OPEN');
create type immediate_need as enum ('NONE','MEAL_PENDING','REST_NEEDED','UNKNOWN');
create type context_freshness as enum ('FRESH','REVALIDATE');
create type context_source as enum ('USER_EXPLICIT','SYSTEM_INFERRED','DEFAULT_SAFE','UNKNOWN');
create type situation_bucket as enum ('A_DIRECT_FIT','B_ACCEPTABLE');
create type serving_state as enum ('PARKED','CORE','PAUSED','DEPRECATED');
create type execution_state as enum ('ACCEPTED','STARTED','COMPLETED','ABORTED');
create type outcome_state as enum ('PENDING','RECORDED','MISSING');
create type outcome_value as enum ('GOOD','NEUTRAL','BAD');
create type discovery_answer as enum ('LIKELY_YES','UNCERTAIN','LIKELY_NO','SKIP');
create type entry_origin as enum ('DIRECT','EXTERNAL_SHARE','NOTIFICATION','CAMPAIGN','OTHER_DEEPLINK','UNKNOWN');
create type pool_release_state as enum ('DRAFT','RELEASE_CANDIDATE','RELEASED','RETIRED');

create table app_user (
  user_id uuid primary key default gen_random_uuid(),
  timezone text not null default 'Asia/Tokyo',
  adult_attested_at timestamptz,
  created_at timestamptz not null default now()
);

create table experiment_config (
  experiment_config_id uuid primary key default gen_random_uuid(),
  config_key text not null unique,
  state experiment_config_state not null default 'DRAFT',
  core_pool_version text not null,
  ranking_policy_version text not null,
  fallback_policy_version text not null,
  moment_policy_version text not null,
  context_policy_version text not null,
  profile_policy_version text not null,
  ui_variant_version text not null,
  access_route_policy_version text not null,
  outcome_prompt_version text not null,
  metric_contract_version text not null,
  created_at timestamptz not null default now(),
  activated_at timestamptz,
  retired_at timestamptz
);

create table proof_cohort (
  proof_cohort_id uuid primary key default gen_random_uuid(),
  cohort_key text not null unique,
  stage cohort_stage not null,
  experiment_config_id uuid not null references experiment_config(experiment_config_id),
  opened_at timestamptz not null default now(),
  closed_at timestamptz
);

create table proof_enrollment (
  proof_enrollment_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(user_id),
  proof_cohort_id uuid not null references proof_cohort(proof_cohort_id),
  experiment_config_id uuid not null references experiment_config(experiment_config_id),
  cohort_entered_at timestamptz not null default now(),
  day0_local_date date not null,
  unique(user_id),
  unique(user_id, proof_cohort_id)
);

create table app_session (
  app_session_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(user_id),
  entry_origin entry_origin not null,
  started_at timestamptz not null default now(),
  client_version text not null
);
create index app_session_user_started_idx on app_session(user_id, started_at desc);

create table moment (
  moment_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(user_id),
  app_session_id uuid not null references app_session(app_session_id),
  started_at timestamptz not null default now(),
  explicitly_started boolean not null default true,
  ended_at timestamptz
);
create index moment_user_started_idx on moment(user_id, started_at desc);

create table context_snapshot (
  context_snapshot_id uuid primary key default gen_random_uuid(),
  moment_id uuid not null references moment(moment_id),
  snapshot_version integer not null check (snapshot_version >= 1),
  context_policy_version text not null,
  trajectory trajectory_type not null,
  trajectory_source context_source not null,
  trajectory_confidence numeric(4,3),
  detour detour_budget not null,
  detour_source context_source not null,
  detour_confidence numeric(4,3),
  need immediate_need not null,
  need_source context_source not null,
  need_confidence numeric(4,3),
  freshness context_freshness not null default 'FRESH',
  auxiliary_facts jsonb not null default '{}'::jsonb,
  fit_receipt_fields_shown jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  unique(moment_id, snapshot_version),
  check (trajectory_confidence is null or trajectory_confidence between 0 and 1),
  check (detour_confidence is null or detour_confidence between 0 and 1),
  check (need_confidence is null or need_confidence between 0 and 1)
);
create index context_snapshot_moment_idx on context_snapshot(moment_id, snapshot_version desc);

create table experience (
  experience_id text primary key,
  canonical_root_id text,
  action_mechanic text not null,
  semantic_cluster text not null,
  content_version text not null,
  provenance jsonb not null default '{}'::jsonb
);

create table resolution (
  resolution_id text primary key,
  experience_id text not null references experience(experience_id),
  title text not null,
  action_copy text not null,
  supporting_copy text,
  serving_state serving_state not null default 'PARKED',
  trajectory_compatibility trajectory_type[] not null default '{}'::trajectory_type[], -- empty array = ANY
  required_detour_scope detour_budget not null default 'NONE',
  need_conflicts immediate_need[] not null default '{}'::immediate_need[],
  soft_context_requirements jsonb not null default '{}'::jsonb,
  expected_duration_minutes integer,
  effort_level text,
  cost_bucket text,
  indoor_outdoor text,
  weather_dependency text,
  mobility_requirement text,
  place_dependency text,
  required_resources text[] not null default '{}'::text[],
  dynamic_fact_requirements text[] not null default '{}'::text[],
  discovery_quality smallint check (discovery_quality is null or discovery_quality between 0 and 4),
  content_version text not null,
  constraint expected_duration_nonnegative check (expected_duration_minutes is null or expected_duration_minutes >= 0)
);

create table core_pool_release (
  core_pool_version text primary key,
  state pool_release_state not null default 'DRAFT',
  canonical_version text not null,
  audit_policy_version text not null,
  coverage_policy_version text not null,
  content_hash text,
  released_at timestamptz,
  approved_by text,
  created_at timestamptz not null default now()
);

create table core_pool_member (
  core_pool_version text not null references core_pool_release(core_pool_version),
  resolution_id text not null references resolution(resolution_id),
  resolution_content_version text not null,
  primary key(core_pool_version, resolution_id)
);

create table entity (
  entity_id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  display_name text not null
);
create table entity_fact (
  entity_fact_id uuid primary key default gen_random_uuid(),
  entity_id uuid not null references entity(entity_id),
  fact_type text not null,
  value_json jsonb not null,
  verified_at timestamptz,
  expires_at timestamptz,
  freshness_state text not null check (freshness_state in ('FRESH','STALE','UNKNOWN'))
);
create table access_route (
  access_route_id uuid primary key default gen_random_uuid(),
  entity_id uuid references entity(entity_id),
  route_type text not null,
  target text
);
create table access_route_fact (
  access_route_fact_id uuid primary key default gen_random_uuid(),
  access_route_id uuid not null references access_route(access_route_id),
  fact_type text not null,
  value_json jsonb not null,
  verified_at timestamptz,
  expires_at timestamptz,
  freshness_state text not null check (freshness_state in ('FRESH','STALE','UNKNOWN'))
);

create table recommendation_decision (
  recommendation_decision_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(user_id),
  moment_id uuid not null references moment(moment_id),
  context_snapshot_id uuid not null references context_snapshot(context_snapshot_id),
  experiment_config_id uuid not null references experiment_config(experiment_config_id),
  proof_cohort_id uuid references proof_cohort(proof_cohort_id),
  core_pool_version text not null references core_pool_release(core_pool_version),
  ranking_policy_version text not null,
  selected_resolution_id text references resolution(resolution_id),
  selected_bucket situation_bucket,
  eligible_candidate_count integer not null check (eligible_candidate_count >= 0),
  excluded_reason_counts jsonb not null default '{}'::jsonb,
  candidate_trace jsonb not null default '[]'::jsonb,
  is_no_match boolean not null,
  created_at timestamptz not null default now(),
  check ((is_no_match and selected_resolution_id is null) or (not is_no_match and selected_resolution_id is not null))
);
create index recommendation_decision_moment_idx on recommendation_decision(moment_id, created_at);

create table recommendation_impression (
  recommendation_impression_id uuid primary key default gen_random_uuid(),
  recommendation_decision_id uuid not null references recommendation_decision(recommendation_decision_id),
  resolution_id text not null references resolution(resolution_id),
  shown_at timestamptz not null default now(),
  skipped_at timestamptz,
  accepted_at timestamptz,
  unique(recommendation_decision_id, resolution_id)
);

create table execution (
  execution_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(user_id),
  moment_id uuid not null references moment(moment_id),
  recommendation_decision_id uuid not null references recommendation_decision(recommendation_decision_id),
  resolution_id text not null references resolution(resolution_id),
  state execution_state not null,
  accepted_at timestamptz not null,
  started_at timestamptz,
  completed_at timestamptz,
  aborted_at timestamptz,
  unique(recommendation_decision_id)
);

create table outcome (
  outcome_id uuid primary key default gen_random_uuid(),
  execution_id uuid not null unique references execution(execution_id),
  state outcome_state not null default 'PENDING',
  value outcome_value,
  prompted_at timestamptz,
  recorded_at timestamptz,
  missing_at timestamptz,
  check ((state='RECORDED' and value is not null) or (state<>'RECORDED'))
);

create table incremental_discovery (
  incremental_discovery_id uuid primary key default gen_random_uuid(),
  execution_id uuid not null unique references execution(execution_id),
  prompted_at timestamptz,
  answer discovery_answer,
  answered_at timestamptz
);

create table event_log (
  event_id uuid primary key,
  event_name text not null,
  event_schema_version text not null,
  user_id uuid not null references app_user(user_id),
  app_session_id uuid not null references app_session(app_session_id),
  moment_id uuid references moment(moment_id),
  proof_cohort_id uuid references proof_cohort(proof_cohort_id),
  experiment_config_id uuid references experiment_config(experiment_config_id),
  metric_contract_version text not null,
  client_occurred_at timestamptz not null,
  server_received_at timestamptz not null default now(),
  client_version text not null,
  payload jsonb not null default '{}'::jsonb
);
create index event_log_user_time_idx on event_log(user_id, server_received_at);
create index event_log_moment_time_idx on event_log(moment_id, server_received_at) where moment_id is not null;
create index event_log_name_time_idx on event_log(event_name, server_received_at);

create table event_correction (
  event_correction_id uuid primary key default gen_random_uuid(),
  event_id uuid not null references event_log(event_id),
  correction_type text not null,
  reason_code text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table measurement_exclusion (
  measurement_exclusion_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(user_id),
  moment_id uuid references moment(moment_id),
  reason_code text not null,
  technical_only boolean not null check (technical_only = true),
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Mutable operational data may update through server commands.
-- The following immutable objects must be protected by triggers or command-layer privileges:
-- ACTIVE experiment_config policy columns, RELEASED core_pool_release/members, referenced context_snapshot, event_log.
