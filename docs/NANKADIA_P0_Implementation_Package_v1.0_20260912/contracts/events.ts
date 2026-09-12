export const eventNames = [
  'app_entry','moment_started','context_question_shown','context_answered',
  'context_snapshot_created','context_resolved','recommendation_requested',
  'recommendation_impression','recommendation_accepted','recommendation_skipped',
  'recommendation_no_match','fallback_entered','fit_receipt_shown','context_corrected',
  'scope_expanded','fallback_keep_baseline','external_open','action_started',
  'execution_completed','execution_aborted','outcome_prompt_shown','outcome_recorded',
  'outcome_missing','incremental_discovery_prompt_shown','incremental_discovery_answered',
  'self_moment_qualified','skip_reason_prompt_shown','skip_reason_recorded',
  'context_revalidation_prompt_shown','context_revalidated'
] as const;
export type EventName = typeof eventNames[number];

export interface EventEnvelope<TPayload = Record<string, unknown>> {
  eventId: string;
  eventName: EventName;
  eventSchemaVersion: string;
  userId: string;
  appSessionId: string;
  momentId?: string;
  proofCohortId?: string;
  experimentConfigId?: string;
  metricContractVersion: string;
  clientOccurredAt: string;
  serverReceivedAt?: string;
  clientVersion: string;
  payload: TPayload;
}
