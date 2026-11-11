import { shallowMount, flushPromises } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';
import { reactive } from 'vue';
import { createI18n } from 'vue-i18n';
import { mdiReply, mdiVoteOutline } from '@mdi/js';
import messages from '../../../config/locales/client.en.yml';

vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn(), $on: vi.fn(), $off: vi.fn()}}));
vi.mock('@/shared/services/flash', () => ({default: {success: vi.fn(), serverError: vi.fn()}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({timeZone: 'UTC'})}}));

import CommonForm from '@/components/poll/common/vote_form.vue';
import AllocateForm from '@/components/poll/dot_vote/vote_form.vue';
import ScoreForm from '@/components/poll/score/vote_form.vue';
import RankForm from '@/components/poll/ranked_choice/vote_form.vue';
import StvForm from '@/components/poll/stv/vote_form.vue';
import TimeForm from '@/components/poll/meeting/vote_form.vue';

const forms = {question: CommonForm, dot_vote: AllocateForm, score: ScoreForm, ranked_choice: RankForm, stv: StvForm, meeting: TimeForm};

function mountForm(kind, {votable = true, castAt = null, scoreMaximum = 5, pointsPerVoter = 10} = {}) {
  const options = [1, 2, 3].map(id => ({id, name: `Option ${id}`, color: '#0070E0', optionName: () => `Option ${id}`}));
  const poll = {
    id: 42, pollType: kind, choiceCountMin: kind === 'ranked_choice' ? 3 : 0,
    choiceCountMax: 3, scoreMin: 0, scoreMax: scoreMaximum, pointsPerVoter,
    pollOptionIds: options.map(option => option.id), limitReasonLength: true,
    config: () => ({has_options: kind !== 'question'}), singleChoice: () => false,
    isVotable: () => votable, optionsDiffer: current => current.length !== options.length,
    pollOptionsForVoting: () => kind === 'question' ? [] : options, pollOptions: () => options
  };
  if (kind === 'question') poll.optionsDiffer = current => current.length !== 0;
  const stance = reactive({
    poll: () => poll, pollOptionIds: () => [], scoreFor: () => 0,
    optionScores: {}, noneOfTheAbove: false, reason: '', reasonFormat: 'html', castAt,
    save: vi.fn().mockResolvedValue({})
  });
  const wrapper = shallowMount(forms[kind], {
    props: {stance},
    global: {
      plugins: [createI18n({legacy: false, locale: 'en', messages})],
      renderStubDefaultSlot: true,
      mocks: {$route: {query: {}}},
      directives: {'submit-on-mod-enter': () => {}},
      stubs: {
        submit_button: false,
        score_input: false,
        VListItem: {template: '<div><slot /><slot name="append" /></div>'},
        VForm: {template: '<form><slot /></form>'},
        VTextField: {props: ['modelValue'], emits: ['update:modelValue'], template: '<input type="number" :value="modelValue" @input="$emit(\'update:modelValue\', $event.target.value)" />'},
        VBtn: {name: 'VBtn', props: ['disabled', 'color', 'prependIcon'], template: '<button :disabled="disabled"><slot /></button>'}
      }
    }
  });
  return {wrapper, stance, options, button: () => wrapper.get('.poll-common-vote-form__submit')};
}

