import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {user: vi.fn()}}));
vi.mock('@/shared/services/ability_service', () => ({default: {}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/services/record_loader', () => ({default: vi.fn()}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {watchRecords: vi.fn()}}}));
vi.mock('@/mixins/url_for', () => ({default: {}}));

import MembersPanel from '@/components/group/members_panel.vue';

const routeChanged = MembersPanel.watch['$route.query'];

describe('group members search', () => {
  it('keeps newer typing when the URL catches up with an earlier search', () => {
    const state = {
      $route: {query: {q: 'ab'}}, searchQueryPushed: 'ab', searchQuery: 'abc', searchOpen: true, refresh: vi.fn()
    };

    routeChanged.call(state);

    expect(state.searchQuery).toBe('abc');
    expect(state.refresh).toHaveBeenCalled();
  });

  it('takes the search from the URL after navigation changes it', () => {
    const state = {
      $route: {query: {q: 'maria'}}, searchQueryPushed: 'ab', searchQuery: 'ab', searchOpen: false, refresh: vi.fn()
    };

    routeChanged.call(state);

    expect(state.searchQuery).toBe('maria');
    expect(state.searchOpen).toBe(true);
  });
});
