import { shallowMount } from '@vue/test-utils';
import { reactive } from 'vue';
import { createI18n } from 'vue-i18n';
import { describe, expect, it } from 'vitest';
import TopicSettingsFields from '@/components/topic/settings_fields.vue';

function mountFields(kind, attributes = {}) {
  const model = reactive({
    allowConcurrentPolls: true,
    allowComments: true,
    allowReactions: true,
    attachmentsAdminOnly: false,
    commentLengthMax: 500,
    ...attributes
  });
  const wrapper = shallowMount(TopicSettingsFields, {
    props: {model, kind},
    global: {plugins: [createI18n({legacy: false, locale: 'en', messages: {en: {}}, missingWarn: false})]}
  });
  return {wrapper, model};
}

describe('shared thread settings fields', () => {
  it('shows discussion settings and preserves hidden poll settings', async () => {
    const {wrapper, model} = mountFields('discussion');
    expect(wrapper.find('.topic-settings__comments').exists()).toBe(false);
    expect(wrapper.find('.topic-settings__reactions').exists()).toBe(false);
    const singlePoll = wrapper.findComponent('.topic-settings__single-poll');
    expect(singlePoll.props('modelValue')).toBe(false);
    singlePoll.vm.$emit('update:modelValue', true);
    await wrapper.vm.$nextTick();
    expect(model).toMatchObject({allowConcurrentPolls: false, allowComments: true, allowReactions: true});
    singlePoll.vm.$emit('update:modelValue', false);
    await wrapper.vm.$nextTick();
    expect(model.allowConcurrentPolls).toBe(true);
    wrapper.unmount();
  });

  it('shows an existing single-poll restriction as checked without changing the saved value', () => {
    const {wrapper, model} = mountFields('discussion', {allowConcurrentPolls: false});
    expect(wrapper.findComponent('.topic-settings__single-poll').props('modelValue')).toBe(true);
    expect(model.allowConcurrentPolls).toBe(false);
    wrapper.unmount();
  });

  it('shows poll settings and changes comments and reactions independently', async () => {
    const {wrapper, model} = mountFields('poll');
    expect(wrapper.find('.topic-settings__single-poll').exists()).toBe(false);
    wrapper.findComponent('.topic-settings__comments').vm.$emit('update:modelValue', false);
    await wrapper.vm.$nextTick();
    expect(model).toMatchObject({allowComments: false, allowReactions: true, allowConcurrentPolls: true});
    wrapper.findComponent('.topic-settings__reactions').vm.$emit('update:modelValue', false);
    await wrapper.vm.$nextTick();
    expect(model).toMatchObject({allowComments: false, allowReactions: false, allowConcurrentPolls: true});
    wrapper.unmount();
  });

  it.each(['discussion', 'poll'])('edits attachments and clears the comment limit for a %s', async kind => {
    const {wrapper, model} = mountFields(kind);
    wrapper.findComponent('.topic-settings__attachments-admin-only').vm.$emit('update:modelValue', true);
    wrapper.findComponent('.topic-settings__comment-length').vm.$emit('update:modelValue', 120);
    await wrapper.vm.$nextTick();
    expect(model.attachmentsAdminOnly).toBe(true);
    expect(model.commentLengthMax).toBe(120);
    wrapper.findComponent('.topic-settings__comment-length').vm.$emit('update:modelValue', null);
    await wrapper.vm.$nextTick();
    expect(model.commentLengthMax).toBeNull();
    expect(model.attachmentsAdminOnly).toBe(true);
    wrapper.unmount();
  });
});
