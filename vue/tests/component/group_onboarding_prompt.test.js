import { mount, flushPromises } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Database from '@/shared/record_store/db';

const mocks = vi.hoisted(() => ({
  post: vi.fn(),
  importREADY: vi.fn(),
  flashSuccess: vi.fn(),
  flashError: vi.fn(),
  groups: null,
  memberships: null,
  users: null,
  user: null
}));

vi.mock('@/shared/services/app_config', () => ({
  default: { defaultLocale: 'en', baseUrl: 'https://loomio.example/', features: { app: { subscriptions: true } }, theme: {} }
}));
vi.mock('@/shared/services/session', () => ({
  default: { user: () => mocks.user, get userId() { return mocks.user?.id; }, isSignedIn: () => true }
}));
vi.mock('@/shared/services/flash', () => ({
  default: { success: mocks.flashSuccess, error: mocks.flashError }
}));
vi.mock('@/shared/services/records', () => ({
  default: {
    groups: { find: query => typeof query === 'object' ? mocks.groups.find(query) : mocks.groups.findOne({ id: query }) },
    memberships: { find: query => mocks.memberships.find(query) },
    remote: { post: mocks.post },
    importREADY: mocks.importREADY
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
import GroupOnboardingPrompt from '@/components/group/onboarding_prompt.vue';

describe('GroupOnboardingPrompt', () => {
  let wrapper;

  beforeEach(() => {
    vi.clearAllMocks();
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

  function setupGroup(overrides = {}, admin = true) {
    const group = new GroupModel({
      id: 100,
      key: 'trial-key',
      name: 'Trial Group',
      discussionsCount: 0,
      onboardingCompleted: false,
      subscription: { plan: 'trial', state: 'active' },
      ...overrides
    });
    mocks.groups.insert(group);
    mocks.memberships.insert(new MembershipModel({
      id: 1,
      userId: mocks.user.id,
      groupId: group.id,
      admin,
      acceptedAt: '2026-11-28T00:00:00Z',
      revokedAt: null
    }));
    return group;
  }

  function mountPrompt(group) {
    return mount(GroupOnboardingPrompt, {
      props: { group },
      global: { plugins: [createVuetify(), I18n] }
    });
  }

  it('shows for a new trial group admin and submits selected answers', async () => {
    mocks.post.mockResolvedValueOnce({ groups: [{ id: 100, onboarding_completed: true }] });
    const group = setupGroup();
    wrapper = mountPrompt(group);

    expect(wrapper.find('.onboarding-prompt').exists()).toBe(true);
    await wrapper.find('.onboarding-prompt__pain--too_many_meetings').trigger('click');
    await wrapper.find('.onboarding-prompt__description textarea').setValue('Coordinating our co-op board');
    await wrapper.find('.onboarding-prompt__intent input').setValue('Approve annual budget');
    await wrapper.find('.onboarding-prompt__save').trigger('click');
    await flushPromises();

    expect(mocks.post).toHaveBeenCalledWith('groups/100/onboarding', {
      pain_points: ['too_many_meetings'],
      description: 'Coordinating our co-op board',
      trial_intent: 'Approve annual budget'
    });
    expect(mocks.flashSuccess).toHaveBeenCalledWith('onboarding_prompt.saved');
    expect(wrapper.find('.onboarding-prompt').exists()).toBe(false);
  });

  it('allows skipping and hides the card', async () => {
    mocks.post.mockResolvedValueOnce({ groups: [{ id: 100, onboarding_completed: true }] });
    const group = setupGroup();
    wrapper = mountPrompt(group);

    await wrapper.find('.onboarding-prompt__skip').trigger('click');
    await flushPromises();

    expect(mocks.post).toHaveBeenCalledWith('groups/100/onboarding', {});
    expect(wrapper.find('.onboarding-prompt').exists()).toBe(false);
  });

  it('hides when already completed, non-admin, or group already has discussions', () => {
    expect(mountPrompt(setupGroup({ id: 101, onboardingCompleted: true })).find('.onboarding-prompt').exists()).toBe(false);
    expect(mountPrompt(setupGroup({ id: 102, discussionsCount: 1 })).find('.onboarding-prompt').exists()).toBe(false);
    expect(mountPrompt(setupGroup({ id: 103 }, false)).find('.onboarding-prompt').exists()).toBe(false);
  });
});
