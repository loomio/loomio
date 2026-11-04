import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  currentUser: {id: 1}
}));

vi.mock('@/shared/services/session', () => ({
  default: {user: () => mocks.currentUser}
}));

import AbilityService from '@/shared/services/ability_service';
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

describe('AbilityService.canMoveTopicItems', () => {
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
    expect(AbilityService.canMoveTopicItems(topic)).toBe(true);
    expect(topic.adminsInclude).toHaveBeenCalledWith(mocks.currentUser);
  });

  it('does not allow ordinary topic members to move items', () => {
    topic.adminsInclude.mockReturnValue(false);

    expect(AbilityService.canMoveTopicItems(topic)).toBe(false);
  });

  it('does not allow moves involving a disabled group', () => {
    group.isEnabled.mockReturnValue(false);

    expect(AbilityService.canMoveTopicItems(topic)).toBe(false);
    expect(topic.adminsInclude).not.toHaveBeenCalled();
  });
});

describe('AbilityService.canJoinGroup', () => {
  it.each([
    ['parent member', true, false, false, true, false, true],
    ['outsider', false, false, false, true, false, false],
    ['outsider in public subgroup', false, false, false, true, true, true],
    ['parent administrator', true, true, false, true, false, true],
    ['existing subgroup member', true, false, true, true, false, false],
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

    expect(AbilityService.canJoinGroup(group)).toBe(allowed);
    expect(AbilityService.canRequestMembership(group)).toBe(false);
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

    expect(AbilityService.canJoinGroup(group)).toBe(false);
  });
});
