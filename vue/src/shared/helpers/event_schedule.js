import { addDays, addMinutes, format, parseISO } from 'date-fns';
import { zonedTimeToUtc } from 'date-fns-tz';

export function eventScheduleFromOutcome(source, outcome, timeZone) {
  const name = outcome.pollOption().name;
  const eventAllDay = /^\d{4}-\d{2}-\d{2}$/.test(name);
  const eventStartsAt = eventAllDay ? zonedTimeToUtc(name, timeZone) : parseISO(name);
  const eventEndsAt = eventAllDay
    ? zonedTimeToUtc(format(addDays(parseISO(name), 1), 'yyyy-MM-dd'), timeZone)
    : addMinutes(eventStartsAt, source.defaulted('meetingDuration'));
  return {eventStartsAt, eventEndsAt, eventAllDay, timeZone};
}
