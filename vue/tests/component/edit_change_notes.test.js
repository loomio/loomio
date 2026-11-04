import { mount, flushPromises } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { createVuetify } from 'vuetify';
import { createRouter, createMemoryHistory } from 'vue-router';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Loki from 'lokijs';

const mocks = vi.hoisted(() => ({
  fetch: vi.fn(),
  count: vi.fn(),
  update: vi.fn(),
  group: null,
  user: null,
  users: null,
  itemable: null,
  topic: null
}));

// Keep the real components, Vuetify controls, permission checks, record models,
// serializer and save method. Only application bootstrap and the data/HTTP
// boundaries are substituted; these tests do not exercise a Rails server.
vi.mock('@/shared/services/records', () => ({default: {
  fetch: mocks.fetch,
  remote: {fetch: mocks.count},
  groups: {find: () => mocks.group, nullModel: () => mocks.group},
  topics: {find: () => mocks.topic},
  discussions: {find: () => mocks.itemable, remote: {update: mocks.update}},
  polls: {find: () => mocks.itemable, remote: {update: mocks.update}},
  users: {
    get collection() { return mocks.users; },
    find: ids => Array.isArray(ids)
      ? mocks.users.find({id: {$in: ids}})
      : mocks.users.findOne({id: ids})
  }
}}));
vi.mock('@/shared/services/session', () => ({default: {
  user: () => mocks.user,
  isSignedIn: () => true
}}));
vi.mock('@/shared/services/app_config', () => ({default: {
  defaultLocale: 'en',
  timeZone: 'UTC',
  theme: {brand_colors: {yellow425: '#ffee55', blue400: '#3366aa', blue50: '#eeeeff', grey100: '#eeeeee'}}
}}));
vi.mock('@/shared/services/flash', () => ({default: {fromServer: vi.fn()}}));
vi.mock('@/i18n', async () => {
  const { createI18n } = await import('vue-i18n');
  const { default: locale } = await import('../../../config/locales/client.en.yml');
  return {
    I18n: createI18n({legacy: false, locale: 'en', messages: locale, warnHtmlMessage: false}),
    dateLocale: undefined
  };
});

import { I18n } from '@/i18n';
import NotifyFields from '@/components/common/notify_fields.vue';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete.vue';
import DiscussionEdited from '@/components/topic_items/discussion_edited.vue';
import PollEdited from '@/components/topic_items/poll_edited.vue';
import DiscussionModel from '@/shared/models/discussion_model';
import PollModel from '@/shared/models/poll_model';
import TopicItemModel from '@/shared/models/topic_item_model';
import UserModel from '@/shared/models/user_model';

const note = 'Corrected the meeting date from Monday to Tuesday';
const modelCases = [
  {kind: 'discussion', Model: DiscussionModel, Edited: DiscussionEdited, headline: 'edited the thread context'},
  {kind: 'poll', Model: PollModel, Edited: PollEdited, headline: 'edited the proposal'}
];

