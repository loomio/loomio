import { mount, flushPromises } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { createRouter, createMemoryHistory } from 'vue-router';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Database from '@/shared/record_store/db';

const mocks = vi.hoisted(() => ({
  subscriptions: true,
  emit: vi.fn(),
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
      return { app: { subscriptions: mocks.subscriptions, loomio_subscriptions: false, training_call_url: 'https://cal.example/training' } };
    },
    theme: { brand_colors: { yellow425: '#ffee55', blue400: '#3366aa', blue50: '#eeeeff', grey100: '#eeeeee' } }
  }
}));
vi.mock('@/shared/services/event_bus', () => ({ default: { $emit: mocks.emit, $on: vi.fn(), $off: vi.fn() } }));
vi.mock('@/shared/services/session', () => ({
  default: {
    user: () => mocks.user,
    get userId() { return mocks.user?.id; },
    isSignedIn: () => true
  }
}));
vi.mock('@/shared/services/records', () => ({
  default: {
    groups: {
      find: query => typeof query === 'object' ? mocks.groups.find(query) : mocks.groups.findOne({ id: query })
    },
    memberships: {
      find: query => mocks.memberships.find(query)
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
import MembershipModel from '@/shared/models/membership_model';
import UserModel from '@/shared/models/user_model';
import GroupCards from '@/components/group/cards.vue';
import PlanBanner from '@/components/group/plan_banner.vue';

describe('GroupCards and PlanBanner', () => {
  let wrapper;
  let router;

  beforeEach(async () => {
    vi.clearAllMocks();
    mocks.subscriptions = true;
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({ matches: false, addEventListener() {}, removeEventListener() {} }));

    router = createRouter({
      history: createMemoryHistory(),
      routes: [{ path: '/:pathMatch(.*)*', component: { template: '<div />' } }]
    });
    await router.push('/g/trial-key');
    await router.isReady();

    const db = new Database();
    mocks.groups = db.addCollection('groups', { indices: ['id', 'parentId'] });
    mocks.memberships = db.addCollection('memberships', { indices: ['id', 'userId', 'groupId'] });
    mocks.users = db.addCollection('users', { indices: ['id'] });

    mocks.user = new UserModel({ id: 1, name: 'Rob', email: 'rob@example.test', emailVerified: true, experiences: {} });
    mocks.users.insert(mocks.user);
  });

  afterEach(() => {
    wrapper?.unmount();
    vi.unstubAllGlobals();
  });

  function setupGroup(overrides = {}) {
    const group = new GroupModel({
      id: 100,
      key: 'trial-key',
      name: 'Trial Group',
      membershipsCount: 2,
      adminMembershipsCount: 1,
      orgMembersCount: 2,
      pollsCount: 5,
      activePollsCount: 2,
      currentUserVotesNeededCount: 1,
      subscription: {
        plan: 'trial',
        state: 'active',
        allow_email_invitations: false,
        allow_subgroups: false,
        allow_guests: false,
        trial_extended_at: null
      },
      ...overrides
    });
    mocks.groups.insert(group);
    mocks.memberships.insert(new MembershipModel({
      id: 1,
      userId: mocks.user.id,
      groupId: group.id,
      admin: true,
      acceptedAt: '2026-11-24T00:00:00Z',
      revokedAt: null
    }));
    return group;
  }

  function mountCards(group) {
    return mount({
      components: { PlanBanner, GroupCards },
      props: ['group'],
      template: '<div><plan-banner :group="group" /><group-cards :group="group" /></div>'
    }, {
      props: { group },
      global: {
        plugins: [createVuetify(), I18n, router],
        stubs: { CommonIcon: true }
      }
    });
  }

  it('shows remaining members countdown, view plans button, and group summary cards', async () => {
    const group = setupGroup({ membershipsCount: 2, pendingMembershipsCount: 0, acceptedMembershipsCount: 2 });
    wrapper = mountCards(group);
    await flushPromises();

    expect(wrapper.find('.plan-banner').text()).toContain('Unlock 30 extra days and a free training call with a Loomio team member when 1 more person joins the group.');
    expect(wrapper.find('.plan-banner__upgrade').attributes('href')).toContain('/upgrade/100');
    expect(wrapper.find('.plan-banner__upgrade').text()).toContain('View plans');
    expect(wrapper.find('.plan-banner__verified-badge').exists()).toBe(false);
    expect(wrapper.find('.plan-banner__verification').exists()).toBe(false);
    expect(wrapper.find('.group-page-members-tab').text()).toContain('Members');
    expect(wrapper.find('.group-page-members-tab').text()).toContain('2 members');
    expect(wrapper.find('.group-page-members-tab').text()).not.toContain('delegate');
    expect(wrapper.find('.group-page-polls-tab').text()).toContain('Polls');
    expect(wrapper.find('.group-page-polls-tab').text()).toContain('0 need vote');
    expect(wrapper.find('.group-page-polls-tab').text()).toContain('2 open');
    expect(wrapper.find('.group-page-files-tab').exists()).toBe(true);

    await wrapper.find('.group-cards__invite').trigger('click');
    expect(mocks.emit).toHaveBeenCalledWith('openModal', { component: 'GroupShareableLinkForm', props: { group } });
  });

  it('shows verified message and opens email invitation form once approved', async () => {
    const group = setupGroup({
      subscription: {
        plan: 'trial',
        state: 'active',
        allow_email_invitations: true,
        trial_extended_at: null
      }
    });
    wrapper = mountCards(group);
    await flushPromises();

    expect(wrapper.find('.plan-banner__verified-badge').text()).toContain('Verified');
    expect(wrapper.find('.plan-banner__verification').text()).toContain("We've seen your group and we're here to help");
    await wrapper.find('.group-cards__invite').trigger('click');
    expect(mocks.emit).toHaveBeenCalledWith('openModal', { component: 'GroupInvitationForm', props: { group } });
  });

  it('shows unlocked state when trial_extended_at is set without a dismiss button', async () => {
    const group = setupGroup({
      subscription: {
        plan: 'trial',
        state: 'active',
        allow_email_invitations: true,
        allow_subgroups: true,
        allow_guests: true,
        trial_extended_at: '2026-11-24T01:00:00Z'
      }
    });
    wrapper = mountCards(group);
    await flushPromises();

    expect(wrapper.find('.plan-banner').text()).toContain('30 extra days & free training call unlocked');
    expect(wrapper.find('.plan-banner__training-call').attributes('href')).toBe('https://cal.example/training');
    expect(wrapper.find('.plan-banner__dismiss').exists()).toBe(false);
  });

  it('hides the active trial banner from non-admin members', async () => {
    const group = setupGroup();
    mocks.memberships.findOne({ id: 1 }).admin = false;
    wrapper = mountCards(group);
    await flushPromises();

    expect(wrapper.find('.plan-banner').exists()).toBe(false);
  });
});
