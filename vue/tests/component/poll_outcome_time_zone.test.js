import { shallowMount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';
import { enUS } from 'date-fns/locale';

const user = vi.hoisted(() => ({timeZone: 'America/Vancouver', dateTimePref: 'iso'}));

vi.mock('@/shared/services/app_config', () => ({default: {timeZone: 'America/Los_Angeles'}}));
vi.mock('@/shared/services/session', () => ({default: {
  user: () => user
}}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/shared/services/event_bus', () => ({default: {}}));
vi.mock('@/shared/services/ability_service', () => ({default: {}}));
vi.mock('@/components/common/recipients_autocomplete', () => ({default: {render: () => null}}));
vi.mock('@/i18n', () => ({
  I18n: {global: {t: key => key}},
  dateLocale: enUS
}));

import OutcomeModal from '@/components/poll/common/outcome_modal.vue';
import MeetingTime from '@/components/poll/meeting/time.vue';

describe('time poll outcome options', () => {
  it.each(['America/Vancouver', 'America/Whitehorse'])('matches the voting display in %s across the autumn clock change', timeZone => {
    user.timeZone = timeZone;
    const names = ['2026-10-31T19:00:00.000Z', '2026-11-02T19:00:00.000Z'];
    const options = names.map((name, index) => ({id: index + 1, name, stances: () => []}));
    const poll = {datesAsOptions: () => true, pollOptions: () => options, title: 'Meeting'};
    const outcome = {poll: () => poll};
    const wrapper = shallowMount({...OutcomeModal, render: () => null}, {props: {outcome}});

    expect(wrapper.vm.options.map(option => option.value)).toEqual([
      'common.none', '2026-10-31 12:00', '2026-11-02 12:00'
    ]);
    names.forEach((name, index) => {
      const time = shallowMount(MeetingTime, {props: {name}});
      expect(wrapper.vm.options[index + 1].value).toBe(time.text());
      time.unmount();
    });
    expect(options.map(option => option.name)).toEqual(names);
    wrapper.unmount();
  });
});
