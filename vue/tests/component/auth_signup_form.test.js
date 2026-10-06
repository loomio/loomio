import { mount } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { afterEach, describe, expect, it, vi } from 'vitest';

vi.hoisted(() => { window.Loomio = {}; });
vi.mock('@/shared/services/app_config', () => ({default: {
  theme: {site_name: 'Loomio'},
  turnstileSiteKey: null,
  features: {app: {create_user: false}},
  pendingIdentity: {}
}}));
vi.mock('@/shared/services/auth_service', () => ({default: {}}));
vi.mock('@/components/auth/turnstile_widget.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/auth/back_button.vue', () => ({default: {template: '<div />'}}));

import SignupForm from '@/components/auth/signup_form.vue';

describe('signup form when account creation is disabled', () => {
  let wrapper;

  afterEach(() => wrapper.unmount());

  it('shows a short title and explains the requirement in the card body', () => {
    wrapper = mount(SignupForm, {
      props: {user: {email: 'new@example.com'}},
      global: {
        plugins: [createVuetify()],
        mocks: {$t: key => key},
        directives: {t: (element, binding) => { element.textContent = binding.value; }}
      }
    });

    expect(wrapper.find('.v-card-title').text()).toBe('auth_form.invitation_required_title');
    expect(wrapper.find('.auth-signup-form__invitation-required').text()).toBe('auth_form.invitation_required');
    expect(wrapper.find('form').exists()).toBe(false);
  });
});
