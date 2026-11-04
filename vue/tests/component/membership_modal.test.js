import { shallowMount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({update: vi.fn(() => Promise.resolve())}));

vi.mock('@/shared/services/records', () => ({default: {memberships: {remote: {update: mocks.update}}}}));
vi.mock('@/shared/services/flash', () => ({default: {success: vi.fn(), fromServer: vi.fn()}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import MembershipModal from '@/components/group/membership_modal.vue';

describe('membership modal', () => {
  beforeEach(() => vi.clearAllMocks());

  // Vote weights are edited together on the member weights page, so this
  // dialog must never send the weight it was opened with.
  it('sends only the title', () => {
    const membership = {id: 7, title: 'Member', weight: '2', user: () => ({name: 'Alex'})};
    const wrapper = shallowMount(MembershipModal, {props: {membership}});
    membership.title = 'Treasurer';

    wrapper.vm.$.setupState.submit();

    expect(mocks.update).toHaveBeenCalledWith(7, {membership: {title: 'Treasurer'}});
  });
});
