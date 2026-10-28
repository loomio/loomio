import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { addDays, startOfHour } from 'date-fns';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 2})}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import PollModel from '@/shared/models/poll_model';

describe('copying a poll', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 9, 29, 10, 30));
  });

  afterEach(() => vi.useRealTimers());

  it.each([
    ['open', {openingAt: null, openedAt: new Date(2026, 9, 20), closedAt: null}],
    ['closed', {openingAt: new Date(2026, 9, 19), openedAt: new Date(2026, 9, 20), closedAt: new Date(2026, 9, 21)}],
    ['scheduled', {openingAt: new Date(2026, 10, 1), openedAt: null, closedAt: null}],
    ['draft', {openingAt: null, openedAt: null, closedAt: null}]
  ])('starts a copy of a %s poll with fresh voting dates and preserves its content', (_state, dates) => {
    const source = new PollModel({
      id: 10, key: 'source', authorId: 1, groupId: 7, topicId: 8,
      title: 'Consent proposal', details: 'Proposed changes', pollType: 'proposal',
      closingAt: new Date(2026, 10, 5), defaultDurationInDays: 3,
      pollOptionsAttributes: [{name: 'Consent', meaning: 'I support this proposal', prompt: 'Any concerns?'}],
      ...dates
    });

    const copy = source.clonePoll();

    expect(copy.isNew()).toBe(true);
    expect(copy.key).toBe(null);
    expect(copy.sourceTemplateId).toBe(source.id);
    expect(copy.authorId).toBe(2);
    expect(copy.groupId).toBe(null);
    expect(copy.topicId).toBe(null);
    expect(copy.openingAt).toBe(null);
    expect(copy.openedAt).toBe(null);
    expect(copy.closedAt).toBe(null);
    expect(copy.isVotable()).toBe(false);
    expect(copy.closingAt).toEqual(startOfHour(addDays(new Date(), 3)));
    expect(copy.title).toBe(source.title);
    expect(copy.details).toBe(source.details);
    expect(copy.pollOptionsAttributes).toEqual(source.pollOptionsAttributes);
    expect(source.openingAt).toEqual(dates.openingAt);
    expect(source.openedAt).toEqual(dates.openedAt);
    expect(source.closedAt).toEqual(dates.closedAt);
  });
});
