import { flushPromises, shallowMount } from '@vue/test-utils';
import { reactive } from 'vue';
import { describe, expect, it, vi } from 'vitest';

vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key, locale: {value: 'en'}})}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({timeZone: 'Pacific/Auckland'})}}));
vi.mock('@/shared/services/records', () => ({default: {fetch: () => Promise.resolve([])}}));

import EventFields from '@/components/poll/event/fields.vue';

function mountFields(overrides = {}) {
  const poll = reactive({
    eventStartsAt: new Date('2026-09-26T22:00:00Z'), eventEndsAt: new Date('2026-09-26T23:00:00Z'),
    eventAllDay: false, eventLocation: '', timeZone: 'Pacific/Auckland', errors: {},
    closingAt: new Date('2026-09-26T22:00:00Z'), isNew: () => true, ...overrides
  });
  const wrapper = shallowMount(EventFields, {props: {poll}});
  return {poll, wrapper};
}

describe('event schedule fields', () => {
  it('shows the schedule in the event timezone and stores edited times as instants', async () => {
    const {poll, wrapper} = mountFields();
    const fields = wrapper.findAllComponents({name: 'VTextField'});
    expect(fields[0].props('modelValue')).toBe('2026-09-27T11:00');
    fields[0].vm.$emit('update:modelValue', '2026-09-28T14:00');
    await flushPromises();
    expect(poll.eventStartsAt.toISOString()).toBe('2026-09-28T01:00:00.000Z');
    expect(poll.eventEndsAt > poll.eventStartsAt).toBe(true);
    expect(poll.closingAt).toEqual(poll.eventStartsAt);
    wrapper.unmount();
  });

  it('uses calendar days for an all-day event across a daylight-saving transition', async () => {
    const {poll, wrapper} = mountFields();
    wrapper.findComponent({name: 'VCheckbox'}).vm.$emit('update:modelValue', true);
    await flushPromises();
    expect(poll.eventStartsAt.toISOString()).toBe('2026-09-26T12:00:00.000Z');
    expect(poll.eventEndsAt.toISOString()).toBe('2026-09-27T11:00:00.000Z');
    const fields = wrapper.findAllComponents({name: 'VTextField'});
    expect(fields[0].props('modelValue')).toBe('2026-09-27');
    expect(fields[1].props('modelValue')).toBe('2026-09-27');
    wrapper.unmount();
  });

  it('keeps all-day dates when the event timezone changes', async () => {
    const {poll, wrapper} = mountFields({eventAllDay: true,
      eventStartsAt: new Date('2026-09-26T12:00:00Z'), eventEndsAt: new Date('2026-09-27T11:00:00Z')});
    wrapper.findComponent({name: 'VAutocomplete'}).vm.$emit('update:modelValue', 'UTC');
    await flushPromises();
    expect(poll.eventStartsAt.toISOString()).toBe('2026-09-27T00:00:00.000Z');
    expect(poll.eventEndsAt.toISOString()).toBe('2026-09-28T00:00:00.000Z');
    expect(poll.closingAt).toEqual(poll.eventStartsAt);
    wrapper.unmount();
  });
});
