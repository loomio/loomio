import { shallowMount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';
import { reactive, nextTick } from 'vue';

vi.mock('@/shared/services/records', () => ({
  default: {pollOptions: {find: () => ({name: 'Yes', meaning: ''})}, users: {find: () => null}}
}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {watchRecords: () => {}}}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import ChartTable from '@/components/poll/common/chart/table.vue';

describe('weighted poll results table', () => {
  it('shows points and weighted points in the same row', () => {
    const poll = {
      voteWeightsEnabled: true,
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['name', 'unweighted_score', 'score'],
      resultHeadingKeys: {name: 'common.option', unweighted_score: 'poll_ranked_choice_form.points', score: 'poll_common.weighted_points'},
      results: [{id: 1, name: 'Yes', name_format: 'plain', unweighted_score: 2, score: '2.83'}]
    };

    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {
        mocks: {$t: key => key},
        stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Yes</span>'}}
      }
    });

    expect(wrapper.findAll('thead th').map(cell => cell.text())).toEqual([
      'common.option', 'poll_ranked_choice_form.points', 'poll_common.weighted_points'
    ]);
    expect(wrapper.findAll('tbody tr')).toHaveLength(1);
    expect(wrapper.findAll('tbody td').slice(-2).map(cell => cell.text())).toEqual(['2', '2.83']);
  });

  it('shows votes and weighted votes on weighted proposals', () => {
    const poll = {
      voteWeightsEnabled: true,
      pollType: 'proposal',
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['name', 'votes', 'score', 'votes_cast_percent', 'voter_percent'],
      resultHeadingKeys: {
        name: 'common.option', votes: 'poll_common.votes', score: 'poll_common.weighted_votes',
        votes_cast_percent: 'poll_common.pct_of_weighted_votes', voter_percent: 'poll_ranked_choice_form.pct_of_voters'
      },
      results: [{id: 1, name: 'Agree', name_format: 'plain', voter_count: 2, score: '2.83', score_percent: 75, voter_percent: 50}]
    };

    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {
        mocks: {$t: key => key},
        stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Agree</span>'}}
      }
    });

    expect(wrapper.findAll('thead th').map(cell => cell.text())).toEqual([
      'common.option', 'poll_common.votes', 'poll_common.weighted_votes',
      'poll_common.pct_of_weighted_votes', 'poll_ranked_choice_form.pct_of_voters'
    ]);
    expect(wrapper.findAll('tbody td').slice(1).map(cell => cell.text())).toEqual(['2', '2.83', '75%', '50%']);
  });

  it('switches a proposal pie from weighted score to voter share when its header is clicked', async () => {
    const poll = {
      voteWeightsEnabled: true,
      closedAt: false,
      chartType: 'pie',
      chartColumn: 'score_percent',
      singleChoice: () => true,
      resultColumns: ['chart', 'name', 'votes', 'score', 'votes_cast_percent', 'voter_percent'],
      resultHeadingKeys: {
        name: 'common.option', votes: 'poll_common.votes', score: 'poll_common.weighted_votes',
        votes_cast_percent: 'poll_common.pct_of_weighted_votes', voter_percent: 'poll_ranked_choice_form.pct_of_voters'
      },
      results: [
        {id: 1, name: 'Agree', name_format: 'plain', color: 'green', voter_count: 2, score: '1', score_percent: 25, voter_percent: 66.67},
        {id: 2, name: 'Disagree', name_format: 'plain', color: 'red', voter_count: 1, score: '3', score_percent: 75, voter_percent: 33.33}
      ]
    };
    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {
        mocks: {$t: key => key},
        stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Option</span>'}}
      }
    });

    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([25, 75]);
    const voterHeader = wrapper.findAll('thead button').find(button => button.text() === 'poll_common.votes');
    await voterHeader.trigger('click');
    expect(voterHeader.attributes('aria-pressed')).toBe('true');
    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([66.67, 33.33]);
    expect(wrapper.findAll('tbody tr').map(row => row.text())).toEqual([
      expect.stringContaining('2'), expect.stringContaining('1')
    ]);
  });

  it('switches bars from weighted score to eligible voter share', async () => {
    const poll = {
      voteWeightsEnabled: true,
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'max_score_percent',
      resultColumns: ['chart', 'name', 'score', 'voter_count'],
      resultHeadingKeys: {name: 'common.option', score: 'poll_common.weighted_points', voter_count: 'membership_card.voters'},
      results: [
        {id: 1, name: 'Alpha', name_format: 'plain', score: '2', voter_count: 3, voter_percent: 75},
        {id: 2, name: 'Beta', name_format: 'plain', score: '4', voter_count: 1, voter_percent: 25}
      ]
    };
    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {
        mocks: {$t: key => key},
        stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Option</span>'}}
      }
    });

    expect(wrapper.findAll('tbody .bg-info').map(bar => bar.attributes('style'))).toEqual([
      'width: 50%; height: 24px;', 'width: 100%; height: 24px;'
    ]);
    const voterHeader = wrapper.findAll('thead button').find(button => button.text() === 'membership_card.voters');
    await voterHeader.trigger('click');
    expect(wrapper.findAll('tbody .bg-info').map(bar => bar.attributes('style'))).toEqual([
      'width: 75%; height: 24px;', 'width: 25%; height: 24px;'
    ]);
  });

  it('keeps the existing pie until a displayed measure is selected', async () => {
    const poll = {
      voteWeightsEnabled: false,
      closedAt: false,
      chartType: 'pie',
      chartColumn: 'score_percent',
      singleChoice: () => true,
      pieSlices: () => [{color: 'green', value: 100}],
      resultColumns: ['chart', 'name', 'voter_percent', 'voter_count'],
      resultHeadingKeys: {name: 'common.option', voter_percent: 'poll_ranked_choice_form.pct_of_voters', voter_count: 'membership_card.voters'},
      results: [
        {id: 1, name: 'Agree', name_format: 'plain', color: 'green', voter_count: 1, voter_percent: 50},
        {id: -1, name: 'Undecided', name_format: 'plain', color: 'grey', voter_count: 1, voter_percent: 50}
      ]
    };
    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {
        mocks: {$t: key => key},
        stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Option</span>'}}
      }
    });

    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([100]);
    await wrapper.findAll('thead button').find(button => button.text() === 'membership_card.voters').trigger('click');
    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([50, 50]);
  });

  it('returns to the default measure when its column disappears', async () => {
    const poll = reactive({
      voteWeightsEnabled: true, closedAt: false, chartType: 'bar', chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['chart', 'name', 'score_percent', 'unweighted_score', 'score', 'voter_count'],
      resultHeadingKeys: {name: 'common.option', score_percent: 'p', unweighted_score: 'u', score: 's', voter_count: 'v'},
      results: [{id: 1, name: 'Alpha', name_format: 'plain', score_percent: 100, unweighted_score: 1, score: '1', voter_count: 1, voter_percent: 100}]
    });
    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {mocks: {$t: key => key}, stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Option</span>'}}}
    });

    await wrapper.findAll('thead button').find(button => button.text() === 'u').trigger('click');
    expect(wrapper.vm.selectedMetric).toBe('unweighted_score');

    poll.resultColumns = ['chart', 'name', 'score_percent', 'score', 'voter_count'];
    await nextTick();

    expect(wrapper.vm.selectedMetric).toBe('score_percent');
  });
});
