import { flushPromises, shallowMount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  eventBus: {$emit: vi.fn(), $on: vi.fn(), $off: vi.fn()},
  findOrFetch: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({
  default: {groups: {findOrFetch: mocks.findOrFetch}}
}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => false}}));
vi.mock('@/shared/services/event_bus', () => ({default: mocks.eventBus}));
vi.mock('@/shared/services/ability_service', () => ({default: {canEditGroup: () => false}}));
vi.mock('@/shared/services/group_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/mixins/url_for', () => ({default: {methods: {urlFor: () => '/group'}}}));
vi.mock('@/mixins/format_date', () => ({default: {}}));

import GroupPage from '@/components/group/page.vue';

const group = {
  id: 1,
  key: 'test-group',
  name: 'Test group',
  attachments: [],
  parentId: null,
  newHost: null
};

function mountPage() {
  return shallowMount(GroupPage, {
    methods: {titleVisible: () => {}},
    global: {
      mocks: {$route: {params: {key: group.key}}, $t: key => key},
      directives: {intersect: () => {}, t: () => {}},
      stubs: {
        VContainer: {template: '<div><slot /></div>'},
        VMain: {template: '<main><slot /></main>'},
        'router-link': true,
        'router-view': true
      }
    }
  });
}

describe('GroupPage', () => {
  beforeEach(() => {
    mocks.eventBus.$emit.mockReset();
    mocks.eventBus.$on.mockReset();
    mocks.eventBus.$off.mockReset();
    mocks.findOrFetch.mockReset().mockResolvedValue(group);
  });

  it('loads the routed group', async () => {
    const wrapper = mountPage();
    await flushPromises();

    expect(mocks.findOrFetch).toHaveBeenCalledWith(group.key);
    expect(wrapper.vm.group).toMatchObject(group);
  });

  it('reports an authorization failure and prompts signed-out users to sign in', async () => {
    const error = {status: 403};
    mocks.findOrFetch.mockRejectedValue(error);
    mountPage();
    await flushPromises();

    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('openAuthModal');
  });

  it('reloads after sign-in', async () => {
    mountPage();
    await flushPromises();
    const reload = mocks.eventBus.$on.mock.calls.find(([event]) => event === 'signedIn')[1];

    reload();
    await flushPromises();
    expect(mocks.findOrFetch).toHaveBeenCalledTimes(2);
  });
});
