export type EntryOrigin =
  | 'DIRECT'
  | 'EXTERNAL_SHARE'
  | 'NOTIFICATION'
  | 'CAMPAIGN'
  | 'OTHER_DEEPLINK'
  | 'UNKNOWN';

const dayKeyFormatterCache = new Map<string, Intl.DateTimeFormat>();

function localDayKey(instant: Date, timeZone: string): string {
  let formatter = dayKeyFormatterCache.get(timeZone);
  if (!formatter) {
    formatter = new Intl.DateTimeFormat('en-US', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    });
    dayKeyFormatterCache.set(timeZone, formatter);
  }
  const parts = Object.fromEntries(
    formatter.formatToParts(instant).map(({ type, value }) => [type, value]),
  );
  return `${parts.year}-${parts.month}-${parts.day}`;
}

function dayNumber(dayKey: string): number {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dayKey)) {
    throw new RangeError(`invalid local date: ${dayKey}`);
  }
  const [year, month, day] = dayKey.split('-').map(Number);
  const value = Date.UTC(year, month - 1, day);
  const check = new Date(value);
  if (
    check.getUTCFullYear() !== year
    || check.getUTCMonth() !== month - 1
    || check.getUTCDate() !== day
  ) throw new RangeError(`invalid local date: ${dayKey}`);
  return value / 86_400_000;
}

export interface SelfMomentInput {
  explicitlyStarted: boolean;
  entryOrigin: EntryOrigin;
  day0LocalDate: string;
  occurredAt: string;
  timeZone: string;
}

export function qualifiesSelfMoment(input: SelfMomentInput): boolean {
  if (!input.explicitlyStarted || input.entryOrigin !== 'DIRECT') return false;
  const occurred = new Date(input.occurredAt);
  if (Number.isNaN(occurred.getTime())) throw new RangeError('invalid occurredAt');
  const dayOffset = dayNumber(localDayKey(occurred, input.timeZone)) - dayNumber(input.day0LocalDate);
  return dayOffset >= 1 && dayOffset <= 14;
}
