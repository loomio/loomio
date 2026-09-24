import { shallowMount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({
  default: {pollOptions: {find: () => ({name: 'Yes', meaning: ''})}, users: {find: () => null}}
}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {watchRecords: () => {}}}}));

import ChartTable from '@/components/poll/common/chart/table.vue';

describe('weighted poll results table', () => {
  it('shows the equal and assigned weight scores in the same row', () => {
    const poll = {
      weightedVoting: true,
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['name', 'unweighted_score', 'score'],
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
      'common.option', 'poll_common.equal_weight_score', 'poll_common.weighted_score'
    ]);
    expect(wrapper.findAll('tbody tr')).toHaveLength(1);
    expect(wrapper.findAll('tbody td').slice(-2).map(cell => cell.text())).toEqual(['2', '2.83']);
  });

  it('shows voters and score on proposals without an equal weight score column', () => {
    const poll = {
      weightedVoting: true,
      pollType: 'proposal',
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['name', 'votes', 'score'],
      results: [{id: 1, name: 'Agree', name_format: 'plain', voter_count: 2, score: '2.83'}]
    };

    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {
        mocks: {$t: key => key},
        stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Agree</span>'}}
      }
    });

    expect(wrapper.findAll('thead th').map(cell => cell.text())).toEqual([
      'common.option', 'membership_card.voters', 'poll_common.weighted_score'
    ]);
    expect(wrapper.findAll('tbody td').slice(-2).map(cell => cell.text())).toEqual(['2', '2.83']);
  });
});
