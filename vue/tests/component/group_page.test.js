import { defineComponent, nextTick, reactive } from 'vue';
import { flushPromises, shallowMount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  route: {params: {key: 'cached-group'}},
  groupCurrent: null,
  groupFetch: null,
  watchRecordsQuery: null,
  eventBus: {$emit: vi.fn(), $on: vi.fn(), $off: vi.fn()},
  fetchById: vi.fn(),
  fuzzyFind: vi.fn()
}));

vi.mock('vue-router', () => ({useRoute: () => reactive(mocks.route)}));
vi.mock('@/shared/services/records', () => ({
  default: {groups: {fuzzyFind: mocks.fuzzyFind, remote: {fetchById: mocks.fetchById}}}
}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => false}}));
vi.mock('@/shared/services/event_bus', () => ({default: mocks.eventBus}));
vi.mock('@/shared/services/ability_service', () => ({default: {canEditGroup: () => false}}));
vi.mock('@/shared/services/group_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/shared/services/lmo_url_service', () => ({default: {route: () => '/cached-group'}}));
vi.mock('@/composables/useWatchRecords', () => ({
  useWatchRecords: () => ({watchRecords: ({query}) => { mocks.watchRecordsQuery = query; }})
}));

import GroupPage from '@/components/group/page.vue';

const RoutedPanel = defineComponent({
  name: 'RoutedPanel',
  props: {group: Object},
  template: '<div class="routed-panel">{{ group.name }}</div>'
});
const RouterView = defineComponent({
  name: 'RouterView',
  setup(_, {slots}) {
    return () => slots.default({Component: RoutedPanel});
  }
});

function deferred() {
  let resolve;
  let reject;
  const promise = new Promise((resolvePromise, rejectPromise) => {
    resolve = resolvePromise;
    reject = rejectPromise;
  });
  return {promise, reject, resolve};
}

function mountPage() {
  return shallowMount(GroupPage, {
    global: {
      mocks: {$t: key => key},
      directives: {intersect: () => {}, t: () => {}},
      stubs: {
        VContainer: {template: '<div><slot /></div>'},
        VMain: {template: '<main><slot /></main>'},
        'router-link': true,
        'router-view': RouterView
      }
    }
  });
}

describe('GroupPage', () => {
  beforeEach(() => {
    mocks.route.params.key = 'cached-group';
    mocks.groupCurrent = {id: 1, key: 'cached-group', name: 'Cached group'};
    mocks.groupFetch = deferred();
    mocks.watchRecordsQuery = null;
    mocks.eventBus.$emit.mockReset();
    mocks.eventBus.$on.mockReset();
    mocks.eventBus.$off.mockReset();
    mocks.fetchById.mockReset().mockReturnValue(mocks.groupFetch.promise);
    mocks.fuzzyFind.mockReset().mockImplementation(() => mocks.groupCurrent);
  });

  it('renders a cached group while authorizing it from the server', async () => {
    const wrapper = mountPage();
    await nextTick();

    expect(mocks.fetchById).toHaveBeenCalledWith('cached-group');
    expect(wrapper.findComponent(RoutedPanel).props('group').name).toBe('Cached group');
  });

  it('replaces cached data after the server refresh completes', async () => {
    const wrapper = mountPage();
    await nextTick();

    mocks.groupCurrent = {id: 1, key: 'cached-group', name: 'Refreshed group'};
    mocks.groupFetch.resolve();
    await flushPromises();

    expect(wrapper.findComponent(RoutedPanel).props('group').name).toBe('Refreshed group');
  });

  it('refreshes the routed panel when records change', async () => {
    const wrapper = mountPage();
    await nextTick();
    mocks.groupCurrent = {id: 1, key: 'cached-group', name: 'Realtime group'};

    mocks.watchRecordsQuery();
    await nextTick();

    expect(wrapper.findComponent(RoutedPanel).props('group').name).toBe('Realtime group');
  });

  it('removes cached content when authorization fails', async () => {
    const wrapper = mountPage();
    await nextTick();
    const error = {status: 403};

    mocks.groupFetch.reject(error);
    await flushPromises();

    expect(wrapper.findComponent(RoutedPanel).exists()).toBe(false);
    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('openAuthModal');
  });

  it('removes cached content when the group no longer exists', async () => {
    const wrapper = mountPage();
    await nextTick();
    const error = {status: 404};

    mocks.groupFetch.reject(error);
    await flushPromises();

    expect(wrapper.findComponent(RoutedPanel).exists()).toBe(false);
    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.eventBus.$emit).not.toHaveBeenCalledWith('openAuthModal');
  });

  it('ignores an authorization failure from a superseded load', async () => {
    const wrapper = mountPage();
    await nextTick();
    const firstFetch = mocks.groupFetch;

    mocks.groupCurrent = {id: 2, key: 'next-group', name: 'Next group'};
    mocks.groupFetch = deferred();
    mocks.fetchById.mockReturnValueOnce(mocks.groupFetch.promise);
    const reload = mocks.eventBus.$on.mock.calls.find(([event]) => event === 'signedIn')[1];
    reload();
    await nextTick();

    firstFetch.reject({status: 403});
    await flushPromises();

    expect(wrapper.findComponent(RoutedPanel).props('group').name).toBe('Next group');
    expect(mocks.eventBus.$emit).not.toHaveBeenCalledWith('pageError', expect.anything());
  });
});
