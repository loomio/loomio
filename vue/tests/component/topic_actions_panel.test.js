import { shallowMount } from '@vue/test-utils';
import { reactive } from 'vue';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  route: null,
  canAddComment: vi.fn(), canStartPoll: vi.fn(), buildComment: vi.fn(),
  comment: null, scroll: vi.fn()
}));
vi.mock('vue-router', () => ({useRoute: () => mocks.route}));
vi.mock('@/shared/services/ability_service', () => ({default: {canAddComment: mocks.canAddComment, canStartPoll: mocks.canStartPoll}}));
vi.mock('@/shared/services/records', () => ({default: {comments: {build: mocks.buildComment}}}));
vi.mock('@/shared/services/session', () => ({default: {defaultFormat: () => 'html', user: () => ({id: 1}), isSignedIn: () => true}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$on: vi.fn(), $off: vi.fn()}}));
vi.mock('@/shared/services/scroll_service', () => ({default: {scrollTo: mocks.scroll}}));
vi.mock('@/composables/useWatchRecords', () => ({useWatchRecords: () => ({watchRecords: ({query}) => query()})}));
vi.mock('@/components/poll/common/form', () => ({default: {name: 'PollCommonForm', props: ['poll'], template: '<div />'}}));
vi.mock('@/components/poll/common/choose_template_wrapper', () => ({default: {name: 'PollCommonChooseTemplateWrapper', template: '<div />'}}));
vi.mock('@/components/topic/comment_form.vue', () => ({default: {name: 'CommentForm', props: ['comment'], template: '<textarea v-model="comment.body" />'}}));

import TopicActionsPanel from '@/components/topic/actions_panel.vue';

let wrapper;
const topic = {id: 1, topicableId: 2, topicableType: 'Discussion', group: () => ({})};
function mountPanel() {
  wrapper = shallowMount(TopicActionsPanel, {attachTo: document.body, props: {topic}, global: {
    mocks: {$t: key => key},
    directives: {t: () => {}},
    stubs: {
      VTabs: {name: 'VTabs', template: '<div><slot /></div>'},
      CommentForm: false,
      JoinGroupButton: true
    }
  }});
  return wrapper;
}
async function selectTab(action) {
  wrapper.findComponent({name: 'VTabs'}).vm.$emit('update:modelValue', action);
  await wrapper.vm.$nextTick();
}

describe('thread action panels', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.route = reactive({query: {}});
    mocks.comment = reactive({body: ''});
    mocks.buildComment.mockReturnValue(mocks.comment);
    mocks.canAddComment.mockReturnValue(true);
    mocks.canStartPoll.mockReturnValue(true);
  });
  afterEach(() => wrapper?.unmount());

  it('loads vote templates on first use and retains the comment draft across switches', async () => {
    mountPanel();
    expect(wrapper.findComponent({name: 'PollCommonChooseTemplateWrapper'}).exists()).toBe(false);
    await wrapper.find('textarea').setValue('Draft to keep');
    await selectTab('add-poll');
    expect(wrapper.find('#topic-1-comment-panel').isVisible()).toBe(false);
    expect(wrapper.find('#topic-1-poll-panel').isVisible()).toBe(true);
    expect(wrapper.findComponent({name: 'PollCommonChooseTemplateWrapper'}).exists()).toBe(true);
    await selectTab('add-comment');
    expect(wrapper.find('textarea').element.value).toBe('Draft to keep');
    expect(wrapper.find('#topic-1-comment-panel').isVisible()).toBe(true);
    expect(wrapper.find('#topic-1-poll-panel').isVisible()).toBe(false);
    expect(mocks.scroll).toHaveBeenCalledTimes(2);
    expect(mocks.scroll).toHaveBeenLastCalledWith('#add-comment', 72);
  });

  it('retains a selected vote template when returning to its tab', async () => {
    mountPanel();
    await selectTab('add-poll');
    const poll = {id: null, title: 'Draft vote'};
    wrapper.findComponent({name: 'PollCommonChooseTemplateWrapper'}).vm.$emit('setPoll', poll);
    await wrapper.vm.$nextTick();
    await selectTab('add-comment');
    await selectTab('add-poll');
    expect(wrapper.findComponent({name: 'PollCommonForm'}).props('poll')).toEqual(poll);
  });

  it('honors an explicit link to the vote form', async () => {
    mocks.route.query.current_action = 'add-poll';
    mountPanel();
    expect(wrapper.find('#topic-1-poll-panel').isVisible()).toBe(true);
    expect(wrapper.find('textarea').exists()).toBe(false);
    await selectTab('add-comment');
    expect(wrapper.find('textarea').isVisible()).toBe(true);
  });

  it('does not expose either form when the reader cannot comment', () => {
    mocks.canAddComment.mockReturnValue(false);
    mocks.canStartPoll.mockReturnValue(false);
    mountPanel();
    expect(wrapper.find('textarea').exists()).toBe(false);
    expect(wrapper.find('.actions-panel__forms').exists()).toBe(false);
  });

  it('allows commenting without exposing the vote tab when starting polls is forbidden', () => {
    mocks.canStartPoll.mockReturnValue(false);
    mountPanel();
    expect(wrapper.find('textarea').isVisible()).toBe(true);
    expect(wrapper.findComponent({name: 'VTabs'}).exists()).toBe(false);
    expect(wrapper.findComponent({name: 'PollCommonChooseTemplateWrapper'}).exists()).toBe(false);
  });
});
