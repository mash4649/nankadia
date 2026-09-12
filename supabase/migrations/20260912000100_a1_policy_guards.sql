-- Portable invariant helpers. Apply with service-owned migrations.

create or replace function prevent_event_mutation() returns trigger language plpgsql as $$
begin
  raise exception 'event_log is append-only';
end $$;

create trigger event_log_no_update_delete
before update or delete on event_log
for each row execute function prevent_event_mutation();

create or replace function prevent_referenced_context_mutation() returns trigger language plpgsql as $$
begin
  if exists (select 1 from recommendation_decision d where d.context_snapshot_id = old.context_snapshot_id) then
    raise exception 'referenced context_snapshot is immutable';
  end if;
  return new;
end $$;

create trigger context_snapshot_guard
before update or delete on context_snapshot
for each row execute function prevent_referenced_context_mutation();

create or replace function guard_experiment_config_mutation() returns trigger language plpgsql as $$
begin
  if old.state = 'ACTIVE' then
    -- allow ACTIVE -> RETIRED only if policy/version fields are unchanged
    if new.state <> 'RETIRED'
       or new.core_pool_version <> old.core_pool_version
       or new.ranking_policy_version <> old.ranking_policy_version
       or new.fallback_policy_version <> old.fallback_policy_version
       or new.moment_policy_version <> old.moment_policy_version
       or new.context_policy_version <> old.context_policy_version
       or new.profile_policy_version <> old.profile_policy_version
       or new.ui_variant_version <> old.ui_variant_version
       or new.access_route_policy_version <> old.access_route_policy_version
       or new.outcome_prompt_version <> old.outcome_prompt_version
       or new.metric_contract_version <> old.metric_contract_version then
      raise exception 'ACTIVE experiment_config is immutable except retirement';
    end if;
  end if;
  return new;
end $$;

create trigger experiment_config_guard
before update on experiment_config
for each row execute function guard_experiment_config_mutation();

create or replace function guard_released_pool_mutation() returns trigger language plpgsql as $$
begin
  if tg_table_name = 'core_pool_member' then
    if exists (
      select 1 from core_pool_release r
      where r.core_pool_version = coalesce(old.core_pool_version, new.core_pool_version)
        and r.state = 'RELEASED'
    ) then
      raise exception 'RELEASED core pool membership is immutable';
    end if;
  elsif tg_table_name = 'core_pool_release' and old.state = 'RELEASED' then
    if new.state <> 'RETIRED' or new.content_hash is distinct from old.content_hash then
      raise exception 'RELEASED core pool metadata is immutable except retirement';
    end if;
  end if;
  return coalesce(new, old);
end $$;

create trigger core_pool_member_guard
before update or delete on core_pool_member
for each row execute function guard_released_pool_mutation();

create trigger core_pool_release_guard
before update on core_pool_release
for each row execute function guard_released_pool_mutation();
