-- Minimal Calibration-1 diagnostic queries. Adapt schema name as needed.

-- Funnel by cohort
select c.cohort_key,
       count(distinct m.moment_id) as moments,
       count(distinct ri.recommendation_impression_id) as impressions,
       count(distinct e.execution_id) filter (where e.state in ('ACCEPTED','STARTED','COMPLETED','ABORTED')) as accepts,
       count(distinct e.execution_id) filter (where e.state in ('STARTED','COMPLETED','ABORTED')) as started,
       count(distinct e.execution_id) filter (where e.state='COMPLETED') as completed,
       count(distinct o.outcome_id) filter (where o.state='RECORDED') as recorded_outcomes
from proof_cohort c
join proof_enrollment pe on pe.proof_cohort_id=c.proof_cohort_id
left join moment m on m.user_id=pe.user_id
left join recommendation_decision rd on rd.moment_id=m.moment_id
left join recommendation_impression ri on ri.recommendation_decision_id=rd.recommendation_decision_id
left join execution e on e.recommendation_decision_id=rd.recommendation_decision_id
left join outcome o on o.execution_id=e.execution_id
group by c.cohort_key order by c.cohort_key;

-- No Match / bucket distribution
select pc.cohort_key,
       count(*) filter (where rd.is_no_match) as no_match_decisions,
       count(*) filter (where rd.selected_bucket='A_DIRECT_FIT') as bucket_a,
       count(*) filter (where rd.selected_bucket='B_ACCEPTABLE') as bucket_b,
       count(*) as decisions
from recommendation_decision rd
left join proof_cohort pc on pc.proof_cohort_id=rd.proof_cohort_id
group by pc.cohort_key;

-- Primary metric components at user level. Assumes first explicit Moment after enrollment is the first qualifying Moment;
-- production view should use the final qualification predicate rather than this simplified skeleton.
with first_moment as (
  select pe.user_id, pe.proof_cohort_id, pe.day0_local_date,
         (select m.moment_id from moment m where m.user_id=pe.user_id and m.started_at>=pe.cohort_entered_at order by m.started_at limit 1) as moment_id
  from proof_enrollment pe
), first_exec as (
  select fm.*, e.execution_id, e.state as execution_state, o.state as outcome_state, o.value as outcome_value
  from first_moment fm
  left join recommendation_decision rd on rd.moment_id=fm.moment_id and rd.selected_resolution_id is not null
  left join execution e on e.recommendation_decision_id=rd.recommendation_decision_id
  left join outcome o on o.execution_id=e.execution_id
), user_primary as (
  select user_id, proof_cohort_id,
    bool_or(execution_state='COMPLETED' and outcome_state='RECORDED' and outcome_value='GOOD') as gal_success,
    bool_or(execution_state='COMPLETED') as completed,
    bool_or(outcome_state='RECORDED') as outcome_recorded,
    bool_or(outcome_state='RECORDED' and outcome_value='GOOD') as positive_outcome
  from first_exec group by user_id, proof_cohort_id
)
select pc.cohort_key,
       count(*) as qualifying_users,
       avg(gal_success::int)::numeric(6,4) as gal_rate,
       (sum(positive_outcome::int)::numeric / nullif(sum(outcome_recorded::int),0))::numeric(6,4) as positive_outcome_rate,
       (sum(outcome_recorded::int)::numeric / nullif(sum(completed::int),0))::numeric(6,4) as outcome_capture_rate
from user_primary up join proof_cohort pc using (proof_cohort_id)
group by pc.cohort_key;

-- Scope expansion diagnostics from event log
select pc.cohort_key,
  count(distinct ev.moment_id) filter (where ev.event_name='scope_expanded') as expanded_moments,
  count(distinct ev.moment_id) filter (where ev.event_name='fallback_keep_baseline') as baseline_keep_moments
from event_log ev
left join proof_cohort pc on pc.proof_cohort_id=ev.proof_cohort_id
group by pc.cohort_key;

-- Event integrity: duplicated logical IDs should be impossible by PK; this checks suspicious state/event gaps.
select e.execution_id, e.state, e.started_at,
       exists(select 1 from event_log ev where ev.user_id=e.user_id and ev.moment_id=e.moment_id and ev.event_name='action_started') as has_started_event
from execution e
where e.state in ('STARTED','COMPLETED','ABORTED');

-- D14 SELF_MOMENT rate based on server-qualified event. Assumes self_moment_qualified is emitted only after canonical server rule.
with enrolled as (
  select pe.user_id, pe.proof_cohort_id
  from proof_enrollment pe
  where not exists (
    select 1 from measurement_exclusion mx
    where mx.user_id=pe.user_id and mx.technical_only=true
  )
), returned as (
  select distinct e.user_id, e.proof_cohort_id
  from event_log e
  where e.event_name='self_moment_qualified'
)
select pc.cohort_key,
       count(*) as qualifying_users,
       count(r.user_id) as returned_users,
       (count(r.user_id)::numeric / nullif(count(*),0))::numeric(6,4) as d14_self_moment_rate
from enrolled q
join proof_cohort pc on pc.proof_cohort_id=q.proof_cohort_id
left join returned r on r.user_id=q.user_id and r.proof_cohort_id=q.proof_cohort_id
group by pc.cohort_key;

-- Direct vs Expanded action-start components. Diagnostic only; this does NOT redefine Primary GAL.
with moment_flags as (
  select m.moment_id, pe.proof_cohort_id,
    exists(select 1 from event_log ev where ev.moment_id=m.moment_id and ev.event_name='scope_expanded') as expanded,
    exists(select 1 from event_log ev where ev.moment_id=m.moment_id and ev.event_name='action_started') as started
  from moment m
  join proof_enrollment pe on pe.user_id=m.user_id
)
select pc.cohort_key,
  count(*) filter (where started and not expanded) as direct_started_moments,
  count(*) filter (where started and expanded) as expanded_started_moments,
  count(*) as observed_moments
from moment_flags mf join proof_cohort pc using (proof_cohort_id)
group by pc.cohort_key;
