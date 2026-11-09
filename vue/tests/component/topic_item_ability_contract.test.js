import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import TopicItemAbility from '@/shared/abilities/topic_item_ability';
import NullGroupModel from '@/shared/models/null_group_model';

abilityContract('topic_item_abilities', {
  pin: item => TopicItemAbility.pin(item),
  unpin: item => TopicItemAbility.unpin(item),
  update_tags: item => TopicItemAbility.updateTags(item)
}, (testCase, roles) => {
  const group = Object.keys(testCase.group).length
    ? {...clientAttributes(testCase.group), isEnabled: () => true}
    : new NullGroupModel();
  const topic = {
    ...clientAttributes(testCase.topic),
    group: () => group,
    adminsInclude: () => roles.topic_admin,
    membersInclude: () => roles.topic_member
  };
  const model = clientAttributes(testCase.model);
  return {...clientAttributes(testCase.item), topic: () => topic, model: () => model};
});
