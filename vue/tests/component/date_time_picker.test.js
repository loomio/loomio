import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/app_config', () => ({
  default: {timeZone: 'Europe/Berlin'}
}));

vi.mock('@/shared/helpers/format_time', () => ({
  hoursOfDay: () => ['07:00', '08:00'],
  timeFormat: () => 'h:mm a'
}));

vi.mock('@/i18n', () => ({
  I18n: {
    global: {
      t: (key, args) => `${key}:${args.time}`
    }
  }
}));

import DateTimePicker from '@/components/common/date_time_picker.vue';

const mountPicker = () => shallowMount(DateTimePicker, {
  props: {
    modelValue: new Date('2026-08-12T05:00:00.000Z'),
    timeZone: 'Europe/Berlin'
  }
});

describe('DateTimePicker', () => {
  it('reports partial custom times through field validation', async () => {
    const wrapper = mountPicker();

    wrapper.vm.timeStr = '07:';
    await nextTick();

    expect(wrapper.vm.timeHint).toBeNull();
    expect(wrapper.vm.validTime('07:')).toMatch(/^poll_meeting_form\.use_24_hour_format:/);
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('accepts a custom half-hour time in the selected timezone', async () => {
    const wrapper = mountPicker();

    wrapper.vm.timeStr = '07:30';
    await nextTick();

    expect(wrapper.vm.timeHint).toBe('7:30 AM');
    expect(wrapper.vm.validTime('07:30')).toBe(true);
    expect(wrapper.emitted('update:modelValue').at(-1)[0].toISOString()).toBe('2026-08-12T05:30:00.000Z');
  });
});
