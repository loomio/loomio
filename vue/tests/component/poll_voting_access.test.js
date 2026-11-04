import {describe, expect, it, vi} from 'vitest';

vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 1})}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import PollModel from '@/shared/models/poll_model';

function poll(attributes = {}) {
  return Object.assign(Object.create(PollModel.prototype), {
    groupId: 10, anonymous: false, voterHasAccess: false,
    isVotable: () => true, myStance: () => ({id: 20}),
    topic: () => ({membersInclude: () => false}),
    ...attributes
  });
}

describe('poll voting access', () => {
  it('does not offer voting to former group members with retained voter records', () => {
    expect(poll().iCanVote()).toBe(false);
    expect(poll({anonymous: true, anonymousVoterEligible: true}).iCanVote()).toBe(false);
  });

  it('allows current members and topic guests with pending votes', () => {
    // Compact poll responses omit groups and memberships; access is supplied
    // with the viewer's voting state rather than requiring those records.
    const access = {voterHasAccess: true, topic: () => null};
    expect(poll(access).iCanVote()).toBe(true);
    expect(poll({...access, anonymous: true, anonymousVoterEligible: true}).iCanVote()).toBe(true);
    expect(poll({...access, anonymous: true, anonymousVoterEligible: true, anonymousBallotSubmitted: true}).iCanVote()).toBe(false);
  });

  it('preserves direct-poll voting without group membership', () => {
    expect(poll({groupId: null, voterHasAccess: true}).iCanVote()).toBe(true);
    expect(poll({groupId: null, voterHasAccess: true, anonymous: true, anonymousVoterEligible: true}).iCanVote()).toBe(true);
  });
});
