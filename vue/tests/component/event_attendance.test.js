import { flushPromises, mount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { reactive } from 'vue';

const mocks = vi.hoisted(() => ({fetch: vi.fn(), sync: null}));
vi.mock('@/shared/services/records', () => ({default: {fetch: mocks.fetch}}));
vi.mock('@/composables/useWatchRecords', () => ({useWatchRecords: () => ({watchRecords: ({query}) => {
  mocks.sync = query;
  query();
}})}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => ({
  'calendar.going': 'Going', 'calendar.maybe': 'Maybe', 'calendar.not_attending': 'Not attending',
  'calendar.no_response': 'No response', 'calendar.show_more': 'Show more'
})[key] || key})}));

import Attendance from '@/components/poll/event/attendance.vue';

function voter(id, option) {
  return {voter_id: id, voter_name: `Person ${id}`, voter_avatar_initials: `P${id}`,
    voter_thumb_url: null, vote_cast: true, option_scores: {[option]: 1}};
}
const settle = async () => { await new Promise(resolve => setTimeout(resolve, 120)); await flushPromises(); };

function panel({hideVoters = false, ...overrides} = {}) {
  const poll = reactive({id: 10, showResults: () => true, results: [
    {id: 1, icon: 'agree', vote_count: 2, color: 'green'},
    {id: 2, icon: 'abstain', vote_count: 1, color: 'yellow'},
    {id: 3, icon: 'disagree', vote_count: 0, color: 'red'},
    {id: -1, vote_count: 5}
  ], ...overrides});
  const wrapper = mount(Attendance, {props: {poll, hideVoters}, global: {stubs: {
    VTooltip: {template: '<div><slot name="activator" :props="{}" /></div>'},
    VAvatar: {template: '<span class="test-avatar"><slot /></span>'},
    VBtn: {props: ['loading'], template: '<button :disabled="loading"><slot /></button>'}
  }}});
  return {wrapper, poll};
}

describe('Event attendance crowds', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.fetch.mockImplementation(({params}) => Promise.resolve({voters:
      params.poll_option_id === 1 ? [voter(1, 1), voter(2, 1)] : [voter(3, 2)]}));
  });

  it('groups avatars into three crowds and keeps no response separate', async () => {
    const {wrapper} = panel();
    await settle();
    expect(wrapper.findAll('h3').map(heading => heading.findAll('span').map(span => span.text()))).toEqual([['Going', '2'], ['Maybe', '1'], ['Not attending', '0']]);
    expect(wrapper.findAll('.poll-event-attendance__group')).toHaveLength(3);
    expect(wrapper.findAll('.poll-event-attendance__group--agree .test-avatar')).toHaveLength(2);
    expect(wrapper.findAll('.poll-event-attendance__group--abstain .test-avatar')).toHaveLength(1);
    expect(wrapper.get('.test-avatar').attributes('aria-label')).toBe('Person 1');
    expect(wrapper.get('.poll-event-attendance__no-response').text()).toBe('No response: 5');
    expect(mocks.fetch).toHaveBeenCalledTimes(2);
    wrapper.unmount();
  });

  it('loads larger crowds in bounded pages without reducing the attendance count', async () => {
    mocks.fetch.mockImplementation(({params}) => Promise.resolve({voters:
      Array.from({length: params.offset ? 5 : 50}, (_, index) => voter(params.offset + index + 1, 1))}));
    const {wrapper} = panel({results: [{id: 1, icon: 'agree', vote_count: 55, color: 'green'}]});
    await settle();
    expect(wrapper.findAll('.test-avatar')).toHaveLength(50);
    expect(wrapper.get('.poll-event-attendance__count').text()).toBe('55');
    await wrapper.get('button').trigger('click');
    await flushPromises();
    expect(mocks.fetch).toHaveBeenLastCalledWith({path: 'polls/10/votes', params: {poll_option_id: 1, limit: 50, offset: 50}});
    expect(wrapper.findAll('.test-avatar')).toHaveLength(55);
    expect(wrapper.find('button').exists()).toBe(false);
    wrapper.unmount();
  });

  it('shows counts without fetching identities when voters are hidden', async () => {
    const {wrapper} = panel({hideVoters: true});
    await settle();
    expect(mocks.fetch).not.toHaveBeenCalled();
    expect(wrapper.get('.poll-event-attendance__count').text()).toBe('2');
    expect(wrapper.find('.test-avatar').exists()).toBe(false);
    wrapper.unmount();
  });

  it('does not expose attendance or request identities before results are visible', async () => {
    const {wrapper} = panel({showResults: () => false});
    await settle();
    expect(mocks.fetch).not.toHaveBeenCalled();
    expect(wrapper.text()).toBe('');
    wrapper.unmount();
  });

  it('ignores in-flight avatars from the previous schedule', async () => {
    let resolve;
    mocks.fetch.mockImplementation(() => new Promise(done => { resolve = done; }));
    const {wrapper, poll} = panel({results: [{id: 1, icon: 'agree', vote_count: 1}]});
    await settle();
    poll.results = [{id: 1, icon: 'agree', vote_count: 0}];
    mocks.sync();
    resolve({voters: [voter(1, 1)]});
    await flushPromises();
    expect(wrapper.find('.test-avatar').exists()).toBe(false);
    expect(wrapper.get('.poll-event-attendance__count').text()).toBe('0');
    wrapper.unmount();
  });
});
