import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { mount } from '@vue/test-utils';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 2}), userId: 2}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import PollModel from '@/shared/models/poll_model';
import PollCommonClosingAt from '@/components/poll/common/closing_at.vue';

const now = new Date(2026, 10, 8, 12, 0);
const hour = 60 * 60 * 1000;

const poll = (attributes = {}) => new PollModel({
  id: 10, openedAt: new Date(now - 24 * hour), closingAt: new Date(now.getTime() + hour),
  closedAt: null, discardedAt: null, ...attributes
});

describe('poll voting window', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(now);
  });

  afterEach(() => vi.useRealTimers());

  it('is votable while open and before its closing time', () => {
    expect(poll().isVotable()).toBe(true);
  });

  it.each([
    ['lapsed before the expiry job closes it', {closingAt: new Date(now - 1000)}],
    ['closed', {closedAt: new Date(now - hour)}],
    ['discarded', {discardedAt: new Date(now - hour)}],
    ['scheduled', {openedAt: null, openingAt: new Date(now.getTime() + hour)}],
    ['a draft without a closing time', {closingAt: null}]
  ])('is not votable when %s', (_state, attributes) => {
    expect(poll(attributes).isVotable()).toBe(false);
  });

  it('labels a lapsed poll by its closing time until the expiry job closes it', () => {
    const lapsed = poll({closingAt: new Date(now - 1000)});
    const wrapper = mount(PollCommonClosingAt, {
      props: {poll: lapsed},
      global: {directives: {t: {}}}
    });

    expect(wrapper.vm.translationKey).toBe('common.closed_ago');
    expect(wrapper.vm.time).toEqual(lapsed.closingAt);
  });
});

describe('poll results visibility', () => {
  it.each([
    ['results the server has not made available', {hideResults: 'until_closed', resultsAvailable: false}, false],
    ['available results', {hideResults: 'off', resultsAvailable: true}, true],
    ['until-vote results before this user votes', {hideResults: 'until_vote', resultsAvailable: true}, false],
    ['until-vote results after the poll closes', {hideResults: 'until_vote', resultsAvailable: true, closedAt: new Date(now - hour)}, true]
  ])('shows %s accordingly', (_case, attributes, visible) => {
    expect(poll(attributes).showResults()).toBe(visible);
  });
});
