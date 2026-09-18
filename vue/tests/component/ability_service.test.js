import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  currentUser: {id: 1}
}));

vi.mock('@/shared/services/session', () => ({
  default: {user: () => mocks.currentUser}
}));

import AbilityService from '@/shared/services/ability_service';

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
