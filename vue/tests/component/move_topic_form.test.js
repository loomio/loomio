import { flushPromises, shallowMount } from '@vue/test-utils';
import { reactive } from 'vue';
import { createI18n } from 'vue-i18n';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import enData from '@/../../config/locales/client.en.yml';

const mocks = vi.hoisted(() => ({
  preview: vi.fn(), move: vi.fn(), push: vi.fn(), emit: vi.fn(),
  success: vi.fn(), serverError: vi.fn(), hardReload: vi.fn(), topic: null,
  groups: [
    {id: 2, name: 'Council', fullName: 'Parent - Council', privacyIsOpen: () => false},
    {id: 3, name: 'Other', fullName: 'Other', privacyIsOpen: () => false}
  ]
}));
vi.mock('vue-router', () => ({useRouter: () => ({push: mocks.push})}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({groups: () => mocks.groups})}}));
vi.mock('@/shared/services/records', () => ({default: {
  topics: {remote: {getMember: mocks.preview, patchMember: mocks.move}, find: () => mocks.topic},
  groups: {find: id => mocks.groups.find(group => group.id === id)}
}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));
vi.mock('@/shared/services/flash', () => ({default: {success: mocks.success, serverError: mocks.serverError}}));
vi.mock('@/shared/services/lmo_url_service', () => ({default: {route: () => '/d/thread'}}));
vi.mock('@/shared/helpers/window', () => ({hardReload: mocks.hardReload}));

import MoveTopicForm from '@/components/topic/move_topic_form.vue';

let wrapper;
function mountForm() {
  mocks.topic = reactive({
    id: 10, groupId: 1, private: true, hasAnonymousPolls: false,
    update(attributes) { Object.assign(this, attributes); },
    topicable: () => ({update: vi.fn()})
  });
  wrapper = shallowMount(MoveTopicForm, {
    props: {topic: mocks.topic},
    global: {
      renderStubDefaultSlot: true,
      plugins: [createI18n({legacy: false, locale: 'en', messages: {en: enData.en}})],
      stubs: {DismissModalButton: true}
    }
  });
  return wrapper;
}
async function chooseDestination(id) {
  wrapper.findComponent('.move-topic-form__group-dropdown').vm.$emit('update:modelValue', id);
  await flushPromises();
}
const submitButton = () => wrapper.findComponent('.move-topic-form__submit');
const retainCheckbox = () => wrapper.findComponent('.move-topic-form__retain-members');
async function submit() {
  submitButton().vm.$emit('click');
  await flushPromises();
}

describe('moving a thread with guest retention', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.preview.mockResolvedValue({members_losing_access_count: 7, can_retain_members_as_guests: true});
    mocks.move.mockResolvedValue({});
  });
  afterEach(() => wrapper?.unmount());

  it('shows the participation loss and moves without retaining people unless selected', async () => {
    mountForm();
    expect(submitButton().props('disabled')).toBe(true);
    await chooseDestination(2);
    expect(mocks.preview).toHaveBeenCalledWith(10, 'move_access', {group_id: 2});
    expect(wrapper.find('.move-topic-form__access-warning').text()).toContain('7');
    expect(retainCheckbox().props('modelValue')).toBe(false);
    expect(submitButton().props('disabled')).toBe(false);
    await submit();
    expect(mocks.move).toHaveBeenCalledWith(10, 'move', {group_id: 2, retain_members_as_guests: false});
    expect(mocks.emit).toHaveBeenCalledWith('closeModal');
    expect(mocks.push).toHaveBeenCalledWith('/d/thread');
  });

  it('sends the selected retention choice and resets it for another destination', async () => {
    mountForm();
    await chooseDestination(2);
    retainCheckbox().vm.$emit('update:modelValue', true);
    await flushPromises();
    await chooseDestination(3);
    expect(retainCheckbox().props('modelValue')).toBe(false);
    retainCheckbox().vm.$emit('update:modelValue', true);
    await flushPromises();
    await submit();
    expect(mocks.move).toHaveBeenCalledWith(10, 'move', {group_id: 3, retain_members_as_guests: true});
  });

  it('does not offer guest retention without destination permission', async () => {
    mocks.preview.mockResolvedValue({members_losing_access_count: 7, can_retain_members_as_guests: false});
    mountForm();
    await chooseDestination(2);
    expect(retainCheckbox().exists()).toBe(false);
    expect(wrapper.find('.move-topic-form__access-warning').text()).toContain('Guest access cannot be granted');
    expect(submitButton().props('disabled')).toBe(false);
  });

  it('does not warn when everyone retains participation access', async () => {
    mocks.preview.mockResolvedValue({members_losing_access_count: 0, can_retain_members_as_guests: true});
    mountForm();
    await chooseDestination(2);
    expect(wrapper.find('.move-topic-form__access-warning').exists()).toBe(false);
    expect(submitButton().props('disabled')).toBe(false);
  });

  it('waits for the selected destination and ignores older preview responses', async () => {
    let resolveFirst;
    let resolveSecond;
    mocks.preview.mockImplementationOnce(() => new Promise(resolve => { resolveFirst = resolve; }))
      .mockImplementationOnce(() => new Promise(resolve => { resolveSecond = resolve; }));
    mountForm();
    await chooseDestination(2);
    expect(submitButton().props('disabled')).toBe(true);
    await chooseDestination(3);
    resolveFirst({members_losing_access_count: 99, can_retain_members_as_guests: true});
    await flushPromises();
    expect(submitButton().props('disabled')).toBe(true);
    expect(wrapper.find('.move-topic-form__access-warning').exists()).toBe(false);
    resolveSecond({members_losing_access_count: 3, can_retain_members_as_guests: true});
    await flushPromises();
    expect(wrapper.find('.move-topic-form__access-warning').text()).toContain('3');
    expect(wrapper.find('.move-topic-form__access-warning').text()).not.toContain('99');
    expect(submitButton().props('disabled')).toBe(false);
  });

  it('blocks submission after a preview failure and lets the mover retry', async () => {
    mocks.preview.mockRejectedValueOnce(new Error('offline'));
    mountForm();
    await chooseDestination(2);
    expect(wrapper.find('.move-topic-form__access-error').exists()).toBe(true);
    expect(submitButton().props('disabled')).toBe(true);
    wrapper.findComponent('.move-topic-form__retry').vm.$emit('click');
    await flushPromises();
    expect(mocks.preview).toHaveBeenLastCalledWith(10, 'move_access', {group_id: 2});
    expect(wrapper.find('.move-topic-form__access-error').exists()).toBe(false);
    expect(submitButton().props('disabled')).toBe(false);
  });

  it('previews direct conversion and keeps contributors by default', async () => {
    mountForm();
    await chooseDestination('direct');
    expect(mocks.preview).toHaveBeenCalledWith(10, 'move_access', {make_direct: true});
    expect(wrapper.find('.move-topic-form__access-warning').text()).toContain('7');
    expect(retainCheckbox().props('modelValue')).toBe(false);
    expect(submitButton().props('disabled')).toBe(false);
    await submit();
    expect(mocks.move).toHaveBeenCalledWith(10, 'move', {group_id: null, make_direct: true, retain_members_as_guests: false});
    expect(mocks.hardReload).toHaveBeenCalledWith('/d/thread');
  });

  it('lets a direct conversion keep the other current members and guests', async () => {
    mountForm();
    await chooseDestination('direct');
    retainCheckbox().vm.$emit('update:modelValue', true);
    await flushPromises();
    await submit();
    expect(mocks.move).toHaveBeenCalledWith(10, 'move', {group_id: null, make_direct: true, retain_members_as_guests: true});
  });

  it('does not offer direct conversion for anonymous polls or an already direct thread', async () => {
    mountForm();
    mocks.topic.hasAnonymousPolls = true;
    await chooseDestination('direct');
    expect(mocks.preview).not.toHaveBeenCalled();
    expect(submitButton().props('disabled')).toBe(true);
    mocks.topic.hasAnonymousPolls = false;
    mocks.topic.groupId = null;
    await wrapper.vm.$nextTick();
    expect(submitButton().props('disabled')).toBe(true);
    expect(wrapper.findComponent('.move-topic-form__group-dropdown').props('items')[0].props.disabled).toBe(true);
  });

  it('ignores a group preview that finishes after switching to direct conversion', async () => {
    let resolveGroup;
    mocks.preview.mockImplementationOnce(() => new Promise(resolve => { resolveGroup = resolve; }));
    mountForm();
    await chooseDestination(2);
    await chooseDestination('direct');
    expect(retainCheckbox().props('modelValue')).toBe(false);
    resolveGroup({members_losing_access_count: 99, can_retain_members_as_guests: false});
    await flushPromises();
    expect(wrapper.find('.move-topic-form__access-warning').text()).not.toContain('99');
    expect(retainCheckbox().exists()).toBe(true);
  });

  it('leaves the dialog open when the server rejects a move', async () => {
    const error = new Error('permission changed');
    mocks.move.mockRejectedValueOnce(error);
    mountForm();
    await chooseDestination(2);
    await submit();
    expect(mocks.serverError).toHaveBeenCalledWith(error);
    expect(mocks.emit).not.toHaveBeenCalled();
    expect(submitButton().props('loading')).toBe(false);
  });
});
