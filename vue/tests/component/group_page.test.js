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

vi.mock('vue-router', () => ({
  useRoute: () => reactive(mocks.route)
}));

vi.mock('@/shared/services/records', () => ({
  default: {
    groups: {
      fuzzyFind: mocks.fuzzyFind,
      remote: {fetchById: mocks.fetchById}
    }
  }
}));

vi.mock('@/shared/services/session', () => ({
  default: {isSignedIn: () => false}
}));

vi.mock('@/shared/services/event_bus', () => ({default: mocks.eventBus}));
vi.mock('@/shared/services/ability_service', () => ({
  default: {canEditGroup: () => false}
}));
vi.mock('@/shared/services/group_service', () => ({
  default: {actions: () => ({})}
}));
vi.mock('@/shared/services/lmo_url_service', () => ({
  default: {route: () => '/cached-group'}
}));
vi.mock('@/composables/useWatchRecords', () => ({
  useWatchRecords: () => ({
    watchRecords: ({query}) => { mocks.watchRecordsQuery = query; }
  })
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
      directives: {
        intersect: () => {},
        t: () => {}
      },
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
    mocks.fetchById.mockReset().mockReturnValue(mocks.groupFetch.promise);
    mocks.fuzzyFind.mockReset().mockImplementation(() => mocks.groupCurrent);
  });

  it('renders a cached group while authorizing it from the server', async () => {
    const wrapper = mountPage();
    await nextTick();

    expect(mocks.fetchById).toHaveBeenCalledWith('cached-group');
    expect(wrapper.findComponent(RoutedPanel).props('group').name).toBe('Cached group');
  });

  it('refreshes the routed panel when watchRecords receives the updated group', async () => {
    const wrapper = mountPage();
    await nextTick();
    const refreshedGroup = {id: 1, key: 'cached-group', name: 'Refreshed group'};

    mocks.groupCurrent = refreshedGroup;
    mocks.watchRecordsQuery();
    await nextTick();

    expect(wrapper.findComponent(RoutedPanel).props('group').name).toBe('Refreshed group');
  });

  it('reports an authorization failure when no cached group is available', async () => {
    mocks.groupCurrent = null;
    const wrapper = mountPage();
    const error = {status: 403};

    mocks.groupFetch.reject(error);
    await flushPromises();

    expect(wrapper.findComponent(RoutedPanel).exists()).toBe(false);
    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.eventBus.$emit).toHaveBeenCalledWith('openAuthModal');
  });
});
