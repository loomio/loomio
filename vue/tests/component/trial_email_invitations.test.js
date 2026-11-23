import { mount, flushPromises } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Database from '@/shared/record_store/db';

const mocks = vi.hoisted(() => ({
  subscriptions: true,
  emit: vi.fn(),
  fetch: vi.fn(() => Promise.resolve({ audiences: [], users: [] })),
  count: vi.fn(() => Promise.resolve({ count: 0 })),
  groups: null,
  memberships: null,
  users: null,
  user: null
}));

vi.mock('@/shared/services/app_config', () => ({
  default: {
    defaultLocale: 'en',
    baseUrl: 'https://loomio.example/',
    get features() {
      return { app: { subscriptions: mocks.subscriptions, loomio_subscriptions: false } };
    },
    theme: { brand_colors: { yellow425: '#ffee55', blue400: '#3366aa', blue50: '#eeeeff', grey100: '#eeeeee' } }
  }
}));
vi.mock('@/shared/services/event_bus', () => ({ default: { $emit: mocks.emit, $on: vi.fn(), $off: vi.fn() } }));
vi.mock('@/shared/services/flash', () => ({ default: { success: vi.fn(), error: vi.fn(), fromServer: vi.fn() } }));
vi.mock('@/shared/services/session', () => ({
  default: {
    user: () => mocks.user,
    get userId() { return mocks.user?.id; },
    isSignedIn: () => true
  }
}));
vi.mock('@/shared/services/records', () => ({
  default: {
    fetch: mocks.fetch,
    remote: { fetch: mocks.count },
    groups: {
      find: query => typeof query === 'object' ? mocks.groups.find(query) : mocks.groups.findOne({ id: query }),
      nullModel: () => new NullGroupModel(),
      remote: {
        getMember: vi.fn(() => Promise.resolve()),
        postMember: vi.fn(() => Promise.resolve())
      }
    },
    memberships: {
      find: query => mocks.memberships.find(query)
    },
    chatbots: {
      find: () => []
    },
    users: {
      get collection() { return mocks.users; },
      find: ids => Array.isArray(ids)
        ? mocks.users.find({ id: { $in: ids } })
        : mocks.users.findOne({ id: ids })
    },
    topics: {
      find: () => ({ id: 10, groupId: null, lockedAt: null, adminsInclude: () => true })
    }
  }
}));
vi.mock('@/i18n', async () => {
  const { createI18n } = await import('vue-i18n');
  const { default: locale } = await import('../../../config/locales/client.en.yml');
  return {
    I18n: createI18n({ legacy: false, locale: 'en', messages: locale, warnHtmlMessage: false }),
    dateLocale: undefined
  };
});

import { I18n } from '@/i18n';
import GroupModel from '@/shared/models/group_model';
import NullGroupModel from '@/shared/models/null_group_model';
import MembershipModel from '@/shared/models/membership_model';
import UserModel from '@/shared/models/user_model';
import DiscussionModel from '@/shared/models/discussion_model';
import GroupShareableLinkForm from '@/components/group/shareable_link_form.vue';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete.vue';
import TipService from '@/shared/services/tip_service';

