import { shallowMount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => false}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));
vi.mock('@/components/poll/common/chart/meeting', () => ({default: {template: '<div />'}}));
vi.mock('@/components/poll/common/chart/table', () => ({default: {template: '<div />'}}));
vi.mock('@/components/poll/stv/chart_panel', () => ({default: {template: '<div />'}}));

import OptionForm from '@/components/poll/common/poll_option_form.vue';
import ChartPanel from '@/components/poll/common/chart/panel.vue';
import CommonIcon from '@/components/common/icon.vue';

const global = {
  mocks: {$t: key => key},
  directives: {t: () => {}},
  stubs: {
    VCard: {template: '<div><slot /></div>'},
    VCardText: {template: '<div><slot /></div>'},
    VSelect: {props: ['items'], template: '<div class="choices">{{ items }}</div>'},
    VAlert: {template: '<div><slot /></div>'}
  }
};

describe('weighted poll rules', () => {
  it.each([false, true])('labels both vote-share bases when weighted voting is %s', weightedVoting => {
    const wrapper = shallowMount(OptionForm, {
      global,
      props: {
        poll: {weightedVoting, pollType: 'proposal', config: () => ({allow_vote_share_requirement: true})},
        pollOption: {name: 'Agree'}, submitFn: vi.fn()
      }
    });

    const choices = wrapper.findAll('.choices').at(-1).text();
    expect(choices).toContain(weightedVoting ? 'poll_option_form.vote_weight_cast' : 'poll_option_form.votes_cast');
    expect(choices).toContain(weightedVoting ? 'poll_option_form.eligible_vote_weight' : 'poll_option_form.eligible_voters');
  });

  it('shows weighted quorum, support, and turnout labels and uses the server quorum status', () => {
    const wrapper = shallowMount(ChartPanel, {
      global,
      props: {poll: {
        id: 1, pollType: 'proposal', weightedVoting: true, quorumPct: 60,
        quorumShortfall: 0, quorumReached: false, closingAt: '2026-10-30',
        results: [{name: 'Agree', test_operator: 'gte', test_percent: 60, test_result: false,
          test_requirement_key: 'poll_option_form.name_gte_eligible_vote_weight'}],
        config: () => ({has_options: false}), showResults: () => true, isClosed: () => false
      }}
    });

    expect(wrapper.text()).toContain('poll_common_percent_voted.pct_of_eligible_vote_weight_must_participate');
    expect(wrapper.text()).toContain('poll_option_form.name_gte_eligible_vote_weight');
    expect(wrapper.text()).toContain('poll_common_percent_voted.pct_vote_weight_participation');
    expect(wrapper.findComponent(CommonIcon).props('name')).toBe('mdiCheckboxBlankOutline');
  });
});
