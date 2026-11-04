import { mount, flushPromises } from '@vue/test-utils';
import { reactive, nextTick } from 'vue';
import { createVuetify } from 'vuetify';
import { VDateInput, VSelect } from 'vuetify/components';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/app_config', () => ({default: {timeZone: 'Pacific/Auckland'}}));
vi.mock('@/shared/helpers/format_time', () => ({
  hoursOfDay: () => ['09:30', '10:00', '17:30'],
  exact: vi.fn(),
  timeFormat: () => 'HH:mm'
}));

import ClosingAtField from '@/components/poll/common/closing_at_field.vue';

describe('poll closing date input', () => {
  let wrapper;
  let poll;
  let errorHandler;

  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    poll = reactive({closingAt: new Date(2026, 9, 8, 9, 30), errors: {closingAt: []}});
    errorHandler = vi.fn();
  });

  afterEach(() => {
    wrapper?.unmount();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  function mountField() {
    wrapper = mount(ClosingAtField, {
      props: {poll},
      attachTo: document.body,
      global: {plugins: [createVuetify()], mocks: {$t: key => key}, config: {errorHandler}}
    });
  }

  it('does not crash or replace the deadline when the date is cleared and blurred', async () => {
    const original = poll.closingAt;
    mountField();

    const input = wrapper.find('.v-date-input input');
    await input.setValue('');
    await input.trigger('blur');
    await flushPromises();

    expect(wrapper.findComponent(VDateInput).props('modelValue')).toBe(null);
    expect(errorHandler).not.toHaveBeenCalled();
    expect(poll.closingAt).toBe(original);
  });

  it('does not replace the deadline while a typed date is incomplete', async () => {
    const original = poll.closingAt;
    mountField();

    const input = wrapper.find('.v-date-input input');
    await input.setValue('2026-10-');
    await input.trigger('blur');
    await flushPromises();

    expect(errorHandler).not.toHaveBeenCalled();
    expect(poll.closingAt).toBe(original);
  });

  it('ignores an invalid date emitted by the picker', async () => {
    const original = poll.closingAt;
    mountField();
    wrapper.findComponent(VDateInput).vm.$emit('update:modelValue', new Date(NaN));
    await nextTick();

    expect(errorHandler).not.toHaveBeenCalled();
    expect(poll.closingAt).toBe(original);
  });

  it('applies the selected time once a cleared date is replaced', async () => {
    const original = poll.closingAt;
    mountField();
    const picker = wrapper.findComponent(VDateInput);
    picker.vm.$emit('update:modelValue', null);
    await nextTick();
    wrapper.findComponent(VSelect).vm.$emit('update:modelValue', '17:30');
    await nextTick();
    expect(poll.closingAt).toBe(original);

    picker.vm.$emit('update:modelValue', new Date(2026, 9, 10));
    await nextTick();

    expect(errorHandler).not.toHaveBeenCalled();
    expect(poll.closingAt).toEqual(new Date(2026, 9, 10, 17, 30));
  });

  it('keeps the selected day when changing the closing time', async () => {
    mountField();
    wrapper.findComponent(VSelect).vm.$emit('update:modelValue', '10:00');
    await nextTick();

    expect(errorHandler).not.toHaveBeenCalled();
    expect(poll.closingAt).toEqual(new Date(2026, 9, 8, 10));
  });

  it('uses the scheduled opening day as the minimum closing date', () => {
    const openingAt = new Date(2026, 9, 7, 17, 30);
    wrapper = mount(ClosingAtField, {
      props: {poll, minDate: openingAt},
      global: {plugins: [createVuetify()], mocks: {$t: key => key}, config: {errorHandler}}
    });

    expect(wrapper.findComponent(VDateInput).props('min')).toEqual(new Date(2026, 9, 7));
    expect(errorHandler).not.toHaveBeenCalled();
  });
});
