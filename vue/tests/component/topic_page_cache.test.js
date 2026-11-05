import { flushPromises, shallowMount } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Loki from 'lokijs';

const mocks = vi.hoisted(() => ({
  route: null, records: null, cached: true,
  fetch: vi.fn(), emit: vi.fn(), on: vi.fn(), off: vi.fn(),
  scroll: vi.fn(), settled: vi.fn(), cancel: vi.fn()
}));
vi.mock('@/shared/services/records', () => ({get default() { return mocks.records; }}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => true}}));
vi.mock('@/shared/services/app_config', () => ({default: {currentUserId: 1}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit, $on: mocks.on, $off: mocks.off}}));
vi.mock('@/shared/services/scroll_service', () => ({default: {scrollTo: mocks.scroll, scrollToSettled: mocks.settled}}));
vi.mock('vue-router', () => ({useRoute: () => mocks.route}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));
vi.mock('@/components/topic/actions_panel', () => ({default: {template: '<div />'}}));
vi.mock('@/components/topic/list.vue', () => ({default: {name: 'TopicList', props: ['collection'], template: '<div class="cached-items">{{ collection.length }}</div>'}}));
vi.mock('@/components/topic/toc_nav.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/discussion/fork_actions.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/topic/header.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/common/formatted_text.vue', () => ({default: {template: '<div />'}}));

import TopicPage from '@/components/topic/page.vue';

let response, topic, discussion, wrapper;
function mountPage() {
  wrapper = shallowMount(TopicPage, {global: {
    stubs: {
      TopicList: false,
      VMain: {template: '<main><slot /></main>'},
      VContainer: {template: '<div><slot /></div>'},
      VSheet: {template: '<div><slot /></div>'},
      VBtn: {template: '<button @click="$emit(\'click\')"><slot /></button>'}
    }
  }});
  return wrapper;
}

function item(sequenceId) {
  return {
    id: sequenceId + 1, topicId: 1, sequenceId, position: sequenceId, positionKey: String(sequenceId).padStart(5, '0'),
    parentId: null, childCount: 0, parent: () => null, replyParent: () => null,
    model: () => discussion
  };
}

