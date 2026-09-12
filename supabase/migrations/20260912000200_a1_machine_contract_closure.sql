-- P0-01: close released-pool and ACTIVE-config invariants without selecting Product policy.

create or replace function guard_released_pool_mutation() returns trigger language plpgsql as $$
begin
  if tg_table_name = 'core_pool_member' then
    if exists (
      select 1 from core_pool_release r
      where r.core_pool_version = coalesce(old.core_pool_version, new.core_pool_version)
        and r.state in ('RELEASED', 'RETIRED')
    ) then
      raise exception 'RELEASED core pool membership is immutable';
    end if;
  elsif tg_table_name = 'core_pool_release' and old.state = 'RELEASED' then
    if new.state <> 'RETIRED'
       or (to_jsonb(new) - array['state', 'retired_at'])
          is distinct from (to_jsonb(old) - array['state', 'retired_at']) then
      raise exception 'RELEASED core pool metadata is immutable except retirement';
    end if;
  end if;
  return coalesce(new, old);
end $$;

drop trigger if exists core_pool_member_guard on core_pool_member;
create trigger core_pool_member_guard
before insert or update or delete on core_pool_member
for each row execute function guard_released_pool_mutation();

create or replace function guard_active_experiment_config_pool() returns trigger language plpgsql as $$
begin
  if new.state = 'ACTIVE' and not exists (
    select 1 from core_pool_release r
    where r.core_pool_version = new.core_pool_version
      and r.state = 'RELEASED'
  ) then
    raise exception 'only RELEASED core pools may activate experiment configs';
  end if;
  return new;
end $$;

create trigger experiment_config_activation_guard
before insert or update on experiment_config
for each row execute function guard_active_experiment_config_pool();

create or replace function guard_core_pool_retirement() returns trigger language plpgsql as $$
begin
  if old.state = 'RELEASED' and new.state = 'RETIRED' and exists (
    select 1 from experiment_config c
    where c.core_pool_version = old.core_pool_version
      and c.state = 'ACTIVE'
  ) then
    raise exception 'cannot retire a core pool referenced by an ACTIVE experiment config';
  end if;
  return new;
end $$;

create trigger core_pool_release_active_config_guard
before update on core_pool_release
for each row execute function guard_core_pool_retirement();
