-- Run after database/0001_schema.sql through 0003_machine_contract_closure.sql.
-- The whole test rolls back and leaves no fixtures behind.
\set ON_ERROR_STOP on
begin;

insert into app_user (user_id) values ('00000000-0000-0000-0000-000000000001');
insert into experience (experience_id, action_mechanic, semantic_cluster, content_version)
values ('machine-contract-experience', 'TEST', 'TEST', 'v1');
insert into resolution (resolution_id, experience_id, title, action_copy, content_version)
values ('machine-contract-resolution', 'machine-contract-experience', 'Test', 'Test', 'v1');

insert into core_pool_release (core_pool_version, state, canonical_version, audit_policy_version, coverage_policy_version)
values ('draft-pool', 'DRAFT', 'v1', 'v1', 'v1');

do $$
declare rejected boolean := false;
begin
  begin
    insert into experiment_config (
      config_key, state, core_pool_version, ranking_policy_version, fallback_policy_version,
      moment_policy_version, context_policy_version, profile_policy_version, ui_variant_version,
      access_route_policy_version, outcome_prompt_version, metric_contract_version
    ) values (
      'draft-pool-active-config', 'ACTIVE', 'draft-pool', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1'
    );
  exception when others then
    if sqlerrm like '%only RELEASED core pools may activate experiment configs%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'ACTIVE config must reject a non-RELEASED pool';
  end if;
end $$;

insert into core_pool_member (core_pool_version, resolution_id, resolution_content_version)
values ('draft-pool', 'machine-contract-resolution', 'v1');
update core_pool_release
set state = 'RELEASED', content_hash = 'released-hash'
where core_pool_version = 'draft-pool';

do $$
declare rejected boolean := false;
begin
  begin
    insert into core_pool_member (core_pool_version, resolution_id, resolution_content_version)
    values ('draft-pool', 'machine-contract-resolution', 'v2');
  exception when others then
    if sqlerrm like '%RELEASED core pool membership is immutable%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'RELEASED core pool membership INSERT must be rejected';
  end if;
end $$;

do $$
declare rejected boolean := false;
begin
  begin
    update core_pool_member set resolution_content_version = 'v2'
    where core_pool_version = 'draft-pool';
  exception when others then
    if sqlerrm like '%RELEASED core pool membership is immutable%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'RELEASED core pool membership UPDATE must be rejected';
  end if;
end $$;

do $$
declare rejected boolean := false;
begin
  begin
    delete from core_pool_member where core_pool_version = 'draft-pool';
  exception when others then
    if sqlerrm like '%RELEASED core pool membership is immutable%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'RELEASED core pool membership DELETE must be rejected';
  end if;
end $$;

do $$
declare rejected boolean := false;
begin
  begin
    update core_pool_release set canonical_version = 'v2'
    where core_pool_version = 'draft-pool';
  exception when others then
    if sqlerrm like '%RELEASED core pool metadata is immutable%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'RELEASED core pool metadata mutation must be rejected';
  end if;
end $$;

do $$
declare rejected boolean := false;
begin
  begin
    update core_pool_release set content_hash = 'mutated-hash'
    where core_pool_version = 'draft-pool';
  exception when others then
    if sqlerrm like '%RELEASED core pool metadata is immutable%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'RELEASED core pool content hash mutation must be rejected';
  end if;
end $$;

insert into experiment_config (
  config_key, state, core_pool_version, ranking_policy_version, fallback_policy_version,
  moment_policy_version, context_policy_version, profile_policy_version, ui_variant_version,
  access_route_policy_version, outcome_prompt_version, metric_contract_version
) values (
  'released-pool-active-config', 'ACTIVE', 'draft-pool', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1', 'v1'
);

do $$
declare rejected boolean := false;
begin
  begin
    update core_pool_release set state = 'RETIRED'
    where core_pool_version = 'draft-pool';
  exception when others then
    if sqlerrm like '%cannot retire a core pool referenced by an ACTIVE experiment config%' then
      rejected := true;
    else
      raise;
    end if;
  end;
  if not rejected then
    raise exception 'core pool retirement must reject ACTIVE config references';
  end if;
end $$;

rollback;
