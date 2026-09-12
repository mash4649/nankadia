import { describe, expect, test } from 'bun:test';
import {
  nextNonRequiredQuestion,
  nextSnapshotVersion,
  resolveMomentMode,
} from '../src/moment-context';

describe('Moment Mode resolver', () => {
  test('resolves trajectory and detour without persisting a mode object', () => {
    expect(resolveMomentMode('RETURNING_HOME_SMALL')).toEqual({
      trajectory: 'RETURNING_HOME',
      detour: 'SMALL',
      source: 'USER_EXPLICIT',
    });
    expect(resolveMomentMode('EN_ROUTE_FIXED_NONE')).toEqual({
      trajectory: 'EN_ROUTE_FIXED',
      detour: 'NONE',
      source: 'USER_EXPLICIT',
    });
    expect(resolveMomentMode('WAITING_SMALL')).toEqual({
      trajectory: 'WAITING',
      detour: 'SMALL',
      source: 'USER_EXPLICIT',
    });
    expect(resolveMomentMode('STAYING_NONE')).toEqual({
      trajectory: 'STAYING',
      detour: 'NONE',
      source: 'USER_EXPLICIT',
    });
    expect(resolveMomentMode('OPEN_ENDED_OPEN')).toEqual({
      trajectory: 'OPEN_ENDED',
      detour: 'OPEN',
      source: 'USER_EXPLICIT',
    });
  });
});

describe('non-required question budget', () => {
  test('prioritizes Moment Mode and never asks a second question', () => {
    expect(nextNonRequiredQuestion({
      nonRequiredQuestionsAsked: 0,
      momentModeUnresolved: true,
      immediateNeedMaterial: true,
    })).toBe('MOMENT_MODE');
    expect(nextNonRequiredQuestion({
      nonRequiredQuestionsAsked: 1,
      momentModeUnresolved: false,
      immediateNeedMaterial: true,
    })).toBeNull();
  });
});

describe('immutable context snapshots', () => {
  test('correction/revalidation receives a new monotonically increasing version', () => {
    expect(nextSnapshotVersion([])).toBe(1);
    expect(nextSnapshotVersion([1])).toBe(2);
    expect(nextSnapshotVersion([1, 3])).toBe(4);
  });
});
