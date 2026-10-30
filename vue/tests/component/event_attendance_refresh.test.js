import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({fetchById: vi.fn()}));
vi.mock('@/shared/services/records', () => ({default: {polls: {remote: {fetchById: mocks.fetchById}}}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 2})}}));
vi.mock('@/i18n', () => ({I18n: {}}));
vi.mock('@/shared/services/app_config', () => ({default: {currentUserId: 2}}));

import PollModel from '@/shared/models/poll_model';

describe('current attendance after a calendar revision', () => {
  beforeEach(() => { mocks.fetchById.mockReset().mockResolvedValue({}); });

  it('fetches the member’s current stance after a shared calendar update', () => {
    const poll = new PollModel({id: 12, pollType: 'event', calendarSequence: 0, myStanceId: 5});
    expect(mocks.fetchById).not.toHaveBeenCalled();
    poll.update({calendarSequence: 1});
    expect(mocks.fetchById).toHaveBeenCalledExactlyOnceWith(12);
    poll.update({calendarSequence: 1, myStanceId: 6});
    expect(mocks.fetchById).toHaveBeenCalledTimes(1);
    expect(poll.myStanceId).toBe(6);
  });

  it('leaves ordinary poll updates on the existing path', () => {
    const poll = new PollModel({id: 12, pollType: 'availability', calendarSequence: 0});
    poll.update({calendarSequence: 1});
    expect(mocks.fetchById).not.toHaveBeenCalled();
  });
});
