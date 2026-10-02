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
  it.each([
    ['ordinary member with creation disabled', false, false, false, true, false],
    ['ordinary member with creation enabled', false, false, true, true, true],
    ['nonmember with creation enabled', false, false, true, false, false],
    ['parent group administrator', true, false, false, false, true],
    ['subgroup administrator', false, true, false, true, true]
  ])('checks tag creation for %s', (_role, parentAdmin, groupAdmin, enabled, member, allowed) => {
    const parent = {adminsInclude: () => parentAdmin};
    const group = {
      parentOrSelf: () => parent,
      adminsInclude: () => groupAdmin,
      membersInclude: () => member,
      membersCanCreateTags: enabled
    };

    expect(AbilityService.canCreateTags(group)).toBe(allowed);
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