describe('vote guidance across voting methods', () => {
  it('allows unused points, blocks an excess, and recovers as allocations change', async () => {
    const {wrapper, button} = mountForm('dot_vote', {pointsPerVoter: 20});
    const fields = wrapper.findAll('.poll-dot-vote-vote-form__score-input');
    expect(button().element.disabled).toBe(false);
    await fields[0].setValue('16');
    expect(button().text()).toBe('Submit vote');
    await fields[1].setValue('6');
    expect(button().text()).toBe('Reduce allocation by 2 points');
    expect(button().element.disabled).toBe(true);
    await fields[1].setValue('5');
    expect(button().text()).toBe('Reduce allocation by 1 point');
    await fields[1].setValue('4');
    expect(button().text()).toBe('Submit vote');
    expect(button().element.disabled).toBe(false);
  });

  it.each(['-1', '0.5', '', 'abc'])('blocks an invalid point value %j', async value => {
    const {wrapper, button} = mountForm('dot_vote', {pointsPerVoter: 20});
    await wrapper.get('.poll-dot-vote-vote-form__score-input').setValue(value);
    expect(button().text()).toBe('Check point allocation');
    expect(button().element.disabled).toBe(true);
  });

  it('submits zero allocations when clearing an existing vote', async () => {
    const {wrapper, stance, button} = mountForm('dot_vote', {castAt: '2026-11-11T00:00:00Z'});
    stance.stanceChoicesAttributes = [{poll_option_id: 1, score: 6}];
    expect(button().text()).toBe('Update vote');
    await wrapper.get('form').trigger('submit');
    await flushPromises();
    expect(stance.save).toHaveBeenCalledOnce();
    expect(stance.stanceChoicesAttributes.map(choice => choice.score)).toEqual([0, 0, 0]);
  });

  it('accepts default zero scores and blocks invalid score entries', async () => {
    const {wrapper, button} = mountForm('score', {scoreMaximum: 20});
    const field = wrapper.get('.poll-score-vote-form__score-input');
    expect(button().element.disabled).toBe(false);
    for (const value of ['21', '-1', '0.5', '']) {
      await field.setValue(value);
      expect(button().text()).toBe('Check scores');
      expect(button().element.disabled).toBe(true);
    }
    await field.setValue('0');
    expect(button().text()).toBe('Submit vote');
    expect(button().element.disabled).toBe(false);
  });

  it('keeps the initial ranking valid without requiring a drag', () => {
    const {button} = mountForm('ranked_choice');
    expect(button().text()).toBe('Submit vote');
    expect(button().element.disabled).toBe(false);
  });

  it.each([5, 10, 11])('shows a direct score input only when the maximum %i exceeds ten', maximum => {
    const {wrapper} = mountForm('score', {scoreMaximum: maximum});
    expect(wrapper.findAll('.poll-score-vote-form__score-input')).toHaveLength(maximum > 10 ? 3 : 0);
  });

  it.each([10, 11])('shows a direct allocation input only when the budget %i exceeds ten', maximum => {
    const {wrapper} = mountForm('dot_vote', {pointsPerVoter: maximum});
    expect(wrapper.findAll('.poll-dot-vote-vote-form__score-input')).toHaveLength(maximum > 10 ? 3 : 0);
  });

  it('requires an STV candidate above the divider and accepts a partial ranking', async () => {
    const {wrapper, options, button} = mountForm('stv');
    expect(button().text()).toBe('Rank at least one candidate');
    expect(button().element.disabled).toBe(true);
    const divider = wrapper.vm.pollOptions.find(option => option.isDivider);
    await wrapper.setData({pollOptions: [options[0], divider, options[1], options[2]]});
    expect(button().text()).toBe('Submit vote');
    expect(button().element.disabled).toBe(false);
    await wrapper.setData({pollOptions: [divider, ...options]});
    expect(button().element.disabled).toBe(true);
  });

  it('allows a time poll response with no available times', () => {
    const {button} = mountForm('meeting');
    expect(button().text()).toBe('Submit vote');
    expect(button().element.disabled).toBe(false);
  });

  it('requires visible response text and uses response wording and icon', async () => {
    const {wrapper, stance, button} = mountForm('question');
    expect(button().text()).toBe('Write your response');
    expect(button().element.disabled).toBe(true);
    expect(wrapper.findComponent({name: 'VBtn'}).props('prependIcon')).toBe(mdiReply);
    const reason = wrapper.findComponent({name: 'stance_reason'});
    reason.vm.$emit('draft-text', 'A response typed into the live editor');
    await wrapper.vm.$nextTick();
    expect(button().text()).toBe('Submit response');
    expect(button().element.disabled).toBe(false);
    expect(stance.reason).toBe('');
    reason.vm.$emit('draft-text', '');
    await wrapper.vm.$nextTick();
    expect(button().text()).toBe('Write your response');
    expect(button().element.disabled).toBe(true);
  });

  it('validates saved response text, length, Markdown, and update wording', async () => {
    const {wrapper, stance, button} = mountForm('question');
    await wrapper.setProps({stance: {...stance, reason: '<p><br></p>'}});
    expect(button().element.disabled).toBe(true);
    await wrapper.setProps({stance: {...stance, reason: '<p>Hello group</p>'}});
    expect(button().text()).toBe('Submit response');
    expect(button().element.disabled).toBe(false);
    await wrapper.setProps({stance: {...stance, reason: 'x'.repeat(501)}});
    expect(button().element.disabled).toBe(true);
    await wrapper.setProps({stance: {...stance, reason: '**Hello group**', reasonFormat: 'md', castAt: '2026-11-11T00:00:00Z'}});
    expect(button().text()).toBe('Update response');
    expect(button().element.disabled).toBe(false);
  });

  it.each(Object.keys(forms))('keeps %s submission disabled when voting is closed', kind => {
    const {button} = mountForm(kind, {votable: false});
    expect(button().element.disabled).toBe(true);
  });

  it.each(['score', 'meeting', 'ranked_choice'])('uses Update vote and a constant icon for %s', kind => {
    const {wrapper, button} = mountForm(kind, {castAt: '2026-11-11T00:00:00Z'});
    expect(button().text()).toBe('Update vote');
    const submit = wrapper.findComponent({name: 'submit_button'}).findComponent({name: 'VBtn'});
    expect(submit.props('prependIcon')).toBe(mdiVoteOutline);
    expect(submit.props('color')).toBe('primary');
  });
});
