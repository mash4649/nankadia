import { describe, expect, test } from 'bun:test';
import { qualifiesSelfMoment } from '../src/self-moment';

const base = {
  explicitlyStarted: true,
  entryOrigin: 'DIRECT' as const,
  day0LocalDate: '2026-09-01',
  timeZone: 'Asia/Tokyo',
};

describe('SELF_MOMENT qualifier', () => {
  test('accepts explicit DIRECT moments on local days 1 through 14', () => {
    expect(qualifiesSelfMoment({ ...base, occurredAt: '2026-09-02T00:00:00Z' })).toBe(true);
    expect(qualifiesSelfMoment({ ...base, occurredAt: '2026-09-15T00:00:00Z' })).toBe(true);
  });

  test('rejects same-day, day 15, external origins, and implicit moments', () => {
    expect(qualifiesSelfMoment({ ...base, occurredAt: '2026-09-01T14:00:00Z' })).toBe(false);
    expect(qualifiesSelfMoment({ ...base, occurredAt: '2026-09-16T00:00:00Z' })).toBe(false);
    expect(qualifiesSelfMoment({ ...base, entryOrigin: 'EXTERNAL_SHARE', occurredAt: '2026-09-02T00:00:00Z' })).toBe(false);
    expect(qualifiesSelfMoment({ ...base, explicitlyStarted: false, occurredAt: '2026-09-02T00:00:00Z' })).toBe(false);
  });

  test('uses the supplied timezone at a calendar-day boundary', () => {
    const pacific = { ...base, day0LocalDate: '2026-09-01', timeZone: 'America/Los_Angeles' };
    expect(qualifiesSelfMoment({ ...pacific, occurredAt: '2026-09-02T06:30:00Z' })).toBe(false);
    expect(qualifiesSelfMoment({ ...pacific, occurredAt: '2026-09-02T07:30:00Z' })).toBe(true);
  });
});
