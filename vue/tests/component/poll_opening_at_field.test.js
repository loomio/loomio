import { mount } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { createVuetify } from 'vuetify';
import { VDateInput, VSelect } from 'vuetify/components';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key, params) => (params ? `${key}:${JSON.stringify(params)}` : key)
  })
}));
vi.mock('@/shared/helpers/format_time', () => ({
  hoursOfDay: () => ['01:00', '10:00', '17:30'],
  timeFormat: () => 'h:mm a'
}));

import OpeningAtField from '@/components/poll/common/opening_at_field.vue';

describe('poll opening date input', () => {
  let wrapper;
  let poll;
  let errorHandler;

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 10, 17, 10, 45));
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    poll = reactive({openingAt: null, errors: {openingAt: []}});
    errorHandler = vi.fn();
  });

  afterEach(() => {
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.useRealTimers();
    vi.unstubAllGlobals();
  });

  function mountField(props = {}) {
    wrapper = mount(OpeningAtField, {
      props: {poll, ...props},
      attachTo: document.body,
      global: {plugins: [createVuetify()], config: {errorHandler}}
    });
  }

  it('shows the opening time hint matching the default field value on a fresh form', async () => {
    mountField();
    await nextTick();

    expect(poll.openingAt).toEqual(new Date(2026, 10, 18, 10, 0));
    expect(wrapper.findComponent(VSelect).props('modelValue')).toBe('10:00');
    expect(wrapper.findComponent(VSelect).props('hint')).toBe('10:00 AM');
    expect(errorHandler).not.toHaveBeenCalled();
  });

  it('updates the opening time hint and distance label when date and hour change', async () => {
    mountField();
    await nextTick();

    wrapper.findComponent(VDateInput).vm.$emit('update:modelValue', new Date(2026, 10, 24, 0, 0));
    await nextTick();
    wrapper.findComponent(VSelect).vm.$emit('update:modelValue', '01:00');
    await nextTick();

    expect(poll.openingAt).toEqual(new Date(2026, 10, 24, 1, 0));
    expect(wrapper.findComponent(VSelect).props('hint')).toBe('1:00 AM');
    expect(wrapper.findComponent(VDateInput).props('hint')).toContain('in 7 days');
    expect(errorHandler).not.toHaveBeenCalled();
  });

  it('preserves openingAt and does not crash when the date picker emits null or an invalid date', async () => {
    mountField();
    await nextTick();
    const original = poll.openingAt;

    wrapper.findComponent(VDateInput).vm.$emit('update:modelValue', null);
    await nextTick();
    wrapper.findComponent(VDateInput).vm.$emit('update:modelValue', new Date(NaN));
    await nextTick();

    expect(poll.openingAt).toBe(original);
    expect(errorHandler).not.toHaveBeenCalled();
  });

  it('does not overwrite openingAt when disabled', async () => {
    const existing = new Date(2026, 10, 16, 9, 0);
    poll.openingAt = existing;
    mountField({disabled: true});
    await nextTick();

    expect(poll.openingAt).toBe(existing);
    expect(wrapper.findComponent(VSelect).props('hint')).toBe('9:00 AM');
    expect(errorHandler).not.toHaveBeenCalled();
  });
});
