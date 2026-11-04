import { mount, flushPromises } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  supported: true,
  list: vi.fn(),
  create: vi.fn(),
  remove: vi.fn(),
  success: vi.fn(),
  error: vi.fn(),
  emit: vi.fn(),
  on: vi.fn(),
  off: vi.fn()
}));

vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));
vi.mock('@/shared/services/auth_service', () => ({default: {
  passkeysSupported: () => mocks.supported,
  suggestedPasskeyName: () => 'Browser passkey',
  passkeyCredentials: mocks.list,
  createPasskey: mocks.create,
  removePasskey: mocks.remove
}}));
vi.mock('@/shared/services/flash', () => ({default: {success: mocks.success, error: mocks.error}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit, $on: mocks.on, $off: mocks.off}}));
vi.mock('@/shared/helpers/format_time', () => ({approximate: () => 'today'}));

import PasskeySettings from '@/components/profile/passkey_settings.vue';

const credential = {id: 12, name: 'My passkey', created_at: '2026-10-01T00:00:00Z'};
const unauthorized = () => Object.assign(new Error('Sign in required'), {status: 401});

describe('passkey settings', () => {
  let wrapper;
  let errorHandler;

  beforeEach(() => {
    vi.resetAllMocks();
    mocks.supported = true;
    mocks.list.mockResolvedValue({passkey_credentials: [credential]});
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    errorHandler = vi.fn();
  });

  afterEach(() => {
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  function mountSettings() {
    wrapper = mount(PasskeySettings, {
      attachTo: document.body,
      global: {plugins: [createVuetify()], stubs: {CommonIcon: true}, config: {errorHandler}}
    });
  }

  async function signedIn() {
    const callback = mocks.on.mock.calls.find(([event]) => event === 'signedIn')[1];
    await callback();
    await flushPromises();
  }

  it('handles an expired session without offering credential controls', async () => {
    mocks.list.mockRejectedValue(unauthorized());
    mountSettings();
    await flushPromises();

    expect(errorHandler).not.toHaveBeenCalled();
    expect(mocks.emit).toHaveBeenCalledWith('openAuthModal');
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);
    expect(mocks.create).not.toHaveBeenCalled();
    expect(mocks.remove).not.toHaveBeenCalled();
  });

  it('waits for a successful load before showing credentials or the empty state', async () => {
    let resolve;
    mocks.list.mockReturnValue(new Promise(done => { resolve = done; }));
    mountSettings();
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);

    resolve({passkey_credentials: [credential]});
    await flushPromises();
    expect(wrapper.text()).toContain('My passkey');
    expect(wrapper.text()).not.toContain('passkey_settings.none');
  });

  it('reloads credentials after signing in and removes the listener when unmounted', async () => {
    mocks.list.mockRejectedValueOnce(unauthorized());
    mountSettings();
    await flushPromises();
    await signedIn();

    expect(mocks.list).toHaveBeenCalledTimes(2);
    expect(wrapper.text()).toContain('My passkey');
    const callback = mocks.on.mock.calls.find(([event]) => event === 'signedIn')[1];
    wrapper.unmount();
    wrapper = null;
    expect(mocks.off).toHaveBeenCalledWith('signedIn', callback);
  });

  it('discards the previous account credentials while loading a new sign-in', async () => {
    mountSettings();
    await flushPromises();
    let resolve;
    mocks.list.mockReturnValue(new Promise(done => { resolve = done; }));
    const callback = mocks.on.mock.calls.find(([event]) => event === 'signedIn')[1];
    const reload = callback();
    await flushPromises();
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);

    resolve({passkey_credentials: []});
    await reload;
    await flushPromises();

    expect(wrapper.text()).not.toContain('My passkey');
    expect(wrapper.text()).toContain('passkey_settings.none');
  });

  it('does not fetch passkeys on unsupported browsers', async () => {
    mocks.supported = false;
    mountSettings();
    await flushPromises();
    expect(mocks.list).not.toHaveBeenCalled();
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);
  });

  it.each([403, 500, undefined])('keeps unexpected load failures visible to error reporting (status %s)', async status => {
    const error = Object.assign(new Error('Unexpected failure'), {status});
    mocks.list.mockRejectedValue(error);
    mountSettings();
    await flushPromises();

    expect(errorHandler).toHaveBeenCalledWith(error, expect.anything(), expect.anything());
    expect(mocks.emit).not.toHaveBeenCalledWith('openAuthModal');
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);
  });

  it.each(['create', 'remove'])('prompts for sign-in if the session expires during %s', async action => {
    mountSettings();
    await flushPromises();
    mocks[action].mockRejectedValue(unauthorized());
    await wrapper.find(`.passkey-settings__${action === 'create' ? 'add' : 'remove'}`).trigger('click');
    await flushPromises();

    expect(mocks.emit).toHaveBeenCalledWith('openAuthModal');
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);
    expect(mocks.success).not.toHaveBeenCalled();
    expect(errorHandler).not.toHaveBeenCalled();
  });

  it('adds and removes passkeys with a fresh credential list after each operation', async () => {
    mountSettings();
    await flushPromises();
    await wrapper.find('.passkey-settings__name input').setValue('  Laptop  ');
    await wrapper.find('.passkey-settings__add').trigger('click');
    await flushPromises();

    expect(mocks.create).toHaveBeenCalledWith('Laptop');
    expect(mocks.success).toHaveBeenCalledWith('passkey_settings.added');
    mocks.list.mockResolvedValue({passkey_credentials: []});
    await wrapper.find('.passkey-settings__remove').trigger('click');
    await flushPromises();

    expect(mocks.remove).toHaveBeenCalledWith(12);
    expect(mocks.success).toHaveBeenCalledWith('passkey_settings.removed');
    expect(wrapper.text()).toContain('passkey_settings.none');
    expect(mocks.list).toHaveBeenCalledTimes(3);
  });

  it('shows recent-authentication errors without changing or hiding credentials', async () => {
    mountSettings();
    await flushPromises();
    mocks.remove.mockRejectedValue({status: 403, errors: {passkey: ['Please sign in again']}});
    await wrapper.find('.passkey-settings__remove').trigger('click');
    await flushPromises();

    expect(mocks.error).toHaveBeenCalledWith('Please sign in again');
    expect(wrapper.text()).toContain('My passkey');
    expect(mocks.success).not.toHaveBeenCalled();
    expect(mocks.emit).not.toHaveBeenCalledWith('openAuthModal');
  });

  it('does not show success when the credential reload fails after a mutation', async () => {
    mountSettings();
    await flushPromises();
    mocks.list.mockRejectedValue(unauthorized());
    await wrapper.find('.passkey-settings__add').trigger('click');
    await flushPromises();

    expect(mocks.create).toHaveBeenCalledOnce();
    expect(mocks.emit).toHaveBeenCalledWith('openAuthModal');
    expect(mocks.success).not.toHaveBeenCalled();
    expect(wrapper.find('.passkey-settings').exists()).toBe(false);
  });
});