describe.each(modelCases)('$kind edit notes and Notify controls', ({kind, Model, Edited, headline}) => {
  let wrapper;
  let model;
  let recipient;

  beforeEach(() => {
    vi.clearAllMocks();
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    mocks.group = {
      id: 7,
      name: 'Planning group',
      namedId: () => ({group_id: 7}),
      membershipsCount: 3,
      isEnabled: () => true,
      adminsInclude: () => true,
      membersInclude: () => true,
      chatbots: () => [{id: 91, name: 'Planning webhook'}]
    };
    mocks.users = new Loki('edit-note-users').addCollection('users');
    mocks.user = new UserModel({id: 1, name: 'Alex Editor', username: 'alex', avatarKind: 'initials', avatarInitials: 'AE'});
    recipient = new UserModel({id: 2, name: 'Jamie Recipient', username: 'jamie', email: 'jamie@example.test', avatarKind: 'initials', avatarInitials: 'JR'});
    mocks.users.insert([mocks.user, recipient]);
    model = reactive(new Model({id: 41, key: 'editing-thread', groupId: 7, topicId: 61, title: 'Planning meeting'}));
    mocks.itemable = model;
    mocks.topic = {topicable: () => model};
    mocks.fetch.mockImplementation(({path}) => {
      if (path === 'chatbots') return Promise.resolve({});
      if (path === 'announcements/available_audiences') return Promise.resolve({audiences: [
        {id: 'group-7', kind: 'group', name: 'Planning group', size: 3},
        {id: 'topic', kind: 'topic', size: 2},
        ...(kind === 'poll' ? [{id: 'voters', kind: 'voters', size: 2}] : [])
      ]});
      if (path === 'announcements/search') return Promise.resolve({users: [{id: recipient.id}]});
      throw new Error(`Unexpected records request: ${path}`);
    });
    mocks.count.mockResolvedValue({count: 1});
    mocks.update.mockResolvedValue({});
  });

  afterEach(() => {
    // The autocomplete's search is debounced, including its mount-time call.
    RecipientsAutocomplete.methods.fetchSuggestions.cancel();
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  function globalOptions() {
    return {plugins: [
      createVuetify(),
      I18n,
      createRouter({history: createMemoryHistory(), routes: [{path: '/:pathMatch(.*)*', component: {template: '<div />'}}]})
    ]};
  }

  async function mountFields(props = {}) {
    wrapper = mount(NotifyFields, {
      props: {model, ...props},
      attachTo: document.body,
      global: globalOptions()
    });
    await flushPromises();
  }

  function noteInput() {
    return wrapper.get('input[placeholder="Optionally, describe your changes. This message will be added to the discussion."]');
  }

  function notifyInput() {
    return wrapper.get('.recipients-autocomplete input');
  }

  async function selectSuggestion(text) {
    await notifyInput().trigger('focus');
    await notifyInput().trigger('mousedown');
    await flushPromises();
    const suggestion = [...document.querySelectorAll('.v-overlay .recipients-autocomplete-suggestion')]
      .find(element => element.textContent.includes(text));
    expect(suggestion, `Visible Notify option: ${text}`).toBeTruthy();
    suggestion.click();
    await nextTick();
    await flushPromises();
  }

  async function expectSavedRecipients(attributes) {
    await model.save();
    expect(mocks.update).toHaveBeenLastCalledWith('editing-thread', expect.objectContaining({
      [kind]: expect.objectContaining({recipient_message: note, ...attributes})
    }));
  }

  it('sends the typed change note through the real model save path with nobody selected', async () => {
    await mountFields();
    expect(wrapper.text()).toContain("What's changed?");
    await noteInput().setValue(note);

    expect(model.recipientMessage).toBe(note);
    expect(wrapper.get('.recipients-autocomplete').text()).toContain('Notify');
    await expectSavedRecipients({
      recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: [], notify_recipients: true
    });
    expect(model.recipientAudience).toBeUndefined();
    expect(mocks.count).not.toHaveBeenCalled();
  });

  it('clears an existing change note in the actual text input and request', async () => {
    model.recipientMessage = note;
    await mountFields();
    expect(noteInput().element.value).toBe(note);
    await noteInput().setValue('');
    await model.save();

    expect(model.recipientMessage).toBe('');
    expect(mocks.update).toHaveBeenLastCalledWith('editing-thread', expect.objectContaining({
      [kind]: expect.objectContaining({recipient_message: ''})
    }));
  });

  it('selects the group audience in Notify and sends its count and save parameters', async () => {
    await mountFields();
    await noteInput().setValue(note);
    await selectSuggestion('Planning group');

    expect(model.recipientAudience).toBe('group-7');
    expect(mocks.fetch).toHaveBeenCalledWith({path: 'announcements/available_audiences', params: {
      include_actor: null, exclude_members: null, [`${kind}_id`]: 41
    }});
    expect(mocks.count).toHaveBeenLastCalledWith({path: 'announcements/count', params: {
      recipient_emails_cmr: '', recipient_user_xids: '', recipient_chatbot_xids: '',
      recipient_audience: 'group-7', include_actor: null, [`${kind}_id`]: 41
    }});
    await expectSavedRecipients({recipient_audience: 'group-7', recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: []});
  });

  it('searches for and selects a person using the actual Notify dropdown', async () => {
    await mountFields();
    await noteInput().setValue(note);
    await notifyInput().trigger('focus');
    await notifyInput().setValue('Jamie');
    await vi.waitFor(() => expect(mocks.fetch).toHaveBeenCalledWith({path: 'announcements/search', params: {
      exclude_types: 'group inviter', q: 'Jamie', per: 20,
      include_actor: null, exclude_members: null, [`${kind}_id`]: 41
    }}), {timeout: 2000});
    await flushPromises();
    await selectSuggestion('Jamie Recipient');

    expect(model.recipientUserIds).toEqual([2]);
    expect(wrapper.get('.recipients-autocomplete').text()).toContain('Jamie Recipient');
    expect(mocks.count).toHaveBeenLastCalledWith({path: 'announcements/count', params: {
      recipient_emails_cmr: '', recipient_user_xids: '2', recipient_chatbot_xids: '',
      recipient_audience: undefined, include_actor: null, [`${kind}_id`]: 41
    }});
    await expectSavedRecipients({recipient_user_ids: [2], recipient_emails: [], recipient_chatbot_ids: []});
  });

  it('turns a pasted guest email into a recipient without losing the change note', async () => {
    await mountFields();
    await noteInput().setValue(note);
    await notifyInput().setValue('guest@example.test, ');
    await flushPromises();

    expect(model.recipientEmails).toEqual(['guest@example.test']);
    expect(wrapper.get('.recipients-autocomplete').text()).toContain('guest@example.test');
    expect(mocks.count).toHaveBeenLastCalledWith({path: 'announcements/count', params: {
      recipient_emails_cmr: 'guest@example.test', recipient_user_xids: '', recipient_chatbot_xids: '',
      recipient_audience: undefined, include_actor: null, [`${kind}_id`]: 41
    }});
    await expectSavedRecipients({recipient_user_ids: [], recipient_emails: ['guest@example.test'], recipient_chatbot_ids: []});
  });

  it('selects a chatbot in Notify and serializes its ID separately', async () => {
    await mountFields();
    await noteInput().setValue(note);
    await selectSuggestion('Planning webhook');

    expect(model.recipientChatbotIds).toEqual([91]);
    expect(mocks.count).toHaveBeenLastCalledWith({path: 'announcements/count', params: {
      recipient_emails_cmr: '', recipient_user_xids: '', recipient_chatbot_xids: '91',
      recipient_audience: undefined, include_actor: null, [`${kind}_id`]: 41
    }});
    await expectSavedRecipients({recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: [91]});
  });

  it('removes a selected Notify audience without clearing the change note', async () => {
    await mountFields();
    await noteInput().setValue(note);
    await selectSuggestion('Planning group');
    await wrapper.get('.recipients-autocomplete .v-chip__close').trigger('click');
    await flushPromises();

    expect(model.recipientAudience).toBeUndefined();
    expect(wrapper.find('.recipients-autocomplete .v-chip').exists()).toBe(false);
    await expectSavedRecipients({recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: []});
  });

  it('clears multiple Notify selections without clearing the change note', async () => {
    await mountFields();
    await noteInput().setValue(note);
    await notifyInput().setValue('first@example.test, second@example.test');
    await flushPromises();
    await selectSuggestion('Planning webhook');
    expect(model.recipientEmails).toEqual(['first@example.test', 'second@example.test']);
    expect(model.recipientChatbotIds).toEqual([91]);

    await wrapper.get('.recipients-autocomplete [aria-label="Clear Notify"]').trigger('click');
    await flushPromises();

    expect(wrapper.find('.recipients-autocomplete .v-chip').exists()).toBe(false);
    expect(model.recipientAudience).toBeUndefined();
    expect(notifyInput().element.value).toBe('');
    await expectSavedRecipients({recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: []});
  });

  if (kind === 'poll') {
    it('selects the poll voter audience without replacing the edit note', async () => {
      await mountFields();
      await noteInput().setValue(note);
      await selectSuggestion('Everyone invited to vote');

      expect(model.recipientAudience).toBe('voters');
      expect(mocks.count).toHaveBeenLastCalledWith({path: 'announcements/count', params: {
        recipient_emails_cmr: '', recipient_user_xids: '', recipient_chatbot_xids: '',
        recipient_audience: 'voters', include_actor: null, poll_id: 41
      }});
      await expectSavedRecipients({recipient_audience: 'voters', recipient_user_ids: [], recipient_emails: [], recipient_chatbot_ids: []});
    });
  }

  it('hides the change-note field for a new record', async () => {
    model.id = null;
    await mountFields();

    expect(wrapper.text()).not.toContain("What's changed?");
    expect(wrapper.findAll('input')).toHaveLength(1);
  });

  it('renders the real edited timeline headline from the current API-shaped record', () => {
    const topicItem = new TopicItemModel({
      id: 81, kind: `${kind}_edited`, topicId: 61, sequenceId: 2, actorId: 1,
      itemableType: kind === 'discussion' ? 'Discussion' : 'Poll', itemableId: 41,
      createdAt: new Date('2026-10-01T12:00:00Z')
    });
    wrapper = mount(Edited, {props: {topic_item: topicItem, itemable: model}, global: globalOptions()});

    expect(wrapper.get('h3').text()).toContain(`Alex Editor ${headline}`);
    expect(wrapper.get('a.actor-link').attributes('href')).toBe('/u/alex');
    expect(wrapper.get('.time-ago').attributes('title')).toContain('2026-10-01');
    expect(wrapper.find('.topic-item__body').exists()).toBe(false);
  });

  it('renders the saved note as escaped text and updates it after record import', async () => {
    const unsafeNote = '<script>alert(1)</script>\n<img src=x onerror=alert(2)> & details';
    const topicItem = reactive(new TopicItemModel({
      id: 81, kind: `${kind}_edited`, topicId: 61, actorId: 1,
      itemableType: kind === 'discussion' ? 'Discussion' : 'Poll', itemableId: 41,
      createdAt: new Date('2026-10-01T12:00:00Z'), changeNote: unsafeNote
    }));
    wrapper = mount(Edited, {props: {topic_item: topicItem, itemable: model}, global: globalOptions()});

    expect(wrapper.get('.topic-item__body').element.textContent).toBe(unsafeNote);
    expect(wrapper.get('.topic-item__body').element.style.whiteSpace).toBe('pre-wrap');
    expect(wrapper.find('script').exists()).toBe(false);
    expect(wrapper.find('img').exists()).toBe(false);
    expect(wrapper.get('h3').text()).toContain(`Alex Editor ${headline}`);

    topicItem.changeNote = 'Second saved note';
    await nextTick();
    expect(wrapper.get('.topic-item__body').text()).toBe('Second saved note');
    topicItem.changeNote = null;
    await nextTick();
    expect(wrapper.find('.topic-item__body').exists()).toBe(false);
  });
});
