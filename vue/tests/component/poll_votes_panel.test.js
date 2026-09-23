import { flushPromises, shallowMount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  fetch: vi.fn(),
  findByIds: vi.fn(),
  canVerifyParticipants: vi.fn(),
  replace: vi.fn(),
  event: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({
  default: {fetch: mocks.fetch, stances: {findByIds: mocks.findByIds}}
}));
vi.mock('@/shared/services/ability_service', () => ({
  default: {canVerifyParticipants: mocks.canVerifyParticipants}
}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.event}}));
vi.mock('vue-router', () => ({
  useRoute: () => ({query: {}}),
  useRouter: () => ({replace: mocks.replace})
}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import VotesPanel from '@/components/poll/common/votes_panel.vue';

const stubs = {
  VTable: {template: '<table><slot /></table>'},
  VAlert: {template: '<div><slot /></div>'},
  VAvatar: {template: '<div><slot /></div>'},
  VSelect: {template: '<div />'},
  VTextField: {template: '<div />'},
  VPagination: true,
  UserAvatar: true,
  TimeAgo: true,
  Loading: true
};

const identifiedPoll = {
  id: 42,
  anonymous: false,
  weightedVoting: true,
  showResults: () => true,
  pollOptions: () => [],
  config: () => ({has_options: true}),
  hasVariableScore: () => false
};

function mountPanel(poll) {
  return shallowMount(VotesPanel, {props: {poll}, global: {stubs}});
}

describe('Poll votes panel', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders the identified voter rows returned by the paginated API', async () => {
    const stance = {
      id: 7,
      participantId: 1,
      weight: 3,
      reason: 'A private reason that does not belong in the table',
      castAt: '2026-09-23T10:00:00Z',
      participant: () => ({id: 1, name: 'Alex'}),
      participantName: () => 'Alex',
      sortedChoices: () => [{show: true, pollOption: {id: 5, optionName: () => 'Agree'}}]
    };
    mocks.fetch.mockResolvedValue({stances: [{id: 7}], meta: {
      total: 1, show_voter_email: true, show_voter_details: true,
      voter_details_by_user_id: {1: {
        voter_email: 'alex@example.com', member_since: '2024-01-02',
        inviter_name: 'Morgan', invited_on: '2026-09-22'
      }}
    }});
    mocks.findByIds.mockReturnValue([stance]);

    const wrapper = mountPanel(identifiedPoll);
    await flushPromises();

    expect(mocks.fetch).toHaveBeenCalledWith({
      path: 'stances',
      params: {per: 50, poll_id: 42, from: 0}
    });
    expect(wrapper.findAll('tbody tr')).toHaveLength(1);
    expect(wrapper.text()).toContain('Alex');
    expect(wrapper.text()).toContain('Agree');
    expect(wrapper.text()).toContain('3');
    expect(wrapper.text()).toContain('alex@example.com');
    expect(wrapper.text()).toContain('poll_receipts_page.email_addresses_for_group_admins');
    expect(wrapper.text()).toContain('2024-01-02');
    expect(wrapper.text()).toContain('Morgan');
    expect(wrapper.text()).toContain('2026-09-22');
    expect(wrapper.text()).not.toContain(stance.reason);
    expect(wrapper.findAll('thead th').map(cell => cell.text()).slice(1)).toEqual([
      'poll_receipts_page.voter_name', 'poll_receipts_page.voter_email',
      'poll_common_votes_panel.stance', 'poll_common_votes_panel.vote_weight_column',
      'poll_common_votes_panel.vote_date', 'poll_receipts_page.member_since',
      'poll_receipts_page.invited_by', 'poll_receipts_page.invited_on'
    ]);
  });

  it.each([
    ['proposal', 'Agree', 1, null, false, 'Agree'],
    ['poll', 'North', 1, null, false, 'North'],
    ['score', 'North', 4, null, true, 'North(4)'],
    ['dot_vote', 'North', 3, null, true, 'North(3)'],
    ['ranked_choice', 'North', 3, 1, true, '1. North']
  ])('shows the %s vote and its weight in adjacent columns', async (pollType, optionName, score, rank, variableScore, expectedVote) => {
    const choice = {show: true, score, rank, pollOption: {id: 5, optionName: () => optionName}};
    const stance = {
      id: 7,
      participantId: 1,
      weight: '2.33',
      castAt: '2026-09-23T10:00:00Z',
      participant: () => ({id: 1, name: 'Alex'}),
      participantName: () => 'Alex',
      sortedChoices: () => [choice]
    };
    mocks.fetch.mockResolvedValue({stances: [{id: 7}], meta: {total: 1}});
    mocks.findByIds.mockReturnValue([stance]);

    const wrapper = mountPanel({
      ...identifiedPoll, pollType,
      hasVariableScore: () => variableScore
    });
    await flushPromises();

    const cells = wrapper.findAll('tbody tr td');
    expect(cells[2].text()).toBe(expectedVote);
    expect(cells[3].text()).toBe('2.33');
  });

  it('keeps anonymous participation status hidden below the threshold', async () => {
    mocks.canVerifyParticipants.mockReturnValue(true);
    mocks.fetch.mockResolvedValue({
      receipts: [{voter_id: 1, voter_name: 'Alex', inviter_name: 'Morgan', invited_on: '2026-09-22'}],
      voters_count: 1,
      show_voter_email: false,
      participation_status_visible: false,
      participation_status_votes_min: 3
    });

    const wrapper = mountPanel({...identifiedPoll, anonymous: true});
    await flushPromises();

    expect(mocks.fetch).toHaveBeenCalledWith({path: 'polls/42/receipts'});
    expect(wrapper.findAll('tbody tr')).toHaveLength(1);
    expect(wrapper.text()).toContain('Morgan');
    expect(wrapper.text()).not.toContain('poll_receipts_page.vote_cast');
    expect(wrapper.text()).not.toContain('poll_receipts_page.email_addresses_for_group_admins');
  });

  it('explains why email addresses appear in an admin’s anonymous participation view', async () => {
    mocks.canVerifyParticipants.mockReturnValue(true);
    mocks.fetch.mockResolvedValue({
      receipts: [{voter_id: 1, voter_name: 'Alex', voter_email: 'alex@example.com'}],
      voters_count: 1,
      show_voter_email: true,
      participation_status_visible: false,
      participation_status_votes_min: 3
    });

    const wrapper = mountPanel({...identifiedPoll, anonymous: true});
    await flushPromises();

    expect(wrapper.text()).toContain('poll_receipts_page.email_addresses_for_group_admins');
    expect(wrapper.text()).toContain('poll_receipts_page.voter_email');
    expect(wrapper.text()).toContain('alex@example.com');
  });

  it('does not fetch anonymous participation records for other viewers', () => {
    mocks.canVerifyParticipants.mockReturnValue(false);

    const wrapper = mountPanel({...identifiedPoll, anonymous: true});

    expect(mocks.fetch).not.toHaveBeenCalled();
    expect(wrapper.text()).toContain('poll_common_votes_panel.participation_records_restricted');
  });
});
