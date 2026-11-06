import { beforeEach, describe, expect, it, vi } from 'vitest';
import Loki from 'lokijs';

const mocks = vi.hoisted(() => ({fetch: vi.fn(), polls: null, stances: null}));
vi.mock('@/shared/services/records', () => ({default: {
  polls: {fetch: mocks.fetch, get collection() { return mocks.polls; }},
  stances: {find: query => mocks.stances.find(query)}
}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 1})}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import PollModel from '@/shared/models/poll_model';

function poll(id, attributes = {}) {
  const model = Object.assign(Object.create(PollModel.prototype), {
    id, groupId: 10, anonymous: false, myStanceId: id,
    discardedAt: null, closedAt: null, openedAt: new Date(),
    closingAt: new Date(Date.now() + 86400000), voterHasAccess: true,
    ...attributes
  });
  mocks.polls.insert(model);
  if (!model.anonymous) mocks.stances.insert({id, castAt: null, revokedAt: null});
  return model;
}

beforeEach(() => {
  vi.resetModules();
  mocks.fetch.mockReset();
  const db = new Loki('pending-polls');
  mocks.polls = db.addCollection('polls');
  mocks.stances = db.addCollection('stances');
});

describe('shared pending polls', () => {
  it('shares all pages between simultaneous consumers and later mounts', async () => {
    const {usePendingPolls} = await import('@/composables/usePendingPolls');
    let finishFirstPage;
    mocks.fetch.mockImplementationOnce(() => new Promise(resolve => { finishFirstPage = resolve; }));
    mocks.fetch.mockResolvedValueOnce({polls: [{id: 101}], meta: {total: 101}});
    const navigation = usePendingPolls();
    const dashboard = usePendingPolls();
    const loading = navigation.loadPendingPolls();
    expect(dashboard.loadPendingPolls()).toBe(loading);
    expect(dashboard.loading.value).toBe(true);
    expect(mocks.fetch).toHaveBeenCalledTimes(1);

    finishFirstPage({polls: Array.from({length: 100}, (_, id) => ({id})), meta: {total: 101}});
    await loading;

    expect(mocks.fetch.mock.calls.map(([args]) => args.params)).toEqual([
      {status: 'vote', limit: 100, offset: 0},
      {status: 'vote', limit: 100, offset: 100}
    ]);
    expect(dashboard.loading.value).toBe(false);
    expect(usePendingPolls().loadPendingPolls()).toBe(loading);
    expect(mocks.fetch).toHaveBeenCalledTimes(2);
  });

  it('finishes an empty pending list with one request', async () => {
    mocks.fetch.mockResolvedValue({polls: [], meta: {total: 0}});
    const {usePendingPolls} = await import('@/composables/usePendingPolls');
    const {loadPendingPolls, loading} = usePendingPolls();
    await loadPendingPolls();
    expect(loading.value).toBe(false);
    expect(mocks.fetch).toHaveBeenCalledTimes(1);
  });

  it('includes identified and anonymous invitations without requiring group membership', async () => {
    const identified = poll(1, {groupId: null});
    const anonymous = poll(2, {anonymous: true, anonymousVoterEligible: true, myStanceId: null});
    poll(3, {voterHasAccess: false});
    poll(4, {anonymous: true, anonymousVoterEligible: false});
    const {usePendingPolls} = await import('@/composables/usePendingPolls');
    const {findPendingPolls} = usePendingPolls();
    expect(findPendingPolls().map(poll => poll.id).sort()).toEqual([1, 2]);

    mocks.stances.findOne({id: identified.id}).castAt = new Date();
    expect(findPendingPolls().map(poll => poll.id)).toEqual([2]);
    anonymous.anonymousBallotSubmitted = true;
    expect(findPendingPolls()).toEqual([]);
  });

  it('removes revoked, closed, expired, discarded and unopened polls from every count', async () => {
    const pending = poll(1);
    poll(2, {closedAt: new Date()});
    poll(3, {closingAt: new Date(Date.now() - 1000)});
    poll(4, {discardedAt: new Date()});
    poll(5, {openedAt: null});
    poll(6);
    mocks.stances.findOne({id: 6}).revokedAt = new Date();
    const {usePendingPolls} = await import('@/composables/usePendingPolls');
    expect(usePendingPolls().findPendingPolls().map(poll => poll.id)).toEqual([pending.id]);
  });
});
