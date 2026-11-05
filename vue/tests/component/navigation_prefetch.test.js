import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  signedIn: vi.fn(), topics: vi.fn(), polls: vi.fn(), stances: vi.fn(), notifications: vi.fn(), viewed: vi.fn()
}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: mocks.signedIn}}));
vi.mock('@/shared/services/records', () => ({default: {
  topics: {fetch: mocks.topics}, polls: {fetch: mocks.polls}, stances: {fetch: mocks.stances},
  notifications: {fetchNotifications: mocks.notifications, viewed: mocks.viewed}
}}));
vi.mock('@/components/notifications/page.vue', () => ({default: {}}));
vi.mock('@/components/dashboard/polls_to_vote_on_page.vue', () => ({default: {}}));

import { prefetchNavigation } from '@/shared/services/navigation_data';

describe('navigation prefetch', () => {
  beforeEach(() => { vi.clearAllMocks(); mocks.signedIn.mockReturnValue(true); });

  it('warms bounded first pages without marking notifications viewed', async () => {
    await prefetchNavigation();
    expect(mocks.topics).toHaveBeenCalledWith({params: {limit: 30, offset: 0, order: 'id', exclude_types: 'reaction'}});
    expect(mocks.polls).toHaveBeenCalledWith({params: {limit: 25, offset: 0, order: 'id', exclude_types: 'group reaction', status: 'recent'}});
    expect(mocks.stances).toHaveBeenCalledWith({path: 'my_stances'});
    expect(mocks.notifications).toHaveBeenCalledOnce();
    expect(mocks.viewed).not.toHaveBeenCalled();
  });

  it('does not fetch private navigation resources while signed out', async () => {
    mocks.signedIn.mockReturnValue(false);
    await prefetchNavigation();
    expect(mocks.topics).not.toHaveBeenCalled();
    expect(mocks.polls).not.toHaveBeenCalled();
    expect(mocks.stances).not.toHaveBeenCalled();
    expect(mocks.notifications).not.toHaveBeenCalled();
  });

  it('allows other prefetches to finish if one fails', async () => {
    mocks.topics.mockRejectedValueOnce(new Error('offline'));
    const results = await prefetchNavigation();
    expect(results[0].status).toBe('rejected');
    expect(results.slice(1).every(result => result.status === 'fulfilled')).toBe(true);
  });
});
