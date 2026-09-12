export type TrajectoryType =
  | 'RETURNING_HOME' | 'EN_ROUTE_FIXED' | 'STAYING'
  | 'WAITING' | 'OPEN_ENDED' | 'UNKNOWN';
export type DetourBudget = 'NONE' | 'SMALL' | 'OPEN';
export type ImmediateNeed = 'NONE' | 'MEAL_PENDING' | 'REST_NEEDED' | 'UNKNOWN';
export type ContextFreshness = 'FRESH' | 'REVALIDATE';
export type ContextSource = 'USER_EXPLICIT' | 'SYSTEM_INFERRED' | 'DEFAULT_SAFE' | 'UNKNOWN';
export type SituationBucket = 'A_DIRECT_FIT' | 'B_ACCEPTABLE';
export type EntryOrigin = 'DIRECT' | 'EXTERNAL_SHARE' | 'NOTIFICATION' | 'CAMPAIGN' | 'OTHER_DEEPLINK' | 'UNKNOWN';
export type OutcomeValue = 'GOOD' | 'NEUTRAL' | 'BAD';
export type DiscoveryAnswer = 'LIKELY_YES' | 'UNCERTAIN' | 'LIKELY_NO' | 'SKIP';

export interface ResolvedField<T> {
  value: T;
  source: ContextSource;
  confidence?: number;
}

export interface ContextSnapshot {
  contextSnapshotId: string;
  momentId: string;
  snapshotVersion: number;
  contextPolicyVersion: string;
  trajectory: ResolvedField<TrajectoryType>;
  detour: ResolvedField<DetourBudget>;
  need: ResolvedField<ImmediateNeed>;
  freshness: ContextFreshness;
  auxiliaryFacts: Record<string, unknown>;
  fitReceiptFieldsShown: string[];
  createdAt: string;
}

export interface ResolutionEligibility {
  trajectoryCompatibility: Array<TrajectoryType | 'ANY'>;
  requiredDetourScope: DetourBudget;
  needConflicts: ImmediateNeed[];
  softContextRequirements?: Record<string, unknown>;
  expectedDurationMinutes?: number;
  effortLevel?: string;
  costBucket?: string;
  indoorOutdoor?: string;
  weatherDependency?: string;
  mobilityRequirement?: string;
  placeDependency?: string;
  requiredResources: string[];
  dynamicFactRequirements: string[];
}

export interface RecommendationTrace {
  recommendationDecisionId: string;
  contextSnapshotId: string;
  corePoolVersion: string;
  rankingPolicyVersion: string;
  eligibleCandidateCount: number;
  selectedBucket?: SituationBucket;
  selectedResolutionId?: string;
  excludedReasonCounts: Record<string, number>;
  candidateTrace: Array<{ resolutionId: string; reasonCodes: string[] }>;
}