describe('cached thread navigation', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.spyOn(window, 'scrollTo').mockImplementation(() => {});
    vi.spyOn(console, 'error').mockImplementation(() => {});
    mocks.settled.mockReturnValue(mocks.cancel);
    mocks.route = reactive({path: '/d/thread', params: {key: 'thread'}, query: {}});
    mocks.cached = true;
    discussion = {id: 10, title: 'Cached discussion', description: 'Saved content', attachments: [], topic: () => topic};
    topic = {id: 1, topicableId: 10, topicableType: 'Discussion', itemsCount: 41, ranges: [[0, 40]], readRanges: [[0, 39]], lastReadAt: new Date(),
      group: () => ({}), topicable: () => discussion, lastSequenceId: () => 40};
    const collection = new Loki('topic-page').addCollection('topic_items');
    collection.insert([item(0), item(1)]);
    mocks.records = {
      views: {}, view: ({name, query}) => { mocks.records.views[name] = query; query(); },
      discussions: {findByKey: () => mocks.cached ? discussion : null},
      polls: {findByKey: () => null, find: () => null},
      topics: {find: () => topic},
      topicItems: {collection, find: query => collection.find(query), fetch: mocks.fetch}
    };
    response = {};
    response.promise = new Promise((resolve, reject) => { response.resolve = resolve; response.reject = reject; });
    mocks.fetch.mockReturnValue(response.promise);
  });

  afterEach(() => { wrapper?.unmount(); vi.restoreAllMocks(); });

  it('renders cached content while refresh is pending and stays at the top', async () => {
    mountPage();
    await nextTick();
    expect(wrapper.find('.cached-items').text()).toBe('2');
    expect(mocks.emit).toHaveBeenCalledWith('currentComponent', expect.objectContaining({title: 'Cached discussion'}));
    expect(mocks.fetch).toHaveBeenCalledWith({params: {discussion_key: 'thread', include_polls_not_closed: 1, order_by: 'sequence_id', per: 25}});
    expect(mocks.scroll).not.toHaveBeenCalled();
    expect(mocks.settled).not.toHaveBeenCalled();
    response.resolve({topics: [{id: 1}]});
    await flushPromises();
    expect(window.scrollTo).toHaveBeenCalledTimes(1);
    expect(mocks.scroll).not.toHaveBeenCalled();
    expect(mocks.settled).not.toHaveBeenCalled();
  });

  it('shows cached description even before any timeline items are available', async () => {
    mocks.records.topicItems.collection.clear();
    mountPage();
    await nextTick();
    expect(wrapper.find('.topic-page__cached-context').exists()).toBe(true);
    expect(mocks.emit).toHaveBeenCalledWith('currentComponent', expect.objectContaining({title: discussion.title}));
  });

  it.each([
    [{sequence_id: '17'}, {}, '.sequenceId-17'],
    [{}, {comment_id: '23'}, '#comment-23']
  ])('preserves explicit links to comments', async (params, query, selector) => {
    Object.assign(mocks.route.params, params);
    Object.assign(mocks.route.query, query);
    mountPage();
    await nextTick();
    expect(mocks.settled).toHaveBeenCalledWith(selector, null);
    expect(window.scrollTo).not.toHaveBeenCalled();
  });

  it('keeps cached content after a network failure', async () => {
    mountPage();
    response.reject(new TypeError('offline'));
    await flushPromises();
    expect(wrapper.find('.cached-items').text()).toBe('2');
    expect(mocks.emit.mock.calls.some(([name]) => name === 'pageError')).toBe(false);
  });

  it('reports revoked access even when a cached record exists', async () => {
    mountPage();
    response.reject({status: 403});
    await flushPromises();
    expect(mocks.emit).toHaveBeenCalledWith('pageError', {status: 403});
  });

  it('ignores a pending response when the page has been left', async () => {
    mocks.cached = false;
    mountPage();
    wrapper.unmount();
    mocks.emit.mockClear();
    response.resolve({topics: [{id: 1}]});
    await flushPromises();
    expect(mocks.emit).not.toHaveBeenCalled();
  });

  it('jumps to cached latest activity without waiting for a refresh', async () => {
    mocks.records.topicItems.collection.insert(item(40));
    mountPage();
    await nextTick();
    await wrapper.find('.topic-page__latest button').trigger('click');
    await nextTick();
    expect(mocks.scroll).toHaveBeenCalledWith('.sequenceId-40');
    const visibleKeys = mocks.on.mock.calls.find(([name]) => name === 'visibleKeys')[1];
    visibleKeys(['00040']);
    await nextTick();
    expect(wrapper.find('.topic-page__latest').exists()).toBe(false);
  });

  it('uses the current latest sequence after a topic update', async () => {
    mountPage();
    await nextTick();
    topic.ranges = [[0, 45]];
    topic.lastSequenceId = () => 45;
    mocks.records.topicItems.collection.insert(item(45));
    await wrapper.find('.topic-page__latest button').trigger('click');
    await nextTick();
    expect(mocks.scroll).toHaveBeenCalledWith('.sequenceId-45');
    expect(mocks.fetch).toHaveBeenCalledWith({params: expect.objectContaining({sequence_id_lte: 45})});
  });

  it('opens an embedded poll link at that poll', async () => {
    const poll = {id: 99, topic: () => topic};
    mocks.records.polls.findByKey = () => poll;
    mocks.route.path = '/p/poll';
    mocks.route.params.key = 'poll';
    mocks.records.topicItems.collection.insert({...item(17), kind: 'poll_created', itemableType: 'Poll', itemableId: 99, model: () => poll});
    mountPage();
    await nextTick();
    expect(mocks.settled).toHaveBeenCalledWith('.sequenceId-17', null);
    expect(window.scrollTo).not.toHaveBeenCalled();
    response.resolve({topics: [{id: 1}]});
    await flushPromises();
    expect(window.scrollTo).not.toHaveBeenCalled();
  });

  it('opens a cached root poll at the start with one refresh request', async () => {
    topic.topicableType = 'Poll';
    mocks.records.polls.findByKey = () => discussion;
    mocks.route.path = '/p/poll';
    mocks.route.params.key = 'poll';
    mountPage();
    await nextTick();
    expect(mocks.fetch).toHaveBeenCalledWith({params: {poll_key: 'poll', include_polls_not_closed: 1, order_by: 'sequence_id', per: 25}});
    response.resolve({topics: [{id: 1}]});
    await flushPromises();
    expect(mocks.fetch).toHaveBeenCalledOnce();
    expect(mocks.scroll).not.toHaveBeenCalled();
    expect(mocks.settled).not.toHaveBeenCalled();
  });

  it('loads an uncached root poll after resolving its topic', async () => {
    topic.topicableType = 'Poll';
    mocks.cached = false;
    mocks.records.polls.findByKey = () => mocks.cached ? discussion : null;
    mocks.route.path = '/p/poll';
    mocks.route.params.key = 'poll';
    mountPage();
    await nextTick();
    expect(wrapper.find('#topic-page').exists()).toBe(false);
    mocks.cached = true;
    response.resolve({topics: [{id: 1}]});
    await flushPromises();
    expect(wrapper.find('#topic-page').exists()).toBe(true);
    expect(mocks.fetch).toHaveBeenCalledWith({params: expect.objectContaining({order_by: 'sequence_id'})});
    expect(mocks.settled).not.toHaveBeenCalled();
  });
});
