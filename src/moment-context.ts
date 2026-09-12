export type TrajectoryType =
  | 'RETURNING_HOME'
  | 'EN_ROUTE_FIXED'
  | 'STAYING'
  | 'WAITING'
  | 'OPEN_ENDED'
  | 'UNKNOWN';

export type DetourBudget = 'NONE' | 'SMALL' | 'OPEN';
export type ImmediateNeed = 'NONE' | 'MEAL_PENDING' | 'REST_NEEDED' | 'UNKNOWN';
export type ContextSource = 'USER_EXPLICIT' | 'SYSTEM_INFERRED' | 'DEFAULT_SAFE' | 'UNKNOWN';

export type MomentModeAnswer =
  | 'RETURNING_HOME_SMALL'
  | 'EN_ROUTE_FIXED_NONE'
  | 'WAITING_SMALL'
  | 'STAYING_NONE'
  | 'OPEN_ENDED_OPEN';

export interface ResolvedMomentMode {
  trajectory: TrajectoryType;
  detour: DetourBudget;
  source: Extract<ContextSource, 'USER_EXPLICIT'>;
}

// Policy mapping is provisional and must remain replaceable by moment_policy_version.
const modeMap: Record<MomentModeAnswer, ResolvedMomentMode> = {
  RETURNING_HOME_SMALL: { trajectory: 'RETURNING_HOME', detour: 'SMALL', source: 'USER_EXPLICIT' },
  EN_ROUTE_FIXED_NONE: { trajectory: 'EN_ROUTE_FIXED', detour: 'NONE', source: 'USER_EXPLICIT' },
  WAITING_SMALL: { trajectory: 'WAITING', detour: 'SMALL', source: 'USER_EXPLICIT' },
  STAYING_NONE: { trajectory: 'STAYING', detour: 'NONE', source: 'USER_EXPLICIT' },
  OPEN_ENDED_OPEN: { trajectory: 'OPEN_ENDED', detour: 'OPEN', source: 'USER_EXPLICIT' },
};

export function resolveMomentMode(answer: MomentModeAnswer): ResolvedMomentMode {
  return { ...modeMap[answer] };
}

export type NonRequiredQuestion = 'MOMENT_MODE' | 'IMMEDIATE_NEED';

export interface QuestionBudgetInput {
  nonRequiredQuestionsAsked: number;
  momentModeUnresolved: boolean;
  immediateNeedMaterial: boolean;
}

/** Required questions are outside this budget and are handled by the caller. */
export function nextNonRequiredQuestion(input: QuestionBudgetInput): NonRequiredQuestion | null {
  if (input.nonRequiredQuestionsAsked >= 1) return null;
  if (input.momentModeUnresolved) return 'MOMENT_MODE';
  if (input.immediateNeedMaterial) return 'IMMEDIATE_NEED';
  return null;
}

export function nextSnapshotVersion(existingVersions: number[]): number {
  return existingVersions.length === 0 ? 1 : Math.max(...existingVersions) + 1;
}
