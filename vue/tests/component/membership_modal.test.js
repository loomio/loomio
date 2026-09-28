import { shallowMount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({update: vi.fn(() => Promise.resolve())}));

vi.mock('@/shared/services/records', () => ({default: {memberships: {remote: {update: mocks.update}}}}));
vi.mock('@/shared/services/ability_service', () => ({default: {canAdminister: () => true}}));
vi.mock('@/shared/services/flash', () => ({default: {success: vi.fn(), fromServer: vi.fn()}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import MembershipModal from '@/components/group/membership_modal.vue';

function mountModal(membership) {
  return shallowMount(MembershipModal, {props: {membership}});
}

function weightedMembership(overrides = {}) {
  return {
    id: 7,
    title: 'Member',
    weight: '2',
    group: () => ({voteWeightsAllowed: true}),
    user: () => ({name: 'Alex'}),
    ...overrides
  };
}

describe('membership modal', () => {
  beforeEach(() => vi.clearAllMocks());

  it('leaves the weight out when only the title changes', () => {
    const membership = weightedMembership();
    const wrapper = mountModal(membership);
    membership.title = 'Treasurer';

    wrapper.vm.$.setupState.submit();

    expect(mocks.update).toHaveBeenCalledWith(7, {membership: {title: 'Treasurer'}});
  });

  it('sends a changed weight', () => {
    const membership = weightedMembership();
    const wrapper = mountModal(membership);
    membership.weight = '2.5';

    wrapper.vm.$.setupState.submit();

    expect(mocks.update).toHaveBeenCalledWith(7, {membership: {title: 'Member', weight: '2.5'}});
  });

  it('does not submit an invalid weight', () => {
    const membership = weightedMembership({weight: '-1'});
    const wrapper = mountModal(membership);

    wrapper.vm.$.setupState.submit();

    expect(mocks.update).not.toHaveBeenCalled();
  });
});
