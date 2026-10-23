import { shallowMount } from '@vue/test-utils';
import { nextTick, reactive } from 'vue';
import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {
  pollOptions: {find: () => null}, users: {find: () => null}
}}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => false}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {watchRecords: () => {}}}}));
vi.mock('vue-i18n', () => ({useI18n: () => ({
  t: (key, args) => args?.pct === undefined ? key : `${key}: ${args.num}/${args.total}, ${args.pct}%`
})}));

import ChartPanel from '@/components/poll/common/chart/panel.vue';
import ChartTable from '@/components/poll/common/chart/table.vue';
import CommonIcon from '@/components/common/icon.vue';

function mountPanel(overrides = {}) {
  const columns = ['votes', 'unweighted_score', 'voter_count', 'score', 'votes_cast_percent', 'voter_percent', 'average'];
  const poll = reactive({
    id: 1, pollType: 'poll', weightedVoting: true, chartType: 'pie', chartColumn: 'score_percent',
    closingAt: '2026-10-30', votersCount: 3, decidedVotersCount: 1, castStancesPct: 80,
    quorumPct: 90, quorumReached: false,
    config: () => ({has_options: true}), showResults: () => true, isClosed: () => false,
    translatedPollType: () => 'Choose', iHaveVoted: () => false,
    singleChoice: () => true,
    resultColumns: ['chart', 'name', ...columns],
    resultHeadingKeys: Object.fromEntries(['name', ...columns].map(column => [column, column])),
    results: [
      {id: 1, name: 'Yes', name_format: 'plain', color: 'green', voter_count: 1,
        unweighted_score: 1, score: 8, score_percent: 100, voter_percent: 80, average: 1},
      {id: -1, name: 'Not voted', name_format: 'plain', color: 'grey', voter_count: 2,
        unweighted_score: 0, score: 0, score_percent: null, voter_percent: 20, average: 0}
    ],
    ...overrides
  });
  const wrapper = shallowMount(ChartPanel, {
    props: {poll},
    global: {
      mocks: {$t: key => key}, directives: {t: () => {}},
      stubs: {
        PollCommonChartTable: false,
        VAlert: {template: '<div><slot /></div>'},
        VTable: {template: '<table><slot /></table>'}
      }
    }
  });
  const participation = () => wrapper.get('p.text-medium-emphasis.my-2').text();
  const select = column => wrapper.findAll('thead button').find(button => button.text() === column).trigger('click');
  return {wrapper, poll, participation, select};
}

describe('chart participation follows the selected results column', () => {
  it.each(['votes', 'unweighted_score', 'voter_count'])('uses people for %s and returns to weight for weighted columns', async column => {
    const {wrapper, participation, select} = mountPanel();
    await nextTick();
    expect(participation()).toBe('poll_common_percent_voted.pct_vote_weight_participation: 1/3, 80%');

    await select(column);
    expect(participation()).toBe('poll_common_percent_voted.pct_participation: 1/3, 33%');
    expect(wrapper.text()).toContain('poll_common_percent_voted.pct_of_eligible_vote_weight_must_participate');
    expect(wrapper.findComponent(CommonIcon).props('name')).toBe('mdiCheckboxBlankOutline');

    await select('score');
    expect(participation()).toBe('poll_common_percent_voted.pct_vote_weight_participation: 1/3, 80%');
  });

  it.each(['votes_cast_percent', 'voter_percent', 'average'])('keeps weight-based participation for %s', async column => {
    const {participation, select} = mountPanel();
    await select('votes');
    await select(column);
    expect(participation()).toBe('poll_common_percent_voted.pct_vote_weight_participation: 1/3, 80%');
  });

  it('resets participation with the chart when the selected column disappears', async () => {
    const {poll, participation, select} = mountPanel();
    await select('unweighted_score');
    poll.resultColumns = poll.resultColumns.filter(column => column !== 'unweighted_score');
    await nextTick();
    expect(participation()).toBe('poll_common_percent_voted.pct_vote_weight_participation: 1/3, 80%');
  });

  it.each([
    {votersCount: 0, decidedVotersCount: 0, castStancesPct: 0, expected: '0/0, 0%'},
    {votersCount: 3, decidedVotersCount: 1, castStancesPct: 0, expected: '1/3, 33%'}
  ])('counts people even when assigned weight or electorate is zero: $expected', async ({expected, ...counts}) => {
    const {participation, select} = mountPanel(counts);
    await select('votes');
    expect(participation()).toBe(`poll_common_percent_voted.pct_participation: ${expected}`);
  });

  it('keeps the server participation value for ordinary unweighted polls', async () => {
    const {participation, select} = mountPanel({weightedVoting: false, castStancesPct: 33});
    await select('score');
    expect(participation()).toBe('poll_common_percent_voted.pct_participation: 1/3, 33%');
  });

  it('does not mount the results table or expose anonymous participation before closing', () => {
    const {wrapper, participation} = mountPanel({
      anonymous: true, weightedVoting: false, hideResults: 'until_closed',
      showResults: () => false, decidedVotersCount: undefined, castStancesPct: undefined
    });
    expect(wrapper.findComponent(ChartTable).exists()).toBe(false);
    expect(participation()).not.toContain('33%');
    expect(participation()).not.toContain('80%');
  });
});
