import { shallowMount, flushPromises } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  route: null,
  signedIn: true,
  groupIds: [7],
  emit: vi.fn(),
  fetchDiscussion: vi.fn(),
  fetchTemplateId: vi.fn(),
  fetchTemplateKey: vi.fn(),
  fetchGroup: vi.fn(),
  fetchUser: vi.fn(),
  build: vi.fn()
}));

vi.mock('vue-router', () => ({useRoute: () => mocks.route}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));
vi.mock('@/shared/services/session', () => ({default: {
  isSignedIn: () => mocks.signedIn,
  user: () => ({groupIds: () => mocks.groupIds}),
  defaultFormat: () => 'md'
}}));
vi.mock('@/shared/services/records', () => ({default: {
  discussions: {findOrFetchById: mocks.fetchDiscussion, build: mocks.build},
  discussionTemplates: {findOrFetchById: mocks.fetchTemplateId, findOrFetchByKey: mocks.fetchTemplateKey},
  groups: {findOrFetchById: mocks.fetchGroup},
  users: {findOrFetchById: mocks.fetchUser}
}}));
vi.mock('@/components/discussion/form.vue', () => ({default: {
  name: 'DiscussionForm',
  props: ['discussion', 'user'],
  template: '<div class="discussion-form">{{ discussion.title }}</div>'
}}));

import DiscussionFormPage from '@/components/discussion/form_page.vue';

const loadCases = [
  ['edit', {key: 'private-thread'}, {}, mocks.fetchDiscussion],
  ['template ID', {}, {template_id: '12'}, mocks.fetchTemplateId],
  ['template key', {}, {template_key: 'planning'}, mocks.fetchTemplateKey],
  ['copy', {}, {discussion_id: '41'}, mocks.fetchDiscussion],
  ['group', {}, {group_id: '7'}, mocks.fetchGroup],
  ['recipient', {}, {user_id: '2'}, mocks.fetchUser]
];

describe('discussion form page loading', () => {
  let wrapper;
  let original;
  let template;

  beforeEach(() => {
    vi.resetAllMocks();
    mocks.route = reactive({params: {}, query: {title: 'New discussion'}});
    mocks.signedIn = true;
    mocks.groupIds = [7];
    mocks.build.mockImplementation(attributes => attributes);
    original = {
      groupId: 7,
      clone: vi.fn(() => ({id: 41, title: 'Edited discussion', groupId: 7})),
      buildCopy: vi.fn(() => ({title: 'Copied discussion', groupId: null}))
    };
    template = {
      defaultToDirectDiscussion: false,
      buildDiscussion: vi.fn(() => ({title: 'From template', groupId: null}))
    };
    mocks.fetchDiscussion.mockResolvedValue(original);
    mocks.fetchTemplateId.mockResolvedValue(template);
    mocks.fetchTemplateKey.mockResolvedValue(template);
    mocks.fetchGroup.mockResolvedValue({id: 7});
    mocks.fetchUser.mockResolvedValue({id: 2});
  });

  afterEach(() => wrapper?.unmount());

  async function mountPage() {
    wrapper = shallowMount(DiscussionFormPage, {global: {stubs: {
      VMain: {template: '<main><slot /></main>'},
      VContainer: {template: '<div><slot /></div>'},
      DiscussionForm: false
    }}});
    await flushPromises();
    return wrapper;
  }

  const form = () => wrapper.findComponent({name: 'DiscussionForm'});

  it.each(loadCases)('shows a page error when the %s load is forbidden', async (_name, params, query, fetchRecord) => {
    mocks.route.params = params;
    mocks.route.query = query;
    const error = Object.assign(new Error('Forbidden'), {status: 403});
    fetchRecord.mockRejectedValue(error);

    await mountPage();

    expect(mocks.emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.emit).not.toHaveBeenCalledWith('openAuthModal');
    expect(form().exists()).toBe(false);
    expect(mocks.build).not.toHaveBeenCalled();
    expect(original.clone).not.toHaveBeenCalled();
    expect(original.buildCopy).not.toHaveBeenCalled();
    expect(template.buildDiscussion).not.toHaveBeenCalled();
  });

  it('prompts a signed-out visitor to sign in after a forbidden edit load', async () => {
    mocks.route.params = {key: 'private-thread'};
    mocks.signedIn = false;
    const error = Object.assign(new Error('Forbidden'), {status: 403});
    mocks.fetchDiscussion.mockRejectedValue(error);

    await mountPage();

    expect(mocks.emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.emit).toHaveBeenCalledWith('openAuthModal');
    expect(form().exists()).toBe(false);
  });

  it.each([404, 500])('shows an HTTP %s error without prompting for sign-in', async status => {
    mocks.route.params = {key: 'unavailable-thread'};
    mocks.signedIn = false;
    const error = Object.assign(new Error('Unavailable'), {status});
    mocks.fetchDiscussion.mockRejectedValue(error);

    await mountPage();

    expect(mocks.emit).toHaveBeenCalledWith('pageError', error);
    expect(mocks.emit).not.toHaveBeenCalledWith('openAuthModal');
    expect(form().exists()).toBe(false);
  });

  it('loads an editable clone and refreshes when the route key changes', async () => {
    mocks.route.params = {key: 'existing-thread'};
    await mountPage();

    expect(form().props('discussion')).toEqual({id: 41, title: 'Edited discussion', groupId: 7});
    expect(mocks.emit).not.toHaveBeenCalledWith('pageError', expect.anything());

    mocks.fetchDiscussion.mockResolvedValue({clone: () => ({id: 42, title: 'Other discussion'})});
    mocks.route.params.key = 'other-thread';
    await nextTick();
    await flushPromises();

    expect(form().props('discussion').id).toBe(42);
  });

  it.each(['template_id', 'template_key'])('uses the selected group for %s unless the template requires a direct discussion', async key => {
    mocks.route.query = {[key]: key === 'template_id' ? '12' : 'planning', group_id: '7'};
    await mountPage();
    expect(form().props('discussion').groupId).toBe(7);

    template.defaultToDirectDiscussion = true;
    mocks.route.query = {...mocks.route.query, title: 'Direct discussion'};
    await nextTick();
    await flushPromises();
    expect(form().props('discussion').groupId).toBe(null);
  });

  it.each([true, false])('retains the copied group only when the user belongs to it (member: %s)', async member => {
    mocks.route.query = {discussion_id: '41'};
    mocks.groupIds = member ? [7] : [];
    await mountPage();

    expect(form().props('discussion').groupId).toBe(member ? 7 : null);
    expect(original.clone).not.toHaveBeenCalled();
  });

  it('builds a discussion after loading the selected group', async () => {
    mocks.route.query = {group_id: '7', title: 'Group discussion'};
    await mountPage();

    expect(form().props('discussion')).toEqual({title: 'Group discussion', groupId: 7, descriptionFormat: 'md'});
  });

  it('builds a direct discussion with the selected recipient', async () => {
    mocks.route.query = {user_id: '2', title: 'Direct discussion'};
    await mountPage();

    expect(form().props('discussion')).toEqual({title: 'Direct discussion', groupId: null, descriptionFormat: 'md'});
    expect(form().props('user')).toEqual({id: 2});
  });

  it('builds a new discussion without fetching a record', async () => {
    await mountPage();

    expect(form().props('discussion')).toEqual({title: 'New discussion', descriptionFormat: 'md'});
    expect(mocks.fetchDiscussion).not.toHaveBeenCalled();
  });
});
