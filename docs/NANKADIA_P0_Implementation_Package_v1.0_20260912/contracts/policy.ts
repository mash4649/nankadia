import type { ContextSnapshot, DetourBudget, ImmediateNeed, ResolutionEligibility, SituationBucket, TrajectoryType } from './domain';

export type Daypart = 'MORNING' | 'DAY' | 'EVENING' | 'NIGHT';
export type WeatherState = 'DRY' | 'RAIN' | 'SNOW' | 'EXTREME' | 'UNKNOWN';

export interface CalibrationAuxiliaryFacts {
  daypart?: Daypart;       // derived from trusted local/server time
  weatherState?: WeatherState; // only when coarse-area weather is legitimately available
}

const detourRank: Record<DetourBudget, number> = { NONE: 0, SMALL: 1, OPEN: 2 };

export function detourFits(userBudget: DetourBudget, requiredScope: DetourBudget): boolean {
  return detourRank[userBudget] >= detourRank[requiredScope];
}

export function trajectoryFits(current: TrajectoryType, compatible: Array<TrajectoryType | 'ANY'>): boolean {
  if (compatible.includes('ANY')) return true;
  if (current === 'UNKNOWN') return compatible.includes('UNKNOWN');
  return compatible.includes(current);
}

export function needFits(current: ImmediateNeed, conflicts: ImmediateNeed[]): boolean {
  return !conflicts.includes(current);
}

export type HardExclusionReason =
  | 'NOT_IN_FROZEN_CORE'
  | 'NOT_SERVABLE'
  | 'SAFETY_OR_LEGAL'
  | 'REQUIRED_FACT_STALE_OR_UNKNOWN'
  | 'TRAJECTORY_INCOMPATIBLE'
  | 'DETOUR_SCOPE_EXCEEDED'
  | 'IMMEDIATE_NEED_CONFLICT'
  | 'REQUIRED_RESOURCE_ABSENT'
  | 'ALREADY_SHOWN_THIS_MOMENT';

export interface HardFilterInputs {
  inFrozenCore: boolean;
  servable: boolean;
  safetyLegalPass: boolean;
  requiredFactsFresh: boolean;
  requiredResourcesKnownPresent: boolean;
  alreadyShown: boolean;
}

export function hardExclusionReasons(
  ctx: ContextSnapshot,
  candidate: ResolutionEligibility,
  flags: HardFilterInputs,
): HardExclusionReason[] {
  const reasons: HardExclusionReason[] = [];
  if (!flags.inFrozenCore) reasons.push('NOT_IN_FROZEN_CORE');
  if (!flags.servable) reasons.push('NOT_SERVABLE');
  if (!flags.safetyLegalPass) reasons.push('SAFETY_OR_LEGAL');
  if (!flags.requiredFactsFresh) reasons.push('REQUIRED_FACT_STALE_OR_UNKNOWN');
  if (!trajectoryFits(ctx.trajectory.value, candidate.trajectoryCompatibility)) reasons.push('TRAJECTORY_INCOMPATIBLE');
  if (!detourFits(ctx.detour.value, candidate.requiredDetourScope)) reasons.push('DETOUR_SCOPE_EXCEEDED');
  if (!needFits(ctx.need.value, candidate.needConflicts)) reasons.push('IMMEDIATE_NEED_CONFLICT');
  if (!flags.requiredResourcesKnownPresent) reasons.push('REQUIRED_RESOURCE_ABSENT');
  if (flags.alreadyShown) reasons.push('ALREADY_SHOWN_THIS_MOMENT');
  return reasons;
}

export interface CalibrationSoftRequirements {
  allowedDayparts?: Daypart[];
  allowedWeatherStates?: WeatherState[];
}

export function knownSoftMismatchCount(
  auxiliary: CalibrationAuxiliaryFacts,
  req: CalibrationSoftRequirements | undefined,
): number {
  if (!req) return 0;
  let count = 0;
  // Unknown/absent auxiliary facts never count as mismatch and never cause a question.
  if (auxiliary.daypart && req.allowedDayparts && !req.allowedDayparts.includes(auxiliary.daypart)) count++;
  if (auxiliary.weatherState && auxiliary.weatherState !== 'UNKNOWN' && req.allowedWeatherStates && !req.allowedWeatherStates.includes(auxiliary.weatherState)) count++;
  return count;
}

export function situationBucket(mismatchCount: number): SituationBucket {
  return mismatchCount === 0 ? 'A_DIRECT_FIT' : 'B_ACCEPTABLE';
}
