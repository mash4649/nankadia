import type { ContextSnapshot, ImmediateNeed, TrajectoryType, DetourBudget } from './domain';

export type MomentModeAnswer =
  | 'RETURNING_HOME_SMALL'
  | 'EN_ROUTE_FIXED_NONE'
  | 'WAITING_SMALL'
  | 'STAYING_NONE'
  | 'OPEN_ENDED_OPEN';

export interface StartMomentInput { appSessionId: string; idempotencyKey: string; }
export interface ResolveMomentModeInput { momentId: string; answer: MomentModeAnswer; idempotencyKey: string; }
export interface ResolveImmediateNeedInput { momentId: string; need: ImmediateNeed; idempotencyKey: string; }
export interface CorrectContextInput {
  momentId: string;
  baseContextSnapshotId: string;
  patch: Partial<{ trajectory: TrajectoryType; detour: DetourBudget; need: ImmediateNeed }>;
  idempotencyKey: string;
}
export interface RequestRecommendationInput { momentId: string; contextSnapshotId: string; idempotencyKey: string; }
export interface ExpandScopeInput { momentId: string; baseContextSnapshotId: string; idempotencyKey: string; }
export interface RecommendationResponse {
  decisionId: string;
  contextSnapshotId: string;
  isNoMatch: boolean;
  resolution?: { resolutionId: string; title: string; actionCopy: string; supportingCopy?: string };
  fitReceipt: string[];
}
export interface AcceptRecommendationInput { recommendationImpressionId: string; idempotencyKey: string; }
export interface SkipRecommendationInput { recommendationImpressionId: string; idempotencyKey: string; }
export interface RecordExternalOpenInput { executionId: string; accessRouteId: string; idempotencyKey: string; }
export interface StartExecutionInput { executionId: string; idempotencyKey: string; }
export interface CompleteExecutionInput { executionId: string; idempotencyKey: string; }
export interface AbortExecutionInput { executionId: string; idempotencyKey: string; }
export interface RecordOutcomeInput { executionId: string; value: 'GOOD'|'NEUTRAL'|'BAD'; idempotencyKey: string; }
export interface RecordDiscoveryInput { executionId: string; answer: 'LIKELY_YES'|'UNCERTAIN'|'LIKELY_NO'|'SKIP'; idempotencyKey: string; }
export interface KeepBaselineInput { momentId: string; idempotencyKey: string; }
