import { mount } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import AppConfig from '@/shared/services/app_config';
import PollModel from '@/shared/models/poll_model';
import StanceChoices from '@/components/poll/common/stance_choices.vue';

function renderChoice({pollType = 'poll', scoreMin = 1, scoreMax = 1, score = 1, rank = null} = {}) {
  const poll = new PollModel({pollType, scoreMin, scoreMax});
  const stance = {
    poll: () => poll,
    castAt: new Date(),
    totalScore: () => score,
    sortedChoices: () => [{id: 1, score, rank, pollOption: {optionName: () => 'Brno'}}]
  };
  return mount(StanceChoices, {
    props: {stance},
    global: {
      directives: {t: {}},
      stubs: {VIcon: true}
    }
  });
}

describe('stance choices', () => {
  beforeEach(() => {
    AppConfig.pollTypes = {poll: {}, score: {}, dot_vote: {}, ranked_choice: {}};
  });

  it.each([1, 5])('hides the fixed score %i and its separator', score => {
    const wrapper = renderChoice({scoreMin: score, scoreMax: score, score});
    expect(wrapper.get('.poll-common-stance-choice').text()).toBe('Brno');
    expect(wrapper.find('v-icon-stub').exists()).toBe(true);
  });

  it.each([
    ['score', 3],
    ['dot_vote', 4]
  ])('shows the chosen %s score %i', (pollType, score) => {
    const wrapper = renderChoice({pollType, scoreMin: 0, scoreMax: 5, score});
    expect(wrapper.get('.poll-common-stance-choice').text().replace(/\s+/g, ' ')).toBe(`Brno · ${score}`);
  });

  it('shows the rank instead of the underlying score', () => {
    const wrapper = renderChoice({pollType: 'ranked_choice', scoreMin: 1, scoreMax: 5, score: 5, rank: 2});
    expect(wrapper.get('.poll-common-stance-choice').text().replace(/\s+/g, ' ')).toBe('2 · Brno');
  });
});