describe('Trial email invitation flag and shareable link UX', () => {
  let wrapper;

  beforeEach(() => {
    vi.clearAllMocks();
    mocks.subscriptions = true;
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({ matches: false, addEventListener() {}, removeEventListener() {} }));

    const db = new Database();
    mocks.groups = db.addCollection('groups', { indices: ['id', 'parentId'] });
    mocks.memberships = db.addCollection('memberships', { indices: ['id', 'userId', 'groupId'] });
    mocks.users = db.addCollection('users', { indices: ['id'] });

    mocks.user = new UserModel({ id: 1, name: 'Rob', email: 'rob@example.test', emailVerified: true });
    mocks.users.insert(mocks.user);
  });

  afterEach(() => {
    wrapper?.unmount();
    vi.unstubAllGlobals();
  });

  function insertGroup(attrs) {
    const group = new GroupModel({
      id: 100,
      key: 'trial-key',
      name: 'Trial Group',
      token: 'abc123',
      orgMembersCount: 2,
      subscription: { plan: 'trial', state: 'active', max_members: 10, allow_guests: true, allow_email_invitations: false },
      ...attrs
    });
    mocks.groups.insert(group);
    return group;
  }

  function insertMembership(attrs) {
    const membership = new MembershipModel({
      id: 1,
      userId: mocks.user.id,
      groupId: 100,
      admin: true,
      acceptedAt: '2026-11-24T00:00:00Z',
      revokedAt: null,
      ...attrs
    });
    mocks.memberships.insert(membership);
    return membership;
  }

  it('evaluates GroupModel#emailInvitationsAllowed and UserModel#emailInvitationsAllowed from subscription flags', () => {
    const trial = insertGroup({ id: 100, subscription: { plan: 'trial', state: 'active', allow_email_invitations: false } });
    insertMembership({ id: 1, groupId: 100 });

    expect(trial.emailInvitationsAllowed()).toBe(false);
    expect(mocks.user.emailInvitationsAllowed()).toBe(false);

    trial.subscription.allow_email_invitations = true;
    expect(trial.emailInvitationsAllowed()).toBe(true);
    expect(mocks.user.emailInvitationsAllowed()).toBe(true);

    trial.subscription.allow_email_invitations = false;
    mocks.subscriptions = false;
    expect(trial.emailInvitationsAllowed()).toBe(true);
    expect(mocks.user.emailInvitationsAllowed()).toBe(true);
  });

  it('shows the trial upgrade note in GroupShareableLinkForm only when email invitations are disabled', async () => {
    const group = insertGroup();
    group.fetchToken = vi.fn(() => Promise.resolve('abc123'));

    wrapper = mount(GroupShareableLinkForm, {
      props: { group },
      global: {
        plugins: [createVuetify(), I18n],
        stubs: { DismissModalButton: true, HelpBtn: true, CommonIcon: true, space: { template: ' ' } }
      }
    });
    await flushPromises();
    expect(wrapper.text()).toContain('Copy the invite link and send it by email or chat to invite people to your group');
    expect(wrapper.text()).not.toContain('Anyone with this link can join your group immediately');
    expect(wrapper.text()).not.toContain('To stop people from joining with this link');
    expect(wrapper.find('.shareable-link-modal__members').text()).toBe('2 of 10 members');
    expect(wrapper.find('.shareable-link-modal__message textarea').element.value).toContain('Trial Group');
    expect(wrapper.find('.shareable-link-modal__message textarea').element.value).toContain('/join/group/abc123');

    group.resetToken = vi.fn(() => {
      group.token = 'xyz789';
      return Promise.resolve('xyz789');
    });
    await wrapper.find('.shareable-link-modal__reset').trigger('click');
    await flushPromises();
    expect(wrapper.vm.confirmReset).toBe(true);
    expect(group.resetToken).not.toHaveBeenCalled();

    await wrapper.vm.resetInvitationLink();
    await flushPromises();
    expect(group.resetToken).toHaveBeenCalledTimes(1);
    expect(wrapper.vm.confirmReset).toBe(false);
    expect(wrapper.find('.shareable-link-modal__message textarea').element.value).toContain('/join/group/xyz789');
    wrapper.unmount();

    group.subscription.allow_email_invitations = true;
    wrapper = mount(GroupShareableLinkForm, {
      props: { group },
      global: {
        plugins: [createVuetify(), I18n],
        stubs: { DismissModalButton: true, HelpBtn: true, CommonIcon: true, space: { template: ' ' } }
      }
    });
    await flushPromises();
    expect(wrapper.text()).not.toContain('Copy the invite link and send it by email or chat to invite people to your group');
    expect(wrapper.text()).toContain('Anyone with this link can join your group immediately');
  });

  it('opens GroupShareableLinkForm from TipService when email invitations are disabled', () => {
    const group = insertGroup();
    const inviteTip = TipService.tips(mocks.user, group, {}).find(t => t.title === 'tips.group.invite_people.title');
    inviteTip.perform();
    expect(mocks.emit).toHaveBeenCalledWith('openModal', { component: 'GroupShareableLinkForm', props: { group } });

    mocks.emit.mockClear();
    group.subscription.allow_email_invitations = true;
    inviteTip.perform();
    expect(mocks.emit).toHaveBeenCalledWith('openModal', { component: 'GroupInvitationForm', props: { group } });
  });

  it('blocks email address chips in RecipientsAutocomplete when email invitations are disabled', async () => {
    const group = insertGroup();
    insertMembership({ id: 1, groupId: group.id });
    const discussion = new DiscussionModel({ id: null, groupId: group.id });

    wrapper = mount(RecipientsAutocomplete, {
      props: { model: discussion, label: 'Invite' },
      global: {
        plugins: [createVuetify(), I18n],
        stubs: { CommonIcon: true, UserAvatar: true, NotificationsCount: true, space: { template: ' ' } }
      }
    });
    await flushPromises();

    wrapper.vm.updateQuery('stranger@example.test ');
    await flushPromises();
    expect(wrapper.vm.recipients).toEqual([]);

    group.subscription.allow_email_invitations = true;
    wrapper.vm.updateQuery('stranger@example.test ');
    await flushPromises();
    expect(wrapper.vm.recipients.map(r => r.id)).toEqual(['stranger@example.test']);
  });
});
