import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {user: vi.fn()}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/services/record_loader', () => ({default: vi.fn()}));

import { syncSearchFromQuery } from '@/components/group/members_panel.vue';

describe('group members search', () => {
  it('keeps newer typing when the URL catches up with an earlier search', () => {
    const state = {
      searchQueryPushed: 'ab', searchQuery: 'abc', searchOpen: true
    };

    syncSearchFromQuery(state, 'ab');

    expect(state.searchQuery).toBe('abc');
  });

  it('takes the search from the URL after navigation changes it', () => {
    const state = {
      searchQueryPushed: 'ab', searchQuery: 'ab', searchOpen: false
    };

    syncSearchFromQuery(state, 'maria');

    expect(state.searchQuery).toBe('maria');
    expect(state.searchOpen).toBe(true);
  });
});
