import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import StanceAbility from '@/shared/abilities/stance_ability';
import PollModel from '@/shared/models/poll_model';
import StanceModel from '@/shared/models/stance_model';

const stanceFor = attributes => {
  const stance = new StanceModel(clientAttributes(attributes));
  stance.attachments = [];
  stance.linkPreviews = [];
  return stance;
};

abilityContract('stance_abilities', {
  update: stance => StanceAbility.update(stance),
  uncast: stance => StanceAbility.uncast(stance),
  redact: stance => StanceAbility.redact(stance),
  unredact: stance => StanceAbility.unredact(stance)
}, (testCase, roles) => {
  const poll = new PollModel(clientAttributes(testCase.poll));
  const stance = stanceFor(testCase.stance);
  const mine = testCase.my_stance && (testCase.my_stance.id === testCase.stance.id ? stance : stanceFor(testCase.my_stance));
  poll.group = () => ({isEnabled: () => true});
  poll.adminsInclude = () => roles.poll_admin;
  poll.myStance = () => mine && !mine.revokedAt ? mine : undefined;
  stance.poll = () => poll;
  return stance;
});
