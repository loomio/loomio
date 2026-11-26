import { mount, flushPromises } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { createVuetify } from 'vuetify';
import { VAutocomplete } from 'vuetify/components';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const fetchMock = vi.fn();
const usersById = {};

vi.mock('@/shared/services/records', () => ({
  default: {
    fetch: (...args) => fetchMock(...args),
    users: {
      collection: {
        chain: () => ({
          find() { return this; },
          data: () => []
        })
      },
      find: ids => ids.map(id => usersById[id]).filter(Boolean)
    }
  }
}));

vi.mock('@/shared/services/flash', () => ({
  default: { fromServer: vi.fn(), success: vi.fn(), error: vi.fn() }
}));

vi.mock('@/shared/services/app_config', () => ({
  default: {
    features: { app: { subscriptions: false } },
    theme: { brand_colors: { primary: '#000000' } }
  }
}));

vi.mock('@/shared/services/session', () => ({
  default: {
    userId: 1,
    user: () => ({ emailInvitationsAllowed: () => true })
  }
}));

vi.mock('@/shared/abilities/topic_ability', () => ({
  default: { canAddGuests: () => true, canAnnounce: () => true }
}));
vi.mock('@/shared/abilities/discussion_ability', () => ({
  default: { canAddGuests: () => true, canAnnounce: () => true }
}));
vi.mock('@/shared/abilities/group_ability', () => ({
  default: { canAddMembers: () => true, canNotify: () => true }
}));
vi.mock('@/shared/abilities/poll_ability', () => ({
  default: { canAddGuests: () => true, canAnnounce: () => true }
}));

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete.vue';

describe('recipients autocomplete multiple groups', () => {
  let wrapper;
  let topic;

  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({ matches: false, addEventListener() {}, removeEventListener() {} }));

    fetchMock.mockReset();
    fetchMock.mockImplementation(({ path, params }) => {
      if (path === 'announcements/available_audiences') {
        return Promise.resolve({
          audiences: [
            { id: 'group-10', kind: 'group', name: 'Core Team', size: 2 },
            { id: 'group-20', kind: 'group', name: 'TAC', size: 3 },
            { id: 'delegates-20', kind: 'delegates', name: 'TAC', size: 2 }
          ]
        });
      }
      if (path === 'announcements/audience' && params.recipient_audience === 'group-10') {
        return Promise.resolve({ users: [{ id: 2 }, { id: 3 }] });
      }
      return Promise.resolve({ users: [] });
    });

    usersById[2] = { id: 2, nameOrEmail: () => 'Alice', email: 'alice@example.com' };
    usersById[3] = { id: 3, nameOrEmail: () => 'Bob', email: 'bob@example.com' };

    topic = reactive({
      id: 99,
      groupId: 10,
      recipientAudience: null,
      recipientUserIds: [],
      recipientEmails: [],
      recipientChatbotIds: [],
      isA: type => type === 'topic',
      bestNamedId: () => ({ topic_id: 99 }),
      group: () => ({ id: 10, chatbots: () => [] }),
      constructor: { singular: 'topic' }
    });
  });

  afterEach(() => {
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  function mountAutocomplete() {
    wrapper = mount(RecipientsAutocomplete, {
      props: { model: topic, hideCount: true },
      attachTo: document.body,
      global: {
        plugins: [createVuetify()],
        mocks: { $t: (key, args) => (args?.name ? `${key}:${args.name}` : key) },
        stubs: {
          NotificationsCount: true,
          CommonIcon: true,
          UserAvatar: true,
          space: true
        },
        directives: { t: () => {} }
      }
    });
  }

  it('keeps remaining group audiences available after selecting a first group and joins selected audience ids', async () => {
    mountAutocomplete();
    await flushPromises();

    const firstGroup = wrapper.vm.suggestions.find(s => s.id === 'group-10');
    const secondGroup = wrapper.vm.suggestions.find(s => s.id === 'group-20');
    expect(firstGroup).toBeTruthy();
    expect(secondGroup).toBeTruthy();

    wrapper.findComponent(VAutocomplete).vm.$emit('update:modelValue', [firstGroup]);
    await nextTick();

    expect(topic.recipientAudience).toBe('group-10');
    expect(wrapper.vm.suggestions.some(s => s.id === 'group-20')).toBe(true);

    wrapper.findComponent(VAutocomplete).vm.$emit('update:modelValue', [firstGroup, secondGroup]);
    await nextTick();

    expect(topic.recipientAudience).toBe('group-10,group-20');
  });

  it('expands one group chip without removing other selected groups or duplicating users', async () => {
    mountAutocomplete();
    await flushPromises();

    const firstGroup = wrapper.vm.suggestions.find(s => s.id === 'group-10');
    const secondGroup = wrapper.vm.suggestions.find(s => s.id === 'group-20');
    const existingAlice = { id: 2, type: 'user', name: 'Alice', user: usersById[2] };

    wrapper.findComponent(VAutocomplete).vm.$emit('update:modelValue', [firstGroup, secondGroup, existingAlice]);
    await nextTick();

    wrapper.vm.expand(firstGroup);
    await flushPromises();
    await nextTick();

    expect(topic.recipientAudience).toBe('group-20');
    expect(topic.recipientUserIds).toEqual([2, 3]);
  });
});
