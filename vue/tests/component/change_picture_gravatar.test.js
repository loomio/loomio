import { mount, flushPromises } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { createVuetify } from 'vuetify';

const mocks = vi.hoisted(() => ({
  user: vi.fn(), fetch: vi.fn(), saveExperience: vi.fn(), updateProfile: vi.fn(),
  emit: vi.fn(), success: vi.fn()
}));
vi.mock('@/shared/services/session', () => ({default: {user: mocks.user}}));
vi.mock('@/shared/services/records', () => ({default: {users: {
  fetch: mocks.fetch, saveExperience: mocks.saveExperience, updateProfile: mocks.updateProfile
}}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));
vi.mock('@/shared/services/flash', () => ({default: {success: mocks.success}}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));
vi.mock('@/components/common/icon.vue', () => ({default: {template: '<span />'}}));
vi.mock('@/components/common/dismiss_modal_button.vue', () => ({default: {template: '<span />'}}));
import ChangePictureForm from '@/components/profile/change_picture_form.vue';

let wrapper;
let user;
const mountForm = () => (wrapper = mount(ChangePictureForm, {global: {
  plugins: [createVuetify()], mocks: {$t: key => key},
  directives: {t: (element, binding) => { element.textContent = binding.value; }}
}}));

describe('Gravatar profile choice', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    user = {id: 1, email: 'member@example.com', avatarKind: 'initials', avatarInitials: 'MU'};
    mocks.user.mockReturnValue({clone: () => user});
    mocks.fetch.mockResolvedValue({avatar_uploaded: null, provider_picture: null});
    mocks.updateProfile.mockResolvedValue({});
    vi.stubGlobal('ResizeObserver', class {observe() {} unobserve() {} disconnect() {}});
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
  });

  afterEach(() => {
    wrapper?.unmount();
    vi.unstubAllGlobals();
  });

  it('opens without mounting a Gravatar image or changing the picture', async () => {
    mountForm();
    await flushPromises();

    expect(wrapper.findAllComponents({name: 'VImg'}).some(image => /gravatar\.com/.test(image.props('src')))).toBe(false);
    expect(wrapper.find('img[src*="gravatar.com"]').exists()).toBe(false);
    expect(mocks.updateProfile).not.toHaveBeenCalled();
    expect(user.avatarKind).toBe('initials');
  });

  it('enables Gravatar only after selecting Use Gravatar', async () => {
    mountForm();
    await flushPromises();
    const option = wrapper.findAll('.change-picture-form__option').find(item => item.text().includes('change_picture_form.use_gravatar'));

    await option.trigger('click');
    await flushPromises();

    expect(mocks.updateProfile).toHaveBeenCalledWith(expect.objectContaining({avatarKind: 'gravatar'}));
    expect(mocks.emit).toHaveBeenCalledWith('updateProfile');
    expect(mocks.emit).toHaveBeenCalledWith('closeModal');
  });

  it('lets an opted-in user switch back to initials without a Gravatar preview', async () => {
    user.avatarKind = 'gravatar';
    mountForm();
    await flushPromises();
    expect(wrapper.findAllComponents({name: 'VImg'})).toHaveLength(0);
    const option = wrapper.findAll('.change-picture-form__option').find(item => item.text().includes('change_picture_form.use_initials'));

    await option.trigger('click');
    await flushPromises();

    expect(mocks.updateProfile).toHaveBeenCalledWith(expect.objectContaining({avatarKind: 'initials'}));
  });
});
