import { flushPromises } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  patch: vi.fn(),
  fetchById: vi.fn(),
  success: vi.fn(),
  fromServer: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({
  default: {remote: {patch: mocks.patch}, polls: {remote: {fetchById: mocks.fetchById}}}
}));
vi.mock('@/shared/services/flash', () => ({default: {success: mocks.success, fromServer: mocks.fromServer}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/services/session', () => ({default: {user: vi.fn()}}));
vi.mock('@/shared/services/stance_service', () => ({default: {}}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {watchRecords: vi.fn()}}}));
vi.mock('@/components/common/recipients_autocomplete', () => ({default: {template: '<div />'}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import PollMembers from '@/components/poll/members.vue';

describe('poll voter bulk weights', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.patch.mockResolvedValue({});
    mocks.fetchById.mockResolvedValue({});
  });

  it('opens with member weights for a group poll and copies them for every voter', async () => {
    const state = {
      poll: {id: 42, groupId: 8}, canUseMemberWeights: true,
      weightMode: 'value', resetWeight: '3', setAllDialog: false,
      weightsByUserId: {1: '2'}, weightsSavedByUserId: {1: '1'},
      weightsSaving: false, fetchStances: vi.fn()
    };

    PollMembers.methods.openSetAllDialog.call(state);
    expect(state.weightMode).toBe('membership');
    expect(state.setAllDialog).toBe(true);

    PollMembers.methods.resetWeights.call(state);
    await flushPromises();

    expect(mocks.patch).toHaveBeenCalledWith('stances/reset_weights', {poll_id: 42, mode: 'membership'});
    expect(state.setAllDialog).toBe(false);
    expect(state.fetchStances).toHaveBeenCalled();
  });

  it('uses a chosen weight for a direct poll', async () => {
    const state = {
      poll: {id: 42, groupId: null}, canUseMemberWeights: false,
      weightMode: 'membership', resetWeight: '2.33', setAllDialog: false,
      weightsByUserId: {}, weightsSavedByUserId: {},
      weightsSaving: false, fetchStances: vi.fn()
    };

    PollMembers.methods.openSetAllDialog.call(state);
    expect(state.weightMode).toBe('value');

    PollMembers.methods.resetWeights.call(state);
    await flushPromises();

    expect(mocks.patch).toHaveBeenCalledWith('stances/reset_weights', {poll_id: 42, mode: 'value', weight: '2.33'});
  });
});
