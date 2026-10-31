import { shallowMount, flushPromises } from '@vue/test-utils';
import { beforeEach, afterEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  signedIn: true, user: {id: 2},
  buildTemplate: vi.fn(), buildDiscussion: vi.fn(), fetchDiscussion: vi.fn(),
  findTopicItems: vi.fn(), fetchTopicItems: vi.fn(), emit: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({default: {
  discussionTemplates: {build: mocks.buildTemplate},
  discussions: {build: mocks.buildDiscussion, findOrFetchById: mocks.fetchDiscussion},
  topicItems: {find: mocks.findTopicItems, fetch: mocks.fetchTopicItems}
}}));
vi.mock('@/shared/services/session', () => ({default: {
  user: () => mocks.user, isSignedIn: () => mocks.signedIn, returnTo: () => '/d/source'
}}));
vi.mock('@/shared/services/app_config', () => ({default: {
  templateSettings: {discussion_template: [
    'title', 'description', 'description_format', 'content_locale', 'tags', 'newest_first', 'max_depth',
    'allow_concurrent_polls', 'allow_comments', 'allow_reactions', 'comment_length_max', 'attachments_admin_only',
    'poll_template_keys_or_ids', 'recipient_audience', 'public', 'default_to_direct_discussion'
  ]}
}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@/shared/services/ability_service', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/shared/services/bookmark_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));
vi.mock('@/components/discussion_template/form', () => ({default: {
  name: 'DiscussionTemplateForm', props: ['discussionTemplate'], template: '<div />'
}}));

import DiscussionModel from '@/shared/models/discussion_model';
import DiscussionTemplateModel from '@/shared/models/discussion_template_model';
import DiscussionService from '@/shared/services/discussion_service';
import DiscussionTemplateFormPage from '@/components/discussion_template/form_page.vue';

let source, group, topic, creationItem, wrapper;

beforeEach(() => {
  vi.clearAllMocks();
  mocks.signedIn = true;
  group = {id: 7, membersCanCreateTemplates: false, adminsInclude: () => true, membersInclude: () => true};
  topic = {id: 8, newestFirst: true, maxDepth: 2, allowConcurrentPolls: true,
    allowComments: false, allowReactions: false, commentLengthMax: 400, attachmentsAdminOnly: true, tags: ['Review', 'Reply tag']};
  creationItem = {tags: ['Review']};
  mocks.findTopicItems.mockReturnValue([creationItem]);
  mocks.fetchTopicItems.mockImplementation(async () => mocks.findTopicItems.mockReturnValue([creationItem]));
  source = new DiscussionModel({id: 10, key: 'source', groupId: 7, topicId: 8, authorId: 1,
    title: 'Monthly project review', description: '<p>What worked?</p>', descriptionFormat: 'html',
    contentLocale: 'fr', lockedAt: new Date(), pinnedAt: new Date(), createdAt: new Date(),
    recipientUserIds: [2, 3], pollTemplateKeysOrIds: ['proposal', 9]});
  source.group = () => group;
  source.topic = () => topic;
  mocks.buildTemplate.mockImplementation(attrs => new DiscussionTemplateModel(attrs));
  mocks.buildDiscussion.mockImplementation(() => new DiscussionModel());
  mocks.fetchDiscussion.mockResolvedValue(source);
});

afterEach(() => wrapper?.unmount());

describe('saving a discussion as a template', () => {
  it('copies content, its own tags and current thread settings without participants or activity', () => {
    const template = source.buildTemplate();
    expect(template.isNew()).toBe(true);
    expect(template).toMatchObject({groupId: 7, processName: source.title, title: source.title,
      description: source.description, descriptionFormat: 'html', contentLocale: 'fr', tags: ['Review'],
      newestFirst: true, maxDepth: 2, allowConcurrentPolls: true, allowComments: false, allowReactions: false,
      commentLengthMax: 400, attachmentsAdminOnly: true, pollTemplateKeysOrIds: ['proposal', 9], public: false, defaultToDirectDiscussion: false});
    for (const field of ['id', 'key', 'topicId', 'authorId', 'createdAt', 'lockedAt', 'pinnedAt', 'recipientUserIds']) {
      expect(template.attributeNames).not.toContain(field);
    }
    template.tags.push('Template only');
    template.pollTemplateKeysOrIds.push('check');
    expect(creationItem.tags).toEqual(['Review']);
    expect(topic.tags).toEqual(['Review', 'Reply tag']);
    expect(source.pollTemplateKeysOrIds).toEqual(['proposal', 9]);
  });

  it('creates a fresh discussion from the saved configuration', () => {
    const template = source.buildTemplate();
    template.id = 9;
    const discussion = template.buildDiscussion();
    expect(discussion.isNew()).toBe(true);
    expect(discussion).toMatchObject({title: source.title, description: source.description,
      tags: ['Review'], allowComments: false, allowReactions: false, commentLengthMax: 400, attachmentsAdminOnly: true,
      discussionTemplateId: 9, authorId: 2, pinnedAt: null, recipientUserIds: []});
  });

  it.each([
    ['group admin', true, true, false, true, true],
    ['member with permission', true, false, true, true, true],
    ['member without permission', true, false, false, true, false],
    ['thread admin or guest', true, false, true, false, false],
    ['signed-out visitor', false, false, true, false, false],
    ['nonmember', true, false, false, false, false]
  ])('offers Save as template according to template creation permissions for a %s', (_role, signedIn, admin, enabled, member, allowed) => {
    mocks.signedIn = signedIn;
    Object.assign(group, {membersCanCreateTemplates: enabled, adminsInclude: () => admin, membersInclude: () => member});
    const actions = DiscussionService.actions(source);
    expect(actions).not.toHaveProperty('make_a_copy');
    expect(actions.save_as_template.canPerform()).toBe(allowed);
    expect(actions.save_as_template.name).toBe('common.action.save_as_template');
    expect(actions.save_as_template.to()).toEqual({path: '/discussion_templates/new',
      query: {discussion_id: 10, return_to: '/d/source'}});
  });

  it('does not offer templates for direct or discarded discussions', () => {
    group.id = null;
    expect(DiscussionService.actions(source).save_as_template.canPerform()).toBe(false);
    group.id = 7;
    source.discardedAt = new Date();
    expect(DiscussionService.actions(source).save_as_template.canPerform()).toBe(false);
  });
});

describe('template form loaded from a discussion', () => {
  async function mountPage() {
    wrapper = shallowMount(DiscussionTemplateFormPage, {global: {
      mocks: {$route: {params: {}, query: {discussion_id: '10'}}},
      stubs: {VMain: {template: '<main><slot /></main>'}, VContainer: {template: '<div><slot /></div>'}}
    }});
    await flushPromises();
  }
  const form = () => wrapper.findComponent({name: 'DiscussionTemplateForm'});

  it('uses the loaded creation item without another fetch', async () => {
    await mountPage();
    expect(form().props('discussionTemplate').tags).toEqual(['Review']);
    expect(mocks.fetchDiscussion).toHaveBeenCalledWith(10);
    expect(mocks.fetchTopicItems).not.toHaveBeenCalled();
  });

  it('fetches a missing creation item after refresh', async () => {
    mocks.findTopicItems.mockReturnValue([]);
    await mountPage();
    expect(mocks.fetchTopicItems).toHaveBeenCalledWith({params: {discussion_key: 'source', sequence_id: 0, per: 1}});
    expect(form().props('discussionTemplate').tags).toEqual(['Review']);
  });

  it('waits for the creation item before showing the form', async () => {
    mocks.findTopicItems.mockReturnValue([]);
    let resolveFetch;
    mocks.fetchTopicItems.mockReturnValue(new Promise(resolve => { resolveFetch = resolve; }));
    await mountPage();
    expect(form().exists()).toBe(false);
    mocks.findTopicItems.mockReturnValue([creationItem]);
    resolveFetch();
    await flushPromises();
    expect(form().props('discussionTemplate').tags).toEqual(['Review']);
  });

  it('rejects a manually entered route without template creation permission', async () => {
    group.adminsInclude = () => false;
    await mountPage();
    expect(mocks.emit).toHaveBeenCalledWith('pageError', expect.objectContaining({status: 403}));
    expect(mocks.buildTemplate).not.toHaveBeenCalled();
    expect(mocks.fetchTopicItems).not.toHaveBeenCalled();
  });

  it.each(['discussion', 'creation item'])('shows a %s access failure without building a template', async resource => {
    const error = Object.assign(new Error('Forbidden'), {status: 403});
    if (resource === 'discussion') { mocks.fetchDiscussion.mockRejectedValue(error); }
    else {
      mocks.findTopicItems.mockReturnValue([]);
      mocks.fetchTopicItems.mockRejectedValue(error);
    }
    await mountPage();
    expect(mocks.emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.buildTemplate).not.toHaveBeenCalled();
  });
});
