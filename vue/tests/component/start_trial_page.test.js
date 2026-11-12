import { mount, flushPromises } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { VForm } from 'vuetify/components';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({post: vi.fn(), error: vi.fn(), success: vi.fn(), push: vi.fn()}));
vi.mock('@/shared/services/app_config', () => ({default: {
  theme: {}, turnstileSiteKey: null, features: {app: {trial_days: 14}}
}}));
vi.mock('@/shared/services/records', () => ({default: {
  groups: {build: attributes => ({...attributes, beforeSaves: []})},
  remote: {post: mocks.post}
}}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => false}}));
vi.mock('@/shared/services/flash', () => ({default: {error: mocks.error, success: mocks.success}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('vue-router', () => ({useRouter: () => ({push: mocks.push})}));
vi.mock('@/components/auth/turnstile_widget.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/lmo_textarea/lmo_textarea.vue', () => ({default: {template: '<div />'}}));

import StartTrialPage from '@/components/start_trial/page.vue';

describe('trial signup request failures', () => {
  let wrapper;

  beforeEach(() => {
    vi.resetAllMocks();
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
  });

  afterEach(() => {
    wrapper?.unmount();
    vi.unstubAllGlobals();
  });

  async function mountForm() {
    wrapper = mount(StartTrialPage, {
      global: {
        plugins: [createVuetify()],
        stubs: {VMain: {template: '<main><slot /></main>'}},
        mocks: {$t: key => key},
        directives: {t: () => {}}
      }
    });
    await wrapper.find('.start-trial-form__name input').setValue('Alex');
    await wrapper.find('.start-trial-form__email input').setValue('alex@example.com');
    await wrapper.find('.start-trial-form__group-name input').setValue('Council');
  }

  async function submit() {
    await wrapper.find('form').trigger('submit');
    await flushPromises();
  }

  it.each([
    ['a bad request', {status: 400, error: 400}],
    ['a server error', {status: 500}],
    ['a network failure', Object.assign(new TypeError('Failed to fetch'), {networkError: true})]
  ])('keeps the form usable after %s without field errors', async (_label, error) => {
    mocks.post.mockRejectedValueOnce(error).mockResolvedValueOnce({group_path: '/g/council'});
    await mountForm();
    await submit();

    expect(mocks.error).toHaveBeenCalledWith('common.please_try_again');
    await expect(wrapper.findComponent(VForm).vm.validate()).resolves.toMatchObject({valid: true});
    expect(wrapper.find('.trial-started').exists()).toBe(false);
    expect(wrapper.find('.start-trial-form__submit').attributes('disabled')).toBeUndefined();
    expect(wrapper.find('.start-trial-form__email input').element.value).toBe('alex@example.com');

    await submit();
    expect(mocks.post).toHaveBeenCalledTimes(2);
    expect(mocks.post).toHaveBeenLastCalledWith('trials', expect.objectContaining({
      user_name: 'Alex', user_email: 'alex@example.com', group_name: 'Council'
    }));
    expect(wrapper.find('.trial-started').exists()).toBe(true);
    expect(mocks.push).not.toHaveBeenCalled();
  });

  it('shows field errors and clears them when a corrected request succeeds', async () => {
    mocks.post.mockRejectedValueOnce({status: 422, errors: {user_email: ['Email address is already registered']}})
      .mockResolvedValueOnce({group_path: '/g/council'});
    await mountForm();
    await submit();

    expect(wrapper.find('.start-trial-form__email').text()).toContain('Email address is already registered');
    expect(mocks.error).toHaveBeenCalledWith('common.check_for_errors_and_try_again');
    expect(wrapper.find('.trial-started').exists()).toBe(false);

    await wrapper.find('.start-trial-form__email input').setValue('alex-new@example.com');
    await submit();
    expect(mocks.post).toHaveBeenLastCalledWith('trials', expect.objectContaining({user_email: 'alex-new@example.com'}));
    expect(wrapper.find('.trial-started').exists()).toBe(true);
  });
});
