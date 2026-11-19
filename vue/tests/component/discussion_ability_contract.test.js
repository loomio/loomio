import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/app_config', () => ({default: {features: {app: {create_user: true}}}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import DiscussionAbility from '@/shared/abilities/discussion_ability';
import NullGroupModel from '@/shared/models/null_group_model';
import AppConfig from '@/shared/services/app_config';
import { session } from './support/ability_contract';

abilityContract('discussion_abilities', {
  create: discussion => DiscussionAbility.canCreate(discussion.group()),
  update: discussion => DiscussionAbility.canUpdate(discussion),
  announce: discussion => DiscussionAbility.canAnnounce(discussion)
}, (testCase, roles) => {
  session.current.groupIds = () => testCase.group_ids || [];
  AppConfig.features.app.create_user = testCase.create_user ?? true;
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
