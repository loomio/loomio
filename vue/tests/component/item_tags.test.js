import { mount, flushPromises } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import { createRouter, createMemoryHistory } from 'vue-router';
import { beforeEach, afterEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  patchItem: vi.fn(), serverError: vi.fn(), watchRecords: vi.fn(), user: {id: 1}
}));
vi.mock('@/shared/services/records', () => ({default: {
  topicItems: {remote: {patchMember: mocks.patchItem}}
}}));
vi.mock('@/shared/services/flash', () => ({default: {serverError: mocks.serverError}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => mocks.user, isSignedIn: () => true}}));
vi.mock('@/composables/useWatchRecords', () => ({useWatchRecords: () => ({watchRecords: mocks.watchRecords})}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));

import TopicTagsPicker from '@/components/tags/topic_tags_picker.vue';
import ThreadTags from '@/components/tags/thread_tags.vue';
import TagFilterToolbar from '@/components/topic/tag_filter_toolbar.vue';
import AbilityService from '@/shared/services/ability_service';

describe('item tagging', () => {
  let wrapper;
  let topic;
  let group;
  let taggedItem;
  let rootItem;

  beforeEach(() => {
    vi.clearAllMocks();
    taggedItem = null;
    rootItem = reactive({id: 6, tags: ['Governance']});
    mocks.patchItem.mockImplementation(async (_id, _action, {tags}) => { (taggedItem || rootItem).tags = tags; });
    vi.stubGlobal('ResizeObserver', class {observe() {} unobserve() {} disconnect() {}});
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    group = {
      id: 1, subgroupsCount: 0, isEnabled: () => true, membersCanCreateTags: false,
      membersInclude: () => true, adminsInclude: () => false,
      parentOrSelf: () => group,
      tags: () => [{id: 1, name: 'Budget', usedGroupIds: [1]}, {id: 2, name: 'Governance', usedGroupIds: [1]}]
    };
    topic = reactive({
      id: 5, groupId: 1, tags: ['Budget', 'Governance'], hasTaggedReplies: true,
      createdTopicItem: () => rootItem,
      group: () => group, membersInclude: () => true, adminsInclude: () => false,
      topicable: () => ({authorId: 1}), topicableType: 'Discussion'
    });
  });

  afterEach(() => {
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  function mountPicker(topicItem) {
    taggedItem = topicItem;
    wrapper = mount(TopicTagsPicker, {props: {topic, topicItem, watchKey: 'test'}, global: {
      plugins: [createVuetify({components})], mocks: {$t: key => key}, stubs: {'common-icon': true}
    }});
  }

  it('edits the opening contribution without selecting aggregate-only tags', async () => {
    mountPicker();
    await nextTick();
    await wrapper.findAll('.topic-tags-picker__tag')[0].trigger('click');
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenCalledWith(6, 'tags', {tags: ['Budget', 'Governance']});
    expect(rootItem.tags).toEqual(['Budget', 'Governance']);
  });

  it('uses the item endpoint and leaves other assignments alone', async () => {
    const item = reactive({id: 9, tags: ['Budget']});
    mountPicker(item);
    await nextTick();
    await wrapper.findAll('.topic-tags-picker__tag')[0].trigger('click');
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenCalledWith(9, 'tags', {tags: []});
    expect(item.tags).toEqual([]);
    expect(rootItem.tags).toEqual(['Governance']);
  });

  it('restores the saved selection when an edit fails', async () => {
    const item = reactive({id: 9, tags: ['Budget']});
    mocks.patchItem.mockRejectedValue(new Error('Forbidden'));
    mountPicker(item);
    await nextTick();
    await wrapper.findAll('.topic-tags-picker__tag')[0].trigger('click');
    await flushPromises();
    expect(item.tags).toEqual(['Budget']);
    expect(mocks.serverError).toHaveBeenCalled();
    await wrapper.findAll('.topic-tags-picker__tag')[0].trigger('click');
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenLastCalledWith(9, 'tags', {tags: []});
  });

  it('uses the saved assignments when the server drops disallowed names', async () => {
    const item = reactive({id: 9, tags: ['Budget']});
    mocks.patchItem.mockImplementation(async () => { item.tags = ['Budget']; });
    mountPicker(item);
    await nextTick();
    await wrapper.findAll('.topic-tags-picker__tag')[1].trigger('click');
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenCalledWith(9, 'tags', {tags: ['Budget', 'Governance']});
    expect(item.tags).toEqual(['Budget']);
    expect(wrapper.findAll('input[type="checkbox"]')[1].element.checked).toBe(false);
  });

  it('shows unused vocabulary without expansion when the organization has only one group', async () => {
    group.tags = () => [
      {id: 1, name: 'Governance', usedGroupIds: [1]},
      {id: 2, name: 'Unused', usedGroupIds: []},
      {id: 3, name: 'Former subgroup tag', usedGroupIds: [99]}
    ];
    mountPicker();
    await nextTick();
    expect(wrapper.findAll('.topic-tags-picker__tag').map(row => row.text())).toEqual(['Former subgroup tag', 'Governance', 'Unused']);
    expect(wrapper.find('.topic-tags-picker__all-tags').exists()).toBe(false);
  });

  it('expands only tags used exclusively in other groups, and keeps selected tags visible', async () => {
    group.subgroupsCount = 1;
    group.tags = () => [
      {id: 1, name: 'Governance', usedGroupIds: [1]},
      {id: 2, name: 'Shared', usedGroupIds: [1, 2]},
      {id: 3, name: 'Subgroup', usedGroupIds: [2]},
      {id: 4, name: 'Unused', usedGroupIds: []}
    ];
    mountPicker();
    await nextTick();
    const names = () => wrapper.findAll('.topic-tags-picker__tag').map(row => row.text());
    expect(names()).toEqual(['Governance', 'Shared', 'Unused']);
    expect(wrapper.find('.topic-tags-picker__all-tags').text()).toContain('loomio_tags.show_tags_from_other_groups');
    await wrapper.find('.topic-tags-picker__all-tags').trigger('click');
    expect(names()).toEqual(['Governance', 'Shared', 'Subgroup', 'Unused']);
    await wrapper.findAll('.topic-tags-picker__tag')[2].trigger('click');
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenCalledWith(6, 'tags', {tags: ['Governance', 'Subgroup']});
    wrapper.vm.reset();
    await nextTick();
    expect(names()).toContain('Subgroup');
  });

  it('lets subgroups expand tags from their parent and sibling groups', async () => {
    const parent = {id: 1, subgroupsCount: 2, adminsInclude: () => false};
    group.id = 2;
    group.parentOrSelf = () => parent;
    topic.groupId = 2;
    rootItem.tags = [];
    group.tags = () => [
      {id: 1, name: 'Local', usedGroupIds: [2]},
      {id: 2, name: 'Parent', usedGroupIds: [1]},
      {id: 3, name: 'Sibling', usedGroupIds: [3]}
    ];
    mountPicker();
    await nextTick();
    expect(wrapper.findAll('.topic-tags-picker__tag').map(row => row.text())).toEqual(['Local']);
    await wrapper.find('.topic-tags-picker__all-tags').trigger('click');
    expect(wrapper.findAll('.topic-tags-picker__tag').map(row => row.text())).toEqual(['Local', 'Parent', 'Sibling']);
    await wrapper.find('.topic-tags-picker__all-tags').trigger('click');
    expect(wrapper.findAll('.topic-tags-picker__tag').map(row => row.text())).toEqual(['Local']);
  });

  it('uses sidebar chips as a reversible route filter', async () => {
    const router = createRouter({history: createMemoryHistory(), routes: [{path: '/d/thread', component: {template: '<div />'}}]});
    await router.push('/d/thread');
    wrapper = mount(ThreadTags, {props: {topic}, global: {plugins: [createVuetify({components}), router]}});
    await wrapper.findAll('.v-chip')[0].trigger('click');
    await flushPromises();
    expect(router.currentRoute.value.query.tag).toBe('Budget');
    await nextTick();
    expect(wrapper.findAll('.v-chip')[0].attributes('aria-pressed')).toBe('true');
    await wrapper.find('.thread-tags__clear').trigger('click');
    await flushPromises();
    expect(router.currentRoute.value.query.tag).toBeUndefined();
  });

  it('cancels filtering from the toolbar without removing other route parameters', async () => {
    const router = createRouter({history: createMemoryHistory(), routes: [{path: '/d/thread', component: {template: '<div />'}}]});
    await router.push('/d/thread?tag=Budget&sequence_id=8');
    wrapper = mount(TagFilterToolbar, {props: {tag: 'Budget', group}, global: {
      plugins: [createVuetify({components}), router], stubs: {'common-icon': true}
    }});
    expect(wrapper.text()).toContain('Budget');
    await wrapper.find('.tag-filter-toolbar__close').trigger('click');
    await flushPromises();
    expect(router.currentRoute.value.query).toEqual({sequence_id: '8'});
  });

  it('shows sidebar tags only when a non-root contribution is tagged, including tags shared with the root', async () => {
    const router = createRouter({history: createMemoryHistory(), routes: [{path: '/d/thread', component: {template: '<div />'}}]});
    await router.push('/d/thread?tag=Governance');
    topic.tags = ['Governance'];
    topic.hasTaggedReplies = false;
    wrapper = mount(ThreadTags, {props: {topic}, global: {plugins: [createVuetify({components}), router]}});
    expect(wrapper.find('.thread-tags').exists()).toBe(false);
    topic.hasTaggedReplies = true;
    await nextTick();
    expect(wrapper.find('.thread-tags').text()).toContain('Governance');
    topic.hasTaggedReplies = false;
    await nextTick();
    expect(wrapper.find('.thread-tags').exists()).toBe(false);
  });

  it('keeps later choices when an earlier queued edit fails', async () => {
    let rejectFirst;
    mocks.patchItem.mockImplementationOnce(() => new Promise((_resolve, reject) => { rejectFirst = reject; }));
    const item = reactive({id: 9, tags: ['Budget']});
    mountPicker(item);
    await nextTick();
    const rows = wrapper.findAll('.topic-tags-picker__tag');
    await rows[0].trigger('click');
    await rows[1].trigger('click');
    rejectFirst(new Error('Failed first edit'));
    await flushPromises();
    expect(item.tags).toEqual(['Governance']);
    await rows[1].trigger('click');
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenLastCalledWith(9, 'tags', {tags: []});
  });

  it('allows a private tag name on a direct contribution without an organization vocabulary', async () => {
    topic.groupId = null;
    topic.discussion = () => ({discussionTemplateId: null});
    const item = reactive({id: 9, tags: []});
    mountPicker(item);
    await flushPromises();
    await wrapper.find('.topic-tags-picker__new-tag').trigger('click');
    const input = wrapper.find('input');
    await input.setValue('Private follow up');
    await input.trigger('keyup', {key: 'Enter'});
    await flushPromises();
    expect(mocks.patchItem).toHaveBeenCalledWith(9, 'tags', {tags: ['Private follow up']});
    expect(item.tags).toEqual(['Private follow up']);
  });

  it('lets comment authors tag their comments regardless of poll result visibility', () => {
    for (const hideResults of ['off', 'until_vote', 'until_closed']) {
      const parent = {itemableType: 'Poll', model: () => ({hideResults, closedAt: null})};
      const item = {kind: 'new_comment', topic: () => topic, model: () => ({authorId: 1}), parent: () => parent};
      expect(AbilityService.canTagTopicItem(item)).toBe(true);
    }
  });

  it('allows tagging closed polls while refusing locked topics and ballot entries', () => {
    topic.adminsInclude = () => true;
    const model = {authorId: 2, closedAt: new Date()};
    const item = {kind: 'poll_created', topic: () => topic, model: () => model};
    expect(AbilityService.canTagTopicItem(item)).toBe(true);
    topic.lockedAt = new Date();
    expect(AbilityService.canTagTopicItem(item)).toBe(false);
    topic.lockedAt = null;
    item.kind = 'stance_updated';
    expect(AbilityService.canTagTopicItem(item)).toBe(false);
  });
});
