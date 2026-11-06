import {beforeEach, describe, expect, it, vi} from 'vitest';
import {computed} from 'vue';
import Loki from 'lokijs';

const mocks = vi.hoisted(() => ({destroy: vi.fn(), records: {}}));
vi.mock('@/shared/services/app_config', () => ({default: {currentUserId: 1}}));
vi.mock('@/shared/services/records', () => ({default: mocks.records}));

import MembershipModel from '@/shared/models/membership_model';
import MembershipRecordsInterface from '@/shared/interfaces/membership_records_interface';
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import RecordStore from '@/shared/record_store/record_store';
import GroupModel from '@/shared/models/group_model';
import UserModel from '@/shared/models/user_model';

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

describe('membership revocation', () => {
  let membership;
  let polls;
  let stances;
  let topics;
  let memberships;

  beforeEach(() => {
    mocks.destroy.mockReset().mockResolvedValue({groups: [{id: 10}]});
    membership = Object.assign(Object.create(MembershipModel.prototype), {
      id: 7, userId: 1, groupId: 10, revokedAt: null,
      update: vi.fn(function (changes) { Object.assign(this, changes); }),
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
    memberships = [11, 12].map(groupId => record({groupId, userId: 1, revokedAt: null}));
    memberships.push(record({groupId: 10, userId: 2}));
    Object.assign(mocks.records, {
      memberships: {
        ...collection(memberships), remote: {destroy: mocks.destroy}, recordStore: mocks.records,
        revokeGroupAccess: MembershipRecordsInterface.prototype.revokeGroupAccess
      },
      topics: collection(topics), polls: collection(polls), stances: collection(stances)
    });
    mocks.records.updateViews = vi.fn();
  });

  it('clears current-user eligibility in the group and its subgroups after success', async () => {
    await expect(membership.destroy()).resolves.toEqual({groups: [{id: 10}]});
    expect(mocks.destroy).toHaveBeenCalledWith(7);
    expect(membership.revokedAt).toBeInstanceOf(Date);
    expect(membership.remove).not.toHaveBeenCalled();
    expect(membership.processing).toBe(false);
    polls.slice(0, 2).forEach(poll => {
      expect(poll.myStanceId).toBe(null);
      expect(poll.anonymousVoterEligible).toBe(false);
    });
    stances.slice(0, 2).forEach(stance => expect(stance.remove).toHaveBeenCalledOnce());
    topics.slice(0, 2).forEach(topic => {
      expect(topic.readerGuest).toBe(false);
      expect(topic.readerAdmin).toBe(false);
    });
    expect(memberships[0].revokedAt).toBeInstanceOf(Date);
    expect(memberships[0].remove).not.toHaveBeenCalled();
    expect(mocks.records.updateViews).toHaveBeenCalledWith(['memberships', 'topics', 'polls', 'stances']);
    memberships.slice(1).forEach(member => expect(member.remove).not.toHaveBeenCalled());
    polls.slice(2, 4).forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    expect(polls[4].update).toHaveBeenCalledWith({voterHasAccess: false});
    expect(polls[4].myStanceId).toBe(34);
    stances.slice(2).forEach(stance => expect(stance.remove).not.toHaveBeenCalled());
    topics.slice(2).forEach(topic => expect(topic.update).not.toHaveBeenCalled());
  });

  it('keeps eligibility while the request is pending and when it fails', async () => {
    let rejectRequest;
    mocks.destroy.mockReturnValue(new Promise((_resolve, reject) => { rejectRequest = reject; }));
    const request = membership.destroy();
    expect(membership.revokedAt).toBe(null);
    expect(membership.remove).not.toHaveBeenCalled();
    polls.forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    rejectRequest(new Error('Forbidden'));
    await expect(request).rejects.toThrow('Forbidden');
    expect(membership.revokedAt).toBe(null);
    expect(membership.processing).toBe(false);
    polls.forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    stances.forEach(stance => expect(stance.remove).not.toHaveBeenCalled());
    topics.forEach(topic => expect(topic.update).not.toHaveBeenCalled());
    memberships.forEach(member => expect(member.remove).not.toHaveBeenCalled());
  });

  it('does not clear the current-user cache when removing another member', async () => {
    membership.userId = 2;
    await membership.destroy();
    expect(membership.revokedAt).toBeInstanceOf(Date);
    expect(membership.remove).not.toHaveBeenCalled();
    polls.forEach(poll => expect(poll.update).not.toHaveBeenCalled());
    stances.forEach(stance => expect(stance.remove).not.toHaveBeenCalled());
    topics.forEach(topic => expect(topic.update).not.toHaveBeenCalled());
    memberships.forEach(member => expect(member.remove).not.toHaveBeenCalled());
  });

  it('applies the same invalidation to realtime removal without a local destroy request', () => {
    mocks.records.memberships.revokeGroupAccess([10, 11]);
    expect(mocks.destroy).not.toHaveBeenCalled();
    expect(polls[0].myStanceId).toBe(null);
    expect(polls[1].anonymousVoterEligible).toBe(false);
    expect(stances[0].remove).toHaveBeenCalledOnce();
    expect(topics[0].readerGuest).toBe(false);
    expect(memberships[0].revokedAt).toBeInstanceOf(Date);
    expect(memberships[0].remove).not.toHaveBeenCalled();
    expect(polls[2].update).not.toHaveBeenCalled();
  });

  it('restores group membership and pages recent polls after rejoining', async () => {
    const fetch = vi.fn()
      .mockResolvedValueOnce({meta: {total: 201}})
      .mockResolvedValueOnce({meta: {total: 201}})
      .mockResolvedValueOnce({meta: {total: 201}});
    const findOrFetch = vi.fn().mockResolvedValue({key: 'group-key'});
    const closed = record({id: 99, groupId: 10, voterHasAccess: false});
    const refreshGroups = vi.fn().mockResolvedValue({});
    const records = {groups: {findOrFetch}, users: {refreshGroups}, polls: {fetch, ...collection([closed])}, updateViews: vi.fn()};
    const restore = MembershipRecordsInterface.prototype.restoreGroupAccess.bind({recordStore: records, find: () => [{}]});

    await restore([10]);

    expect(findOrFetch).toHaveBeenCalledWith(10);
    expect(refreshGroups).toHaveBeenCalledOnce();
    expect(closed.voterHasAccess).toBe(true);
    expect(fetch.mock.calls.map(([request]) => request.params)).toEqual([0, 100, 200].map(offset => ({
      group_key: 'group-key', subgroups: 'none', status: 'recent', limit: 100, offset
    })));
  });
});

describe('retained memberships', () => {
  it('reactively removes access and group listings, then restores the same record on rejoin', () => {
    const store = new RecordStore(new Loki('membership-access'));
    store.addRecordsInterface(MembershipRecordsInterface);
    for (const model of [UserModel, GroupModel]) {
      const records = new BaseRecordsInterface(store);
      records.model = model;
      records.baseConstructor(store);
      store[model.plural] = records;
    }
    Object.assign(mocks.records, {memberships: store.memberships, users: store.users, groups: store.groups});
    const user = store.users.create({id: 1});
    const group = store.groups.create({id: 10});
    const membership = store.memberships.importRecord({id: 7, userId: 1, groupId: 10, admin: true});
    const groupIds = computed(() => user.groupIds());
    const memberAccess = computed(() => group.membersInclude(user));
    const adminAccess = computed(() => group.adminsInclude(user));

    expect(groupIds.value).toEqual([10]);
    expect(memberAccess.value).toBe(true);
    expect(adminAccess.value).toBe(true);

    membership.update({revokedAt: new Date()});

    expect(store.memberships.find(7)).toBe(membership);
    expect(groupIds.value).toEqual([]);
    expect(memberAccess.value).toBe(false);
    expect(adminAccess.value).toBe(false);
    expect(user.membershipFor(group)).toBeUndefined();
    expect(user.adminMemberships()).toEqual([]);
    expect(group.memberships()).toEqual([]);
    expect(group.adminMemberships()).toEqual([]);
    expect(group.parentAndSelfMemberships()).toEqual([]);
    expect(store.memberships.forUser(user)).toEqual([]);
    expect(store.memberships.forGroup(group)).toEqual([]);
    expect(store.memberships.forModel(user)).toEqual([]);

    store.memberships.importRecord({id: 7, userId: 1, groupId: 10, admin: false, revokedAt: null});

    expect(store.memberships.find(7)).toBe(membership);
    expect(groupIds.value).toEqual([10]);
    expect(memberAccess.value).toBe(true);
    expect(adminAccess.value).toBe(false);
    expect(user.membershipFor(group)).toBe(membership);
  });
});
