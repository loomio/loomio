import { shallowMount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';
import { mdiVoteOutline } from '@mdi/js';
import { createI18n } from 'vue-i18n';
import messages from '../../../config/locales/client.en.yml';

vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/services/flash', () => ({default: {success: vi.fn(), serverError: vi.fn()}}));

import VoteForm from '@/components/poll/common/vote_form.vue';

function mountForm({minimum = 1, maximum = 2, votable = true, singleChoice = false, castAt = null, selectedOptionIds = []} = {}) {
  const options = [1, 2, 3].map(id => ({id, optionName: () => `Option ${id}`}));
  const poll = {
    id: 42,
    pollType: 'poll',
    pollOptionIds: options.map(option => option.id),
    choiceCountMin: minimum,
    choiceCountMax: maximum,
    config: () => ({has_options: true}),
    singleChoice: () => singleChoice,
    isVotable: () => votable,
    optionsDiffer: current => current.length !== options.length,
    pollOptionsForVoting: () => options
  };
  const stance = {poll: () => poll, pollOptionIds: () => selectedOptionIds, noneOfTheAbove: false, castAt};
  return shallowMount(VoteForm, {
    props: {stance},
    global: {
      plugins: [createI18n({legacy: false, locale: 'en', messages})],
      renderStubDefaultSlot: true,
      mocks: {$route: {query: {}}},
      directives: {'submit-on-mod-enter': () => {}},
      stubs: {submit_button: false, VBtn: {name: 'VBtn', props: ['disabled', 'color', 'prependIcon'], template: '<button :disabled="disabled"><slot /></button>'}}
    }
  });
}

describe('poll vote form selection feedback', () => {
  it('enables submission only within the selection limits and keeps the same ballot icon', async () => {
    const wrapper = mountForm();
    const button = () => wrapper.findComponent({name: 'VBtn'});
    const submit = () => wrapper.get('.poll-common-vote-form__submit');
    const choices = wrapper.findAll('input[type="checkbox"]');

    expect(button().text()).toBe('Select 1 to 2 options');
    expect(button().props('prependIcon')).toBe(mdiVoteOutline);
    expect(button().props('color')).toBe('primary');
    expect(submit().element.disabled).toBe(true);

    await choices[0].setValue(true);
    expect(button().text()).toBe('Submit vote');
    expect(button().props('color')).toBe('primary');
    expect(button().props('prependIcon')).toBe(mdiVoteOutline);
    expect(submit().element.disabled).toBe(false);

    await choices[1].setValue(true);
    expect(button().text()).toBe('Submit vote');

    await choices[2].setValue(true);
    expect(button().text()).toBe('Select 1 to 2 options');
    expect(button().props('prependIcon')).toBe(mdiVoteOutline);
    expect(button().props('color')).toBe('primary');
    expect(submit().element.disabled).toBe(true);

    await choices[2].setValue(false);
    expect(button().text()).toBe('Submit vote');
    expect(button().props('prependIcon')).toBe(mdiVoteOutline);
    expect(submit().element.disabled).toBe(false);

    await choices[0].setValue(false);
    await choices[1].setValue(false);
    expect(button().text()).toBe('Select 1 to 2 options');
    expect(button().props('prependIcon')).toBe(mdiVoteOutline);
    expect(submit().element.disabled).toBe(true);
  });

  it('shows the selection limits below the minimum and accepts exactly the required number', async () => {
    const wrapper = mountForm({minimum: 2, maximum: 2});
    const choices = wrapper.findAll('input[type="checkbox"]');

    await choices[0].setValue(true);
    expect(wrapper.get('.poll-common-vote-form__submit').text()).toBe('Select 2 options');
    expect(wrapper.findComponent({name: 'VBtn'}).props('prependIcon')).toBe(mdiVoteOutline);
    expect(wrapper.get('.poll-common-vote-form__submit').element.disabled).toBe(true);

    await choices[1].setValue(true);
    expect(wrapper.get('.poll-common-vote-form__submit').text()).toBe('Submit vote');
    expect(wrapper.findComponent({name: 'VBtn'}).props('prependIcon')).toBe(mdiVoteOutline);
    expect(wrapper.get('.poll-common-vote-form__submit').element.disabled).toBe(false);
  });

  it('keeps voting disabled when the poll is not votable, even with a valid selection', async () => {
    const wrapper = mountForm({votable: false});
    await wrapper.get('input[type="checkbox"]').setValue(true);

    expect(wrapper.get('.poll-common-vote-form__submit').element.disabled).toBe(true);
  });

  it('shows Update vote when editing an existing valid vote', async () => {
    const wrapper = mountForm({castAt: '2026-11-10T00:00:00Z', selectedOptionIds: [1]});
    const button = wrapper.get('.poll-common-vote-form__submit');
    expect(button.text()).toBe('Update vote');

    await wrapper.get('input[type="checkbox"]').setValue(false);
    expect(button.text()).toBe('Select 1 to 2 options');
    expect(button.element.disabled).toBe(true);
  });

  it('prompts for a single option before enabling submission', async () => {
    const wrapper = mountForm({singleChoice: true, minimum: 1, maximum: 1});

    expect(wrapper.find('.poll-common-vote-form__option-count').exists()).toBe(false);
    expect(wrapper.get('.poll-common-vote-form__submit').text()).toBe('Select an option');
    expect(wrapper.get('.poll-common-vote-form__submit').element.disabled).toBe(true);
    expect(wrapper.findComponent({name: 'VBtn'}).props('prependIcon')).toBe(mdiVoteOutline);
    expect(wrapper.findAll('input[type="radio"]')).toHaveLength(3);
    await wrapper.get('input[type="radio"]').setValue(true);
    expect(wrapper.get('.poll-common-vote-form__submit').text()).toBe('Submit vote');
    expect(wrapper.get('.poll-common-vote-form__submit').element.disabled).toBe(false);
  });
});
