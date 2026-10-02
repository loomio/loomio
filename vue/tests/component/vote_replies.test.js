import { beforeEach, describe, expect, it, vi } from 'vitest';
import { shallowMount } from '@vue/test-utils';

const mocks = vi.hoisted(() => ({polls: new Map(), items: new Map(), stances: new Map(), vote: {castAt: null}, user: {id: 1}}));
vi.mock('@/shared/services/records', () => ({default: {
  polls: {find: id => mocks.polls.get(id)},
  stances: {find: query => typeof query === 'number' ? mocks.stances.get(query) : (mocks.vote.castAt ? [mocks.vote] : [])},
  topicItems: {find: id => mocks.items.get(id), nullModel: () => null}
}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => mocks.user, isSignedIn: () => true}}));
vi.mock('@/shared/services/app_config', () => ({default: {pollTypes: {proposal: {has_options: true}}}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@/shared/services/bookmark_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/shared/helpers/open_modal', () => ({default: vi.fn()}));
vi.mock('@/shared/services/flash', () => ({default: {success: vi.fn()}}));
vi.mock('@/components/topic/load_more.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/topic/reply_form.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/topic_items/intersection_wrapper', () => ({default: {template: '<div />'}}));
vi.mock('@/components/topic_items/stem_wrapper', () => ({default: {template: '<div />'}}));
vi.mock('@/components/topic_items/collapsed', () => ({default: {template: '<div />'}}));

import CommentModel from '@/shared/models/comment_model';
import PollModel from '@/shared/models/poll_model';
import TopicItemModel from '@/shared/models/topic_item_model';
import StanceService from '@/shared/services/stance_service';
import TopicList from '@/components/topic/list.vue';
import StanceReason from '@/components/poll/common/stance_reason.vue';

describe('conversation beneath votes', () => {
  let poll;
  let topic;
  let stance;

  beforeEach(() => {
    mocks.vote.castAt = null;
    mocks.polls.clear();
    mocks.items.clear();
    mocks.stances.clear();
    poll = new PollModel({id: 10, hideResults: 'until_vote', closingAt: '2026-12-01', myStanceId: 1});
    mocks.polls.set(poll.id, poll);
    topic = {maxDepth: 2, membersInclude: () => true, lockedAt: null};
    poll.topic = () => topic;
    stance = {castAt: '2026-10-01', poll: () => poll};
    mocks.stances.set(11, stance);
    makeItem({id: 10, itemableType: 'Poll', itemableId: poll.id, parentId: null});
  });

  function makeItem(attributes) {
    const item = new TopicItemModel(attributes);
    item.actor = () => mocks.user;
    mocks.items.set(item.id, item);
    return item;
  }

  function mountComment(parentId, commentAttributes = {}) {
    const comment = new CommentModel({id: 20, ...commentAttributes});
    const item = makeItem({id: 30, depth: 2, itemableType: 'Comment', itemableId: comment.id, parentId, childCount: 0});
    const collection = [{topic_item: item, itemable: comment, children: []}];
    const wrapper = shallowMount(TopicList, {
      props: {collection, loader: {topic, collapsed: {}}},
      global: {stubs: {VExpandTransition: {template: '<div><slot /></div>'}, UserAvatar: true, CommonIcon: true}}
    });
    return {wrapper, collection};
  }

  it('enables Reply as soon as the reader votes and keeps it disabled until closing for until-closed polls', () => {
    const reply = StanceService.actions(stance, {}, {depth: 2}).add_comment;
    expect(reply.canPerform()).toBeFalsy();
    mocks.vote.castAt = '2026-10-02';
    expect(reply.canPerform()).toBeTruthy();
    poll.hideResults = 'until_closed';
    expect(reply.canPerform()).toBeFalsy();
    poll.closedAt = '2026-10-03';
    expect(reply.canPerform()).toBeTruthy();
    poll.anonymous = true;
    expect(reply.canPerform()).toBeFalsy();
  });

  it('hides a reply displayed beside its vote at maximum depth until the reader votes', async () => {
    // The comment's domain parent is outside the page; the normal timeline
    // parent still identifies the poll after nesting depth is capped.
    const {wrapper, collection} = mountComment(10, {parentType: 'Comment', parentId: 999});
    expect(wrapper.find('.topic-item').exists()).toBe(false);
    mocks.vote.castAt = '2026-10-02';
    await wrapper.setProps({collection: [...collection]});
    expect(wrapper.find('.topic-item').exists()).toBe(true);
    mocks.vote.castAt = null;
    await wrapper.setProps({collection: [...collection]});
    expect(wrapper.find('.topic-item').exists()).toBe(false);
    wrapper.unmount();
  });

  it('hides direct poll comments until voting and reveals them when the poll closes', async () => {
    const {wrapper, collection} = mountComment(10, {parentType: 'Poll', parentId: poll.id});
    expect(wrapper.find('.topic-item').exists()).toBe(false);
    mocks.vote.castAt = '2026-10-02';
    await wrapper.setProps({collection: [...collection]});
    expect(wrapper.find('.topic-item').exists()).toBe(true);
    poll.hideResults = 'until_closed';
    await wrapper.setProps({collection: [...collection]});
    expect(wrapper.find('.topic-item').exists()).toBe(false);
    poll.closedAt = '2026-10-03';
    await wrapper.setProps({collection: [...collection]});
    expect(wrapper.find('.topic-item').exists()).toBe(true);
    wrapper.unmount();
  });

  it('uses normally loaded stance and comment ancestors to hide nested replies', async () => {
    makeItem({id: 11, itemableType: 'Stance', itemableId: 11, parentId: 10});
    makeItem({id: 12, itemableType: 'Comment', itemableId: 21, parentId: 11});
    const {wrapper, collection} = mountComment(12);
    expect(wrapper.find('.topic-item').exists()).toBe(false);
    mocks.vote.castAt = '2026-10-02';
    await wrapper.setProps({collection: [...collection]});
    expect(wrapper.find('.topic-item').exists()).toBe(true);
    wrapper.unmount();
  });

  it('leaves comments elsewhere in the discussion visible', () => {
    makeItem({id: 1, itemableType: 'Discussion', parentId: null});
    const {wrapper} = mountComment(1);
    expect(wrapper.find('.topic-item').exists()).toBe(true);
    wrapper.unmount();
  });

  it('disables mention suggestions in vote reasons until an until-closed poll closes', async () => {
    poll.hideResults = 'until_closed';
    const wrapper = shallowMount(StanceReason, {
      props: {poll, stance}, global: {mocks: {$t: key => key}, stubs: {
        LmoTextarea: true, ValidationErrors: true
      }}
    });
    const editor = () => wrapper.findComponent('.poll-common-vote-form__reason');
    expect(editor().props('allowMentions')).toBe(false);
    await wrapper.setProps({poll: new PollModel({id: 10, hideResults: 'until_closed', closedAt: '2026-10-03'})});
    expect(editor().props('allowMentions')).toBe(true);
    await wrapper.setProps({poll: new PollModel({id: 10, hideResults: 'until_vote'})});
    expect(editor().props('allowMentions')).toBe(true);
    wrapper.unmount();
  });
});
