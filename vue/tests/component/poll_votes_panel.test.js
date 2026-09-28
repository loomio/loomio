import { flushPromises, mount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { nextTick } from 'vue';

const mocks = vi.hoisted(() => ({
  fetch: vi.fn(),
  canVerifyParticipants: vi.fn(),
  replace: vi.fn(),
  event: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({default: {fetch: mocks.fetch}}));
vi.mock('@/shared/services/ability_service', () => ({default: {canVerifyParticipants: mocks.canVerifyParticipants}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.event}}));
vi.mock('vue-router', () => ({
  useRoute: () => ({query: {}}),
  useRouter: () => ({replace: mocks.replace})
}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: (key, params) => key === 'poll_common_form.voter_page_count'
    ? `${params.first}–${params.last} of ${params.total}` : key})
}));

import VotesPanel from '@/components/poll/common/votes_panel.vue';

const stubs = {
  VTable: {template: '<table><slot /></table>'},
  VAvatar: {template: '<div><slot /></div>'},
  VSelect: {template: '<div />'},
  VTextField: {template: '<div />'},
  VPagination: {template: '<div />'},
  VIcon: {template: '<span />'},
  Loading: {template: '<div />'}
};

const poll = {
  id: 42,
  anonymous: false,
  voteWeightsEnabled: true,
  pollType: 'proposal',
  showResults: () => true,
  pollOptions: () => [{id: 5, optionName: () => 'Agree'}],
  config: () => ({has_options: true}),
  hasVariableScore: () => false
};

function mountPanel(overrides = {}) {
  return mount(VotesPanel, {props: {poll: {...poll, ...overrides}}, global: {stubs}});
}

describe('Poll votes panel', () => {
  beforeEach(() => { vi.clearAllMocks(); });

  it('renders identified votes from the poll votes endpoint', async () => {
    mocks.fetch.mockResolvedValue({
      voters: [{
        voter_id: 1, voter_name: 'Alex', voter_email: 'alex@example.com',
        vote_cast: true, option_scores: {5: 1}, weight: '3',
        member_since: '2024-01-02', inviter_name: 'Morgan', invited_on: '2026-09-22'
      }],
      meta: {total: 1, show_voter_email: true, show_voter_details: true}
    });

    const wrapper = mountPanel();
    await flushPromises();
    await nextTick();

    expect(mocks.fetch).toHaveBeenCalledWith({path: 'polls/42/votes', params: {limit: 25, offset: 0}});
    expect(wrapper.findAll('tbody tr')).toHaveLength(1);
    expect(wrapper.text()).toContain('Alex');
    expect(wrapper.text()).toContain('Agree');
    expect(wrapper.text()).toContain('3');
    expect(wrapper.text()).toContain('alex@example.com');
    expect(wrapper.text()).toContain('Morgan');
  });

  it('does not show anonymous participation status below the threshold', async () => {
    mocks.canVerifyParticipants.mockReturnValue(true);
    mocks.fetch.mockResolvedValue({
      voters: [{voter_id: 1, voter_name: 'Alex', inviter_name: 'Morgan'}],
      meta: {total: 1, show_voter_email: false, show_voter_details: true,
        participation_status_visible: false, participation_status_votes_min: 3}
    });

    const wrapper = mountPanel({anonymous: true, voteWeightsEnabled: false});
    await flushPromises();
    await nextTick();

    expect(mocks.fetch).toHaveBeenCalledWith({path: 'polls/42/votes', params: {limit: 25, offset: 0}});
    expect(wrapper.findAll('tbody tr')).toHaveLength(1);
    expect(wrapper.text()).toContain('Morgan');
    expect(wrapper.text()).not.toContain('poll_receipts_page.vote_cast');
  });

  it('does not request anonymous voter records for an unauthorized viewer', () => {
    mocks.canVerifyParticipants.mockReturnValue(false);
    const wrapper = mountPanel({anonymous: true});
    expect(mocks.fetch).not.toHaveBeenCalled();
    expect(wrapper.text()).toContain('poll_common_votes_panel.participation_records_restricted');
  });

  it('shows the result range beside pagination', async () => {
    mocks.fetch.mockResolvedValue({voters: [], meta: {total: 50}});

    const wrapper = mountPanel();
    await flushPromises();

    expect(wrapper.text()).toContain('1–25 of 50');
    expect(wrapper.find('.poll-common-votes-panel__pagination').exists()).toBe(true);
  });
});
