import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));

import ReactionAbility from '@/shared/abilities/reaction_ability';

abilityContract('reaction_abilities', {
  create: topic => ReactionAbility.canCreate(topic)
}, (testCase, roles) => ({
  ...clientAttributes(testCase.topic),
  group: () => ({isEnabled: () => true}),
  membersInclude: () => roles.topic_member
}));
