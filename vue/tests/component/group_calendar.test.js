import { flushPromises, shallowMount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  findOrFetch: vi.fn(), get: vi.fn(), post: vi.fn(), push: vi.fn(), membersInclude: vi.fn()
}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key, locale: {value: 'en'}})}));
vi.mock('vue-router', () => ({useRoute: () => ({params: {key: 'our-group'}}), useRouter: () => ({push: mocks.push})}));
vi.mock('vuetify', () => ({useDisplay: () => ({smAndDown: {value: false}})}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 1, timeZone: 'Pacific/Auckland'})}}));
vi.mock('@/shared/services/records', () => ({default: {groups: {findOrFetch: mocks.findOrFetch}, remote: {get: mocks.get, post: mocks.post}}}));
vi.mock('@/shared/services/ability_service', () => ({default: {canStartPoll: () => true}}));
vi.mock('@/shared/services/flash', () => ({default: {serverError: vi.fn()}}));
vi.mock('@/composables/useWatchRecords', () => ({useWatchRecords: () => ({watchRecords: vi.fn()})}));

import GroupCalendar from '@/components/group/calendar_panel.vue';

describe('group calendar', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.membersInclude.mockReturnValue(true);
    mocks.findOrFetch.mockResolvedValue({id: 12, membersInclude: mocks.membersInclude});
    mocks.get.mockResolvedValue({entries: [{id: 'event-id', name: 'Gathering', kind: 'event',
      start: '2026-10-30T00:00:00Z', end: '2026-10-30T01:00:00Z', timed: true, url: 'https://www.loomio.com/p/meeting'}]});
  });

  it('converts timed entries to the member timezone for the calendar UI', async () => {
    const wrapper = shallowMount(GroupCalendar);
    await flushPromises();
    expect(mocks.get).toHaveBeenCalledWith('groups/12/calendar', expect.objectContaining({start: expect.any(String), end: expect.any(String)}));
    const calendar = wrapper.findComponent({name: 'VCalendar'});
    expect(calendar.props('events')[0].start).toBe('2026-10-30 13:00');
    calendar.vm.$emit('click:event', {}, {event: calendar.props('events')[0]});
    expect(mocks.push).toHaveBeenCalledWith('/p/meeting');
    wrapper.unmount();
  });

  it('does not fetch calendar details for a reader without group membership', async () => {
    mocks.membersInclude.mockReturnValue(false);
    const wrapper = shallowMount(GroupCalendar);
    await flushPromises();
    expect(mocks.get).not.toHaveBeenCalled();
    expect(wrapper.findComponent({name: 'VCalendar'}).exists()).toBe(false);
    wrapper.unmount();
  });
});
