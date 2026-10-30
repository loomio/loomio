import { describe, expect, it } from 'vitest';
import { eventScheduleFromOutcome } from '@/shared/helpers/event_schedule';

describe('creating an event from a Time poll outcome', () => {
  it('uses the Time poll duration default when older polls have no stored duration', () => {
    const source = {meetingDuration: null, defaulted: key => key === 'meetingDuration' ? 60 : null};
    const outcome = {pollOption: () => ({name: '2026-11-02T12:00:00+13:00'})};
    const schedule = eventScheduleFromOutcome(source, outcome, 'Pacific/Auckland');
    expect(schedule.eventStartsAt.toISOString()).toBe('2026-11-01T23:00:00.000Z');
    expect(schedule.eventEndsAt.toISOString()).toBe('2026-11-02T00:00:00.000Z');
    expect(schedule.eventAllDay).toBe(false);
  });

  it('preserves all-day dates across daylight-saving changes', () => {
    const source = {defaulted: () => 60};
    const outcome = {pollOption: () => ({name: '2026-09-27'})};
    const schedule = eventScheduleFromOutcome(source, outcome, 'Pacific/Auckland');
    expect(schedule.eventStartsAt.toISOString()).toBe('2026-09-26T12:00:00.000Z');
    expect(schedule.eventEndsAt.toISOString()).toBe('2026-09-27T11:00:00.000Z');
    expect(schedule.eventAllDay).toBe(true);
  });
});
