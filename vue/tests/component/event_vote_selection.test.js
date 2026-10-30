import { shallowMount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {
  watchRecords({query}) { query(); }
}}}));

import VoteForm from '@/components/poll/common/vote_form.vue';

describe('attendance selection', () => {
  it.each(['event', 'proposal'])('highlights the selected %s option and clears the previous highlight', async pollType => {
    const options = [
      {id: 1, icon: 'agree', color: '#22B866', optionName: () => 'Going'},
      {id: 2, icon: 'abstain', color: '#F5C401', optionName: () => 'Maybe'},
      {id: 3, icon: 'disagree', color: '#F05252', optionName: () => 'Not going'}
    ];
    const poll = {
      id: 4, pollType, pollOptionIds: [1, 2, 3], choiceCountMin: 1, choiceCountMax: 1,
      config: () => ({has_option_icon: true, has_options: true}), singleChoice: () => true,
      optionsDiffer: () => true, pollOptionsForVoting: () => options, isVotable: () => true
    };
    const wrapper = shallowMount(VoteForm, {
      props: {stance: {poll: () => poll, pollOptionIds: () => [], noneOfTheAbove: false}},
      global: {
        mocks: {$route: {query: {}}}, directives: {t: () => {}, submitOnModEnter: () => {}},
        stubs: {
          VCard: {props: ['color'], template: '<div :data-color="color"><slot /></div>'},
          VListItem: {template: '<div><slot name="prepend" /><slot /></div>'},
          VListItemTitle: {template: '<span><slot /></span>'}
        }
      }
    });

    await wrapper.get('input[aria-label="Going"]').setValue(true);
    expect(wrapper.get('.poll-common-vote-form__button--agree').attributes('data-color')).toBe('#22B866');
    expect(wrapper.find('.poll-common-vote-form__button--brand-selected').exists()).toBe(false);

    await wrapper.get('input[aria-label="Maybe"]').setValue(true);
    expect(wrapper.get('.poll-common-vote-form__button--agree').attributes('data-color')).toBeUndefined();
    expect(wrapper.get('.poll-common-vote-form__button--abstain').attributes('data-color')).toBe('#F5C401');
    expect(wrapper.get('.poll-common-vote-form__button--disagree').attributes('data-color')).toBeUndefined();
  });
});
