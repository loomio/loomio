import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import MembershipAbility from '@/shared/abilities/membership_ability';

abilityContract('membership_abilities', {
  update: membership => MembershipAbility.canUpdate(membership),
  resend: membership => MembershipAbility.canResend(membership),
  destroy: membership => MembershipAbility.canDestroy(membership)
}, (testCase, roles) => {
  const group = {isEnabled: () => true, adminsInclude: () => roles.group_admin};
  return {...clientAttributes(testCase.membership), group: () => group};
});
