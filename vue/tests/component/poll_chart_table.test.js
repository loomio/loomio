import { mount, shallowMount } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { describe, expect, it, vi } from 'vitest';
import { reactive, nextTick } from 'vue';

vi.mock('@/shared/services/records', () => ({
  default: {pollOptions: {find: () => ({name: 'Yes', meaning: ''})}, users: {find: () => null, build: () => ({})}}
}));
vi.mock('@/mixins/watch_records', () => ({default: {methods: {watchRecords: () => {}}}}));
vi.mock('@/components/user/avatar', () => ({default: {
  name: 'UserAvatar', props: {user: Object, size: Number, noLink: Boolean},
  template: '<div class="v-avatar test-voter-avatar" :title="user.name">{{ user.name }}</div>'
}}));
vi.mock('vue-i18n', async importOriginal => ({
  ...await importOriginal(),
  useI18n: () => ({t: key => key})
}));

import ChartTable from '@/components/poll/common/chart/table.vue';

describe('weighted poll results table', () => {
  it('shows points and weighted points in the same row', () => {
    const poll = {
      weightedVoting: true,
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

  it('shows remaining vote weight for Not voted but leaves its share of votes cast blank', () => {
    const poll = {
      weightedVoting: true,
      pollType: 'proposal',
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['name', 'votes', 'score', 'voter_percent', 'votes_cast_percent'],
      resultHeadingKeys: {
        name: 'common.option', votes: 'poll_common.votes', score: 'poll_common.weighted_votes',
        votes_cast_percent: 'poll_common.pct_of_vote_weight_cast', voter_percent: 'poll_common.pct_of_eligible_vote_weight'
      },
      results: [
        {id: 1, name: 'Agree', name_format: 'plain', vote_count: 2, score: '2.83', score_percent: 100, voter_percent: 50},
        {id: 2, name: 'Disagree', name_format: 'plain', vote_count: 0, score: 0, score_percent: 0, voter_percent: 0},
        {id: -1, name: 'Not voted', name_format: 'plain', vote_count: 3, score: 2.83, score_percent: null, voter_percent: 50}
      ]
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
      'poll_common.pct_of_eligible_vote_weight', 'poll_common.pct_of_vote_weight_cast'
    ]);
    expect(wrapper.findAll('tbody tr').map(row => row.findAll('td').slice(1).map(cell => cell.text()))).toEqual([
      ['2', '2.83', '50%', '100%'],
      ['0', '0', '0%', '0%'],
      ['3', '2.83', '50%', '']
    ]);
  });

  it('includes Not voted in vote counts and weights, excluding it only from the share of votes cast', async () => {
    const poll = {
      weightedVoting: true,
      closedAt: false,
      chartType: 'pie',
      chartColumn: 'score_percent',
      singleChoice: () => true,
      voteCountTotal: 4,
      resultColumns: ['chart', 'name', 'votes', 'score', 'votes_cast_percent', 'voter_percent'],
      resultHeadingKeys: {
        name: 'common.option', votes: 'poll_common.votes', score: 'poll_common.weighted_votes',
        votes_cast_percent: 'poll_common.pct_of_vote_weight_cast', voter_percent: 'poll_common.pct_of_eligible_vote_weight'
      },
      results: [
        {id: 1, name: 'Agree', name_format: 'plain', color: 'green', vote_count: 2, score: 1, score_percent: 25, voter_percent: 12.5},
        {id: 2, name: 'Disagree', name_format: 'plain', color: 'red', vote_count: 1, score: 3, score_percent: 75, voter_percent: 37.5},
        {id: -1, name: 'Not voted', name_format: 'plain', color: 'grey', vote_count: 1, score: 4, score_percent: null, voter_percent: 50}
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
    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([50, 25, 25]);
    await wrapper.findAll('thead button').find(button => button.text() === 'poll_common.weighted_votes').trigger('click');
    expect(wrapper.vm.slices).toEqual([
      {color: 'green', value: 12.5}, {color: 'red', value: 37.5}, {color: 'grey', value: 50}
    ]);
    const weightHeader = wrapper.findAll('thead button').find(button => button.text() === 'poll_common.pct_of_eligible_vote_weight');
    await weightHeader.trigger('click');
    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([12.5, 37.5, 50]);
    await wrapper.findAll('thead button').find(button => button.text() === 'poll_common.pct_of_vote_weight_cast').trigger('click');
    expect(wrapper.vm.slices.map(slice => slice.value)).toEqual([25, 75]);
    expect(wrapper.vm.slices.map(slice => slice.color)).not.toContain('grey');
    expect(wrapper.find('tbody tr:last-child').findAll('td').slice(1).map(cell => cell.text())).toEqual(['1', '4', '', '50%']);
  });

  it('switches bars from weighted score to eligible voter share', async () => {
    const poll = {
      weightedVoting: true,
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'max_score_percent',
      voteCountTotal: 4,
      resultColumns: ['chart', 'name', 'score', 'vote_count'],
      resultHeadingKeys: {name: 'common.option', score: 'poll_common.weighted_points', vote_count: 'membership_card.voters'},
      results: [
        {id: 1, name: 'Alpha', name_format: 'plain', score: '2', vote_count: 3, voter_percent: 33},
        {id: 2, name: 'Beta', name_format: 'plain', score: '4', vote_count: 1, voter_percent: 67}
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
      weightedVoting: false,
      closedAt: false,
      chartType: 'pie',
      chartColumn: 'score_percent',
      singleChoice: () => true,
      pieSlices: () => [{color: 'green', value: 100}],
      voteCountTotal: 2,
      resultColumns: ['chart', 'name', 'voter_percent', 'vote_count'],
      resultHeadingKeys: {name: 'common.option', voter_percent: 'poll_ranked_choice_form.pct_of_voters', vote_count: 'membership_card.voters'},
      results: [
        {id: 1, name: 'Agree', name_format: 'plain', color: 'green', vote_count: 1, voter_percent: 50},
        {id: -1, name: 'Not voted', name_format: 'plain', color: 'grey', vote_count: 1, voter_percent: 50}
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
      weightedVoting: true, closedAt: false, chartType: 'bar', chartColumn: 'score_percent',
      pieSlices: () => [],
      resultColumns: ['chart', 'name', 'score_percent', 'unweighted_score', 'score', 'vote_count'],
      resultHeadingKeys: {name: 'common.option', score_percent: 'p', unweighted_score: 'u', score: 's', vote_count: 'v'},
      results: [{id: 1, name: 'Alpha', name_format: 'plain', score_percent: 100, unweighted_score: 1, score: '1', vote_count: 1, voter_percent: 100}]
    });
    const wrapper = shallowMount(ChartTable, {
      props: {poll},
      global: {mocks: {$t: key => key}, stubs: {VTable: {template: '<table><slot /></table>'}, PlainText: {template: '<span>Option</span>'}}}
    });

    await wrapper.findAll('thead button').find(button => button.text() === 'u').trigger('click');
    expect(wrapper.vm.selectedMetric).toBe('unweighted_score');

    poll.resultColumns = ['chart', 'name', 'score_percent', 'score', 'vote_count'];
    await nextTick();

    expect(wrapper.vm.selectedMetric).toBe('score_percent');
  });

  function voterTable(sampleCount, voteCount, hideVoters = false) {
    const ids = Array.from({length: sampleCount}, (_, index) => index + 1);
    const poll = {
      closedAt: false,
      chartType: 'bar',
      chartColumn: 'voter_percent',
      pieSlices: () => [],
      resultColumns: ['name', 'voters'],
      resultHeadingKeys: {name: 'common.option', voters: 'poll_common.voters'},
      results: [{id: 1, name: 'Agree', name_format: 'plain', vote_count: voteCount, voter_ids: ids}]
    };

    return mount(ChartTable, {
      props: {poll, hideVoters},
      data: () => ({users: Object.fromEntries(ids.map(id => [id, {id, name: `Voter ${id}`}]))}),
      global: {
        plugins: [createVuetify()],
        directives: {t: () => {}},
        mocks: {$t: key => key},
        stubs: {
          VTable: {template: '<table><slot /></table>'},
          PlainText: {template: '<span>Agree</span>'}
        }
      }
    });
  }

  it.each([
    [3, 3, 3, ''],
    [4, 4, 4, ''],
    [5, 5, 5, ''],
    [6, 6, 5, '+1'],
    [50, 100, 5, '+95'],
    [0, 100, 0, '+100']
  ])('groups %i supplied identities out of %i voters with accurate overflow', (sample, total, shown, overflow) => {
    const wrapper = voterTable(sample, total);
    expect(wrapper.findAll('.test-voter-avatar')).toHaveLength(shown);
    expect(wrapper.find('.v-avatar-group__overflow').exists()).toBe(Boolean(overflow));
    if (overflow) expect(wrapper.get('.v-avatar-group__overflow').text()).toBe(overflow);
    const avatars = wrapper.findAllComponents({name: 'UserAvatar'});
    expect(avatars).toHaveLength(shown);
    avatars.forEach(avatar => {
      expect(avatar.props('noLink')).toBe(true);
    });
  });

  it('keeps voter identities hidden when the results panel hides voters', () => {
    const wrapper = voterTable(5, 100, true);
    expect(wrapper.find('.v-avatar-group').exists()).toBe(false);
    expect(wrapper.text()).not.toContain('Voter 1');
  });
});
