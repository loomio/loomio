import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));

import PollAbility from '@/shared/abilities/poll_ability';

abilityContract('poll_group_create_abilities', {
  create: group => PollAbility.canCreateInGroup(group)
}, (testCase, roles) => ({
  ...clientAttributes(testCase.group),
  isEnabled: () => testCase.group.enabled,
  adminsInclude: () => roles.group_admin,
  membersInclude: () => roles.group_member
}));
