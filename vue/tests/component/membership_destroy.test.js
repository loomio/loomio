import {beforeEach, describe, expect, it, vi} from 'vitest';

const mocks = vi.hoisted(() => ({destroy: vi.fn(), records: {}}));
vi.mock('@/shared/services/app_config', () => ({default: {currentUserId: 1}}));
vi.mock('@/shared/services/records', () => ({default: mocks.records}));

import MembershipModel from '@/shared/models/membership_model';

function record(attributes) {
  return {
    ...attributes,
    update: vi.fn(function (changes) { Object.assign(this, changes); }),
    remove: vi.fn()
  };
}

function collection(records) {
  return {find: query => records.filter(item => Object.entries(query).every(([key, value]) =>
    value?.$in ? value.$in.includes(item[key]) : item[key] === value
  ))};
}

describe('membership removal', () => {
  let membership;
  let polls;
  let stances;
  let topics;
  let memberships;

  beforeEach(() => {
    mocks.destroy.mockReset().mockResolvedValue({groups: [{id: 10}]});
    membership = Object.assign(Object.create(MembershipModel.prototype), {
      id: 7, userId: 1, groupId: 10,
      group: () => ({selfAndSubgroupIds: () => [10, 11]}),
      remove: vi.fn()
    });
    polls = [10, 11, 12, null].map((groupId, i) => record({
      id: 20 + i, groupId, myStanceId: 30 + i,
      anonymousVoterEligible: true, isVotable: () => true
    }));
    polls.push(record({id: 24, groupId: 10, myStanceId: 34, isVotable: () => false}));
    stances = polls.map(poll => record({id: poll.myStanceId, pollId: poll.id, participantId: 1}));
    stances.push(record({id: 35, pollId: 20, participantId: 2}));
    topics = [10, 11, 12, null].map(groupId => record({groupId, readerGuest: true, readerAdmin: true}));
    memberships = [11, 12].map(groupId => record({groupId, userId: 1}));
    memberships.push(record({groupId: 10, userId: 2}));
    Object.assign(mocks.records, {
      memberships: {...collection(memberships), remote: {destroy: mocks.destroy}},
      topics: collection(topics), polls: collection(polls), stances: collection(stances)
    });
  });

  it('clears current-user eligibility in the group and its subgroups after success', async () => {
    await expect(membership.destroy()).resolves.toEqual({groups: [{id: 10}]});
    expect(mocks.destroy).toHaveBeenCalledWith(7);
    polls.slice(0, 2).forEach(poll => {
      expect(poll.myStanceId).toBe(null);
      expect(poll.anonymousVoterEligible).toBe(false);
    });
    stances.slice(0, 2).forEach(stance => expect(stance.remove).toHaveBeenCalledOnce());
    topics.slice(0, 2).forEach(topic => {
      expect(topic.readerGuest).toBe(false);
      expect(topic.readerAdmin).toBe(false);
    });
    expect(memberships[0].remove).toHaveBeenCalledOnce();
    memberships.slice(1).forEach(member => expect(member.remove).not.toHaveBeenCalled());
    polls.slice(2).forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    stances.slice(2).forEach(stance => expect(stance.remove).not.toHaveBeenCalled());
    topics.slice(2).forEach(topic => expect(topic.update).not.toHaveBeenCalled());
  });

  it('keeps eligibility while the request is pending and when it fails', async () => {
    let rejectRequest;
    mocks.destroy.mockReturnValue(new Promise((_resolve, reject) => { rejectRequest = reject; }));
    const request = membership.destroy();
    polls.forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    rejectRequest(new Error('Forbidden'));
    await expect(request).rejects.toThrow('Forbidden');
    polls.forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    stances.forEach(stance => expect(stance.remove).not.toHaveBeenCalled());
    topics.forEach(topic => expect(topic.update).not.toHaveBeenCalled());
    memberships.forEach(member => expect(member.remove).not.toHaveBeenCalled());
  });

  it('does not clear the current-user cache when removing another member', async () => {
    membership.userId = 2;
    await membership.destroy();
    polls.forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    stances.forEach(stance => expect(stance.remove).not.toHaveBeenCalled());
    topics.forEach(topic => expect(topic.update).not.toHaveBeenCalled());
    memberships.forEach(member => expect(member.remove).not.toHaveBeenCalled());
  });
});
