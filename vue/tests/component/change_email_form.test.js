import { flushPromises, mount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  requestEmailChange: vi.fn(),
  event: vi.fn(),
  flash: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({
  default: {users: {requestEmailChange: mocks.requestEmailChange}}
}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.event}}));
vi.mock('@/shared/services/flash', () => ({default: {success: mocks.flash}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import ChangeEmailForm from '@/components/profile/change_email_form.vue';

const stubs = {
  VCard: {template: '<div><slot /></div>'},
  VCardText: {template: '<div><slot /></div>'},
  VCardActions: {template: '<div><slot /></div>'},
  VTextField: {
    props: ['modelValue'],
    emits: ['update:modelValue'],
    template: '<input :value="modelValue" @input="$emit(\'update:modelValue\', $event.target.value)" />'
  },
  VBtn: {template: '<button><slot /></button>'},
  VAlert: {template: '<div><slot /></div>'},
  VSpacer: true,
  'dismiss-modal-button': {template: '<span />'}
};

describe('change email form', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('requests confirmation and closes after the server accepts the new address', async () => {
    const close = vi.fn();
    mocks.requestEmailChange.mockResolvedValue({});
    const wrapper = mount(ChangeEmailForm, {props: {close}, global: {stubs, mocks: {$t: key => key}}});

    await wrapper.find('input').setValue('new@example.com');
    await wrapper.find('.change-email-form__submit').trigger('click');
    await flushPromises();

    expect(mocks.requestEmailChange).toHaveBeenCalledWith('new@example.com');
    expect(mocks.flash).toHaveBeenCalledWith('profile_page.email_confirmation_sent');
    expect(mocks.event).toHaveBeenCalledWith('updateProfile');
    expect(close).toHaveBeenCalledOnce();
  });

  it('shows a server validation error without closing', async () => {
    const close = vi.fn();
    mocks.requestEmailChange.mockRejectedValue({errors: {email_change_pending: ['Address is already in use']}});
    const wrapper = mount(ChangeEmailForm, {props: {close}, global: {stubs, mocks: {$t: key => key}}});

    await wrapper.find('input').setValue('taken@example.com');
    await wrapper.find('.change-email-form__submit').trigger('click');
    await flushPromises();

    expect(wrapper.text()).toContain('Address is already in use');
    expect(close).not.toHaveBeenCalled();
  });
});
