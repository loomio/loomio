import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  currentUser: {id: 1}
}));

vi.mock('@/shared/services/session', () => ({
  default: {user: () => mocks.currentUser}
}));

import AbilityService from '@/shared/services/ability_service';
import PollAbility from '@/shared/abilities/poll_ability';
import GroupAbility from '@/shared/abilities/group_ability';
import TopicAbility from '@/shared/abilities/topic_ability';
import NullGroupModel from '@/shared/models/null_group_model';

describe('AbilityService.canCreateTags', () => {
  beforeEach(() => {
    mocks.currentUser = {id: 1};
  });

  it.each([
    ['ordinary member with creation disabled', false, false, false, true, false],
    ['ordinary member with creation enabled', false, false, true, true, true],
    ['nonmember with creation enabled', false, false, true, false, false],
    ['parent group administrator', true, false, false, false, true],
    ['subgroup administrator', false, true, false, true, true]
  ])('checks tag creation for %s', (_role, parentAdmin, groupAdmin, enabled, member, allowed) => {
    const parent = {adminsInclude: () => parentAdmin};
    const group = {
      isEnabled: () => true,
      parentOrSelf: () => parent,
      adminsInclude: () => groupAdmin,
      membersInclude: () => member,
      membersCanCreateTags: enabled
    };

    // Viewing a poll before opening the discussion form must not break tags.
    AbilityService.canAnnouncePoll({groupId: 1, group: () => group});
    expect(AbilityService.canCreateTags(group)).toBe(allowed);
  });

  it.each([
    ['direct poll', false, false, true],
    ['restricted direct poll', false, true, false],
    ['discarded poll', true, false, false]
  ])('checks tags with the current session user after a %s', (_state, discarded, specifiedVotersOnly, canAnnounce) => {
    const poll = {
      groupId: null,
      discardedAt: discarded ? '2026-10-06' : null,
      specifiedVotersOnly,
      adminsInclude: () => false,
      membersInclude: user => user.id === 1
    };
    const group = {
      parentOrSelf: () => group,
      adminsInclude: user => user.id === 1,
      membersInclude: () => false,
      membersCanCreateTags: true
    };

    expect(AbilityService.canAnnouncePoll(poll)).toBe(canAnnounce);
    expect(AbilityService.canCreateTags(group)).toBe(true);

    mocks.currentUser = {id: 2};
    expect(AbilityService.canCreateTags(group)).toBe(false);

    mocks.currentUser = {id: null};
    expect(AbilityService.canCreateTags(group)).toBe(false);
  });

  it('returns false for the null group', () => {
    expect(AbilityService.canCreateTags(new NullGroupModel())).toBe(false);
  });
});

describe('TopicAbility.moveComments', () => {
  let group;
  let topic;

  beforeEach(() => {
    group = {isEnabled: vi.fn(() => true)};
    topic = {
      group: vi.fn(() => group),
      adminsInclude: vi.fn(() => true)
    };
  });

  it('allows topic administrators to move items', () => {
    expect(TopicAbility.moveComments(topic)).toBe(true);
    expect(topic.adminsInclude).toHaveBeenCalledWith(mocks.currentUser);
  });

  it('does not allow ordinary topic members to move items', () => {
    topic.adminsInclude.mockReturnValue(false);

    expect(TopicAbility.moveComments(topic)).toBe(false);
  });

  it('does not allow moves involving a disabled group', () => {
    group.isEnabled.mockReturnValue(false);

    expect(TopicAbility.moveComments(topic)).toBe(false);
    expect(topic.adminsInclude).not.toHaveBeenCalled();
  });
});

// Joining is offered only to non-members; GroupAbility.join matches the server.
describe('GroupAbility.join', () => {
  beforeEach(() => { mocks.currentUser = {id: 1, emailVerified: true}; });

  it.each([
    ['parent member', true, false, false, true, false, true],
    ['outsider', false, false, false, true, false, false],
    ['outsider in public subgroup', false, false, false, true, true, true],
    ['parent administrator', true, true, false, true, false, true],
    ['existing subgroup member', true, false, true, true, false, true],
    ['discarded subgroup', true, false, false, false, false, false]
  ])('checks immediate joining for a %s', (_role, parentMember, parentAdmin, member, enabled, publicVisibility, allowed) => {
    const parent = {membersInclude: () => parentMember, adminsInclude: () => parentAdmin};
    const group = {
      parentId: 10,
      parent: () => parent,
      parentOrSelf: () => parent,
      isEnabled: () => enabled,
      isDiscarded: () => !enabled,
      isVisibleToPublic: publicVisibility,
      isVisibleToParentMembers: true,
      privacyIsSecret: () => false,
      membersInclude: () => member,
      membershipGrantedUpon: 'request'
    };

    expect(GroupAbility.join(group)).toBe(allowed);
    expect(GroupAbility.requestMembership(group)).toBe(false);
  });

  it('does not allow ordinary parent members to self join a secret subgroup', () => {
    const parent = {membersInclude: () => true, adminsInclude: () => false};
    const group = {
      parentId: 10,
      parent: () => parent,
      parentOrSelf: () => parent,
      isEnabled: () => true,
      isDiscarded: () => false,
      isVisibleToPublic: false,
      isVisibleToParentMembers: false,
      privacyIsSecret: () => true,
      membersInclude: () => false,
      membershipGrantedUpon: 'invitation'
    };

    expect(GroupAbility.join(group)).toBe(false);
  });
});

describe('poll actions in a locked thread', () => {
  const poll = ({locked = false, closed = false} = {}) => ({
    group: () => ({isEnabled: () => true}),
    topic: () => ({lockedAt: locked ? new Date(2026, 10, 1) : null}),
    discardedAt: null,
    closedAt: closed ? new Date(2026, 10, 2) : null,
    hideResults: 'off',
    anonymous: false,
    adminsInclude: () => true
  });

  it('lets a poll admin edit, delete and reopen polls in an unlocked thread', () => {
    expect(PollAbility.update(poll())).toBe(true);
    expect(PollAbility.destroy(poll())).toBe(true);
    expect(PollAbility.reopen(poll({closed: true}))).toBe(true);
  });

  it('matches the server by blocking edit, delete and reopen once the thread is locked', () => {
    expect(PollAbility.update(poll({locked: true}))).toBe(false);
    expect(PollAbility.destroy(poll({locked: true}))).toBe(false);
    expect(PollAbility.reopen(poll({locked: true, closed: true}))).toBe(false);
  });

  it('still lets a poll admin set an outcome in a locked thread, as the server does', () => {
    expect(AbilityService.canSetPollOutcome(poll({locked: true, closed: true}))).toBeTruthy();
  });
});
