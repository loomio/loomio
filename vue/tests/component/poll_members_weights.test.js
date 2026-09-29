import { flushPromises, shallowMount } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  patch: vi.fn(),
  fetch: vi.fn(),
  fetchById: vi.fn(),
  success: vi.fn(),
  fromServer: vi.fn(),
  users: {}
}));

vi.mock('@/shared/services/records', () => ({
  default: {
    remote: {patch: mocks.patch},
    fetch: mocks.fetch,
    polls: {remote: {fetchById: mocks.fetchById}},
    users: {findById: id => mocks.users[id]}
  }
}));
vi.mock('@/shared/services/flash', () => ({default: {success: mocks.success, fromServer: mocks.fromServer}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 1})}}));
vi.mock('@/shared/services/stance_service', () => ({default: {}}));
vi.mock('@/composables/useWatchRecords', () => ({useWatchRecords: () => ({watchRecords: vi.fn()})}));
vi.mock('@/components/common/recipients_autocomplete', () => ({default: {template: '<div />'}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import PollMembers from '@/components/poll/members.vue';

function buildPoll(overrides = {}) {
  return {
    id: 42, groupId: 8, weightedVoting: true, closedAt: null, openingAt: null, openedAt: '2026-09-28',
    recipientAudience: null, recipientUserIds: [], recipientEmails: [], recipientChatbotIds: [],
    adminsInclude: () => true, detachedAnonymousVoting: () => false, group: () => ({id: 8}),
    ...overrides
  };
}

async function mountMembers(poll) {
  const wrapper = shallowMount(PollMembers, {props: {poll}});
  vi.advanceTimersByTime(300);
  await flushPromises();
  return wrapper;
}

describe('poll voter weights', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.clearAllMocks();
    mocks.users = {7: {id: 7, nameOrEmail: () => 'Alex'}};
    mocks.fetch.mockResolvedValue({
      users: [{id: 7}],
      meta: {total: 1, guest_ids: [], group_admin_ids: [], topic_admin_ids: [], stance_ids_by_user_id: {7: 9}, weights_by_user_id: {7: '1'}}
    });
    mocks.patch.mockResolvedValue({});
    mocks.fetchById.mockResolvedValue({});
  });

  afterEach(() => vi.useRealTimers());

  it('pages voters with limit and offset and shows server weights', async () => {
    const wrapper = await mountMembers(buildPoll());

    expect(mocks.fetch).toHaveBeenCalledWith({path: 'stances/users', params: expect.objectContaining({poll_id: 42, offset: 0, limit: 50})});
    expect(wrapper.vm.$.setupState.weightsByUserId[7]).toBe('1');
  });

  it('copies member weights for every voter in a group poll', async () => {
    const state = (await mountMembers(buildPoll())).vm.$.setupState;

    state.openSetAllDialog();
    expect(state.weightMode).toBe('membership');
    state.resetWeights();
    await flushPromises();

    expect(mocks.patch).toHaveBeenCalledWith('stances/reset_weights', {poll_id: 42, mode: 'membership'});
    expect(state.setAllDialog).toBe(false);
  });

  it('uses one chosen weight in a direct poll', async () => {
    const state = (await mountMembers(buildPoll({groupId: null}))).vm.$.setupState;

    state.openSetAllDialog();
    expect(state.weightMode).toBe('value');
    state.resetWeight = '2.33';
    state.resetWeights();
    await flushPromises();

    expect(mocks.patch).toHaveBeenCalledWith('stances/reset_weights', {poll_id: 42, mode: 'value', weight: '2.33'});
  });

  it('shows the weight the server saved rather than the typed value', async () => {
    mocks.patch.mockResolvedValue({stances: [{id: 9, weight: '1.5'}]});
    const state = (await mountMembers(buildPoll())).vm.$.setupState;

    state.openWeightDialog(mocks.users[7]);
    state.weightValue = '1.50';
    state.saveWeight();
    await flushPromises();

    expect(mocks.patch).toHaveBeenCalledWith('stances/9/set_weight', {weight: '1.50'});
    expect(state.weightsByUserId[7]).toBe('1.5');
    expect(state.weightDialog).toBe(false);
  });
});
