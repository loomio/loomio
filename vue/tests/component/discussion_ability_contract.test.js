import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import DiscussionAbility from '@/shared/abilities/discussion_ability';
import NullGroupModel from '@/shared/models/null_group_model';

abilityContract('discussion_abilities', {
  create: discussion => DiscussionAbility.create(discussion.group()),
  update: discussion => DiscussionAbility.update(discussion),
  announce: discussion => DiscussionAbility.announce(discussion)
}, (testCase, roles) => {
  const group = Object.keys(testCase.group).length ? {
    ...clientAttributes(testCase.group),
    isEnabled: () => true,
    privacyIsSecret() { return this.groupPrivacy === 'secret'; },
    adminsInclude: () => roles.group_admin,
    membersInclude: () => roles.group_member
  } : new NullGroupModel();
  const topic = {
    ...clientAttributes(testCase.topic),
    group: () => group,
    adminsInclude: () => roles.topic_admin,
    membersInclude: () => roles.topic_member
  };
  return {
    ...clientAttributes(testCase.discussion),
    topic: () => topic,
    group: () => group,
    authorIs: () => roles.author
  };
});
