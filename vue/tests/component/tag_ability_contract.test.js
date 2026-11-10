import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));

import TagAbility from '@/shared/abilities/tag_ability';

abilityContract('tag_abilities', {
  create: group => TagAbility.canCreate(group)
}, (testCase, roles) => {
  const parent = {adminsInclude: () => roles.parent_admin};
  return {
    ...clientAttributes(testCase.group),
    parentOrSelf: () => parent,
    adminsInclude: () => roles.group_admin,
    membersInclude: () => roles.group_member
  };
});
